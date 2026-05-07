#' Compute approximate cross section along a depth transect
#'
#' @description
#' Compute the depth along a linear transect which bounds are specified by the user.
#'
#' @rdname mar_get_transect
#' @usage
#' mar_get_transect(mat, x1, y1, x2, y2, locator=FALSE, distance=FALSE, \dots)
#' @param mat bathymetric data matrix of class \code{bathy}, imported using \code{mar_read_bathy} (no default)
#' @param x1 start longitude of the transect (no default)
#' @param x2 stop longitude of the transect (no default)
#' @param y1 start latitude of the transect (no default)
#' @param y2 stop latitude of the transect (no default)
#' @param locator whether to use locator to choose transect bounds interactively with a map (default is \code{FALSE})
#' @param distance whether to compute the haversine distance (in km) from the start of the transect, along the transect (default is \code{FALSE})
#' @param \dots other arguments to be passed to \code{locator()} to specify the characteristics of the points and lines to draw on the bathymetric map when \code{locator=TRUE}.
#'
#' @details
#' \code{mar_get_transect} allows the user to compute an approximate linear depth cross section either by inputing start and stop coordinates, or by clicking on a map created with \code{mar_plot_bathy}. In its interactive mode, this function uses the \code{locator} function (\code{graphics} package); after creating a map with \code{mar_plot_bathy}, the user can click twice to delimit the bound of the transect of interest (for example, lower left and upper right corners of a rectangular area of interest), press Escape, and get a table with the transect information.
#'
#' @return
#' A table with, at least, longitude, latitude and depth along the transect, and if specified (distance=\code{TRUE}), the distance in kilometers from the start of the transect. The number of elements in the resulting table depends on the resolution of the \code{bathy} object.
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_read_bathy}}, \code{\link{nw.atlantic}}, \code{\link{nw.atlantic.coast}}, \code{\link{mar_get_depth}}, \code{\link{mar_get_sample}}
#'
#' @examples
#' # load datasets
#' 	data(nw.atlantic); mar_as_bathy(nw.atlantic) -> atl
#' 	data(nw.atlantic.coast)
#'
#' # Example 1. mar_get_transect(), without use of locator()
#' 	mar_get_transect(atl, -65, 43,-59,40) -> test ; plot(test[,3]~test[,2],type="l")
#' 	mar_get_transect(atl, -65, 43,-59,40, distance=TRUE) -> test ; plot(test[,4]~test[,3],type="l")
#'
#' # Example 2. mar_get_transect(), without use of locator(); pretty plot
#' 	par(mfrow=c(2,1),mai=c(1.2, 1, 0.1, 0.1))
#' 	plot(atl, deep=-6000, shallow=-10, step=1000, lwd=0.5, col="grey50",drawlabels=TRUE)
#' 	lines(nw.atlantic.coast)
#'
#' 	mar_get_transect(atl, -75, 44,-46,32, loc=FALSE, dis=TRUE) -> test
#' 	points(test$lon,test$lat,type="l",col="blue",lwd=2,lty=2)
#' 	mar_plot_profile(test)
#'
#' # Example 3. mar_get_transect(), with use of locator(); pretty plot
#' \dontrun{
#' 	par(mfrow=c(2,1),mai=c(1.2, 1, 0.1, 0.1))
#' 	plot(atl, deep=-6000, shallow=-10, step=1000, lwd=0.5, col="grey50",drawlabels=TRUE)
#' 	lines(nw.atlantic.coast)
#'
#' 	mar_get_transect(atl, loc=TRUE, dis=TRUE, col=2, lty=2) -> test
#' 	mar_plot_profile(test)
#' 	}
#' @export
#' @aliases get.transect
mar_get_transect = function(mat, x1, y1, x2, y2, locator=FALSE, distance=FALSE,...){

	as.numeric(rownames(mat)) -> lon
	as.numeric(colnames(mat)) -> lat

## test that the locator input data corresponds to two points
	if (locator) {
		locator(n=2,type="o",...)->coord
		if (length(coord$x) == 1) stop("Please choose two points from the map")
		x1=coord$x[1];x2=coord$x[2];y1=coord$y[1];y2=coord$y[2]
	}

## test that the manual input data is within the bounds of mat
	if ( x1<min(lon) | x1>max(lon) ) stop("x1 not within the longitudinal range of mat")
	if ( x2<min(lon) | x2>max(lon) ) stop("x2 not within the longitudinal range of mat")
	if ( y1<min(lat) | y1>max(lat) ) stop("y1 not within the latitudinal range of mat")
	if ( y2<min(lat) | y2>max(lat) ) stop("y2 not within the latitudinal range of mat")

## reduce mat to the bounds of the input area and switch orientation to get values along the (approximate) diagonal
	which.min(abs(lon-x1)) -> x1b
	which.min(abs(lat-y1)) -> y1b
	which.min(abs(lon-x2)) -> x2b
	which.min(abs(lat-y2)) -> y2b
	
	if (x1b==x2b | y1b==y2b) {
		new.bathy <- matrix(as.vector(mat[x1b:x2b, y1b:y2b]),nrow=length(y1b:y2b),ncol=length(x1b:x2b),dimnames=list(lat[y1b:y2b],lon[x1b:x2b]))
		depth <- as.vector(new.bathy)
	} else {
		new.bathy <- t(mat[x1b:x2b, y1b:y2b])
		depth <- mar_diag_bathy(new.bathy)
	}

## check (and fix if needed) dimentions of new matrix
	as.numeric(colnames(new.bathy)) -> lon
	as.numeric(rownames(new.bathy)) -> lat

	if (length(lon) == 1) lon <- rep(lon,length(lat))
	if (length(lat) == 1) lat <- rep(lat,length(lon))

	if (length(lon)<length(lat)) lon <- seq(lon[1],lon[length(lon)],length.out=length(lat))
	if (length(lon)>length(lat)) lat <- seq(lat[1],lat[length(lat)],length.out=length(lon))

## output format: add distances from x1y1 ?
	if(distance == F) return(data.frame(lon, lat, depth))
	if(distance == T){
		
		deg2km <- function(x1, y1, x2, y2) {

			x1 <- x1*pi/180
			y1 <- y1*pi/180
			x2 <- x2*pi/180
			y2 <- y2*pi/180

			dx <- x2-x1
			dy <- y2-y1

			fo <- sin(dy/2)^2 + cos(y1) * cos(y2) * sin(dx/2)^2
			fos <- 2 * asin(min(1,sqrt(fo)))

			return(6371 * fos)
		}
		
		dist.km = NULL
		for(i in 1:length(depth)){
			dist.km = c(dist.km, deg2km(x1=lon[1],y1=lat[1],x2=lon[i],y2=lat[i]))
		}
		out <- data.frame(lon, lat, dist.km, depth)
		return(out)
	}
}

#' @rdname mar_get_transect
#' @export
get.transect <- mar_get_transect
