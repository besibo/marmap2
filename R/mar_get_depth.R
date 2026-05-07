#' Get depth data by clicking on a map
#'
#' @description
#' Outputs depth information based on points selected by clicking on a map
#'
#' @rdname mar_get_depth
#' @usage
#' mar_get_depth(mat, x, y=NULL, locator=TRUE, distance=FALSE, \dots)
#' @param mat Bathymetric data matrix of class \code{bathy}, as imported with \code{mar_read_bathy}.
#' @param x Either a list of two elements (numeric vectors of longitude and latitude), a 2-column matrix or data.frame of longitudes and latitudes, or a numeric vector of longitudes.
#' @param y Either \code{NULL} (default) or a numerical vector of latitudes. Ignored if \code{x} is not a numeric vector.
#' @param locator Logical. Whether to choose data points interactively with a map or not. If \code{TRUE} (default), a bathymetric map must have been plotted and both \code{x} and \code{y} are both ignored.
#' @param distance whether to compute the haversine distance (in km) from the first data point on (default is \code{FALSE}). Only available when at least two points are provided.
#' @param ... Further arguments to be passed to \code{locator} when the interactive mode is used (\code{locator=TRUE}).
#'
#' @details
#' \code{mar_get_depth} allows the user to get depth data by clicking on a map created with \code{mar_plot_bathy} or by providing coordinates of points of interest. This function uses the \code{locator} function (\code{graphics} package); after creating a map with \code{mar_plot_bathy}, the user can click on the map once or several times (if \code{locator=TRUE}), press the Escape button, and get the depth of those locations in a three-coumn data.frame (longitude, latitude and depth). Alternatively, when \code{locator=FALSE}, the user can submit a list of longitudes and latitudes, a two-column matrix or data.frame of longitudes and latitudes (as input for \code{x}), or one vector of longitudes (\code{x}) and one vector of latitudes (\code{y}). The non-interactive mode is well suited to get depth information for each point provided by GPS tracking devices. While \code{\link{mar_get_transect}} gets every single depth value available in the bathymetric matrix between two points along a user-defined transect, \code{mar_get_depth} only provides depth data for the specific points provided as input by the user.
#'
#' @return
#' A data.frame with at least, longitude, latitude and depth with one line for each point of interest. If \code{distance=TRUE}, a fourth column containing the kilometric distance from the first point is added.
#'
#' @author
#' Benoit Simon-Bouhet and Eric Pante
#'
#' @seealso
#' \code{\link{mar_path_profile}}, \code{\link{mar_get_transect}}, \code{\link{mar_read_bathy}}, \code{\link{mar_summary_bathy}}, \code{\link{mar_subset_bathy}}, \code{\link{nw.atlantic}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' data(nw.atlantic)
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' # create vectors of latitude and longitude
#' lon <- c(-70, -65, -63, -55)
#' lat <- c(33, 35, 40, 37)
#'
#' # a simple example
#' plot(atl, lwd=.5)
#' points(lon,lat,pch=19,col=2)
#'
#' # Use mar_get_depth to get the depth for each point
#' mar_get_depth(atl, x=lon, y=lat, locator=FALSE)
#'
#' # alternativeley once the map is plotted, use the iteractive mode:
#' \dontrun{
#' mar_get_depth(atl, locator=TRUE, pch=19, col=3)
#' }
#' # click several times and press Escape
#' @export
#' @aliases get.depth
mar_get_depth <- function(mat, x, y=NULL, locator=TRUE, distance=FALSE, ...){

	if (!is(mat,"bathy")) stop("'mat' must be of class 'bathy'")

	if (locator == FALSE) {

		if (!is.null(y) & !is.vector(y)) stop("'y' must be a numeric vector or NULL")
		if (!is.null(y) & !is.numeric(y)) stop("'y' must be a numeric vector or NULL")

		if (is.list(x)) {
			if (length(x)!=2) stop("if 'x' is a list, it must contain only two vectors of the same length (longitude and latitude)")
			if (!is.vector(x[[1]]) | !is.vector(x[[2]])) stop("if 'x' is a list, it must contain only two vectors of the same length (longitude and latitude)")
			if (length(x[[1]]) != length(x[[2]])) stop("if 'x' is a list, it must contain only two vectors of the same length (longitude and latitude)")
			if (!is.null(y)) warning("'y' has been ignored\n")
			coord <- x ; names(coord) <- c("x","y")
			}

		if (is.data.frame(x) | is.matrix(x)) {

			x <- as.matrix(x)

			if (ncol(x) > 2) {
				warning("'x' has too many columns. Only the first two will be considered\n")
				x <- x[,1:2]
				coord <- list(x=x[,1],y=x[,2])
				if (!is.null(y)) warning("only the first two columns of 'x' were considered. 'y' has been ignored\n")
				}

			if (ncol(x) == 2) {
				coord <- list(x=x[,1],y=x[,2])
				if (!is.null(y)) warning("since 'x' has 2 columns, 'y' has been ignored\n")
				}

			if (ncol(x) == 1) {
				if (is.null(y)) stop("with 'locator=FALSE', you must supply both 'x' and 'y' or a 2-column matrix-like 'x'")
				coord <- list(x=x,y=y)
				}

			}

		if (!is.list(x)) {
			if (is.vector(x) & !is.numeric(x)) stop("'x' must be numeric")
			if (is.vector(x) & is.numeric(x)) {
				if (is.null(y)) stop("with 'locator=FALSE', you must either provide both 'x' and 'y' or a 2-column matrix-like 'x'")
					if (length(x) != length(y)) warning("The lengths of 'x' and 'y' differ. Some values have been recycled\n")
						coord <- list(x=x,y=y)
				}
			}

		} else {
			message("Waiting for interactive input: click any number of times on the map, then press 'Esc'")
			coord <- locator(type="p",...)
		}

	as.numeric(rownames(mat)) -> lon
	as.numeric(colnames(mat)) -> lat

	outside.lon <- any(findInterval(coord$x,range(lon),rightmost.closed=TRUE) != 1)
	outside.lat <- any(findInterval(coord$y,range(lat),rightmost.closed=TRUE) != 1)

	if (outside.lon | outside.lat) stop("Some data points are oustide the range of mat")

	out <- data.frame(lon=coord$x, lat=coord$y)
	out$depth <- apply(out, 1, function(x) mat[ which(abs(lon-x[1])==min(abs(lon-x[1]))) , which(abs(lat-x[2])==min(abs(lat-x[2]))) ][1])

	if(distance){

		if (nrow(out) == 1) stop("Cannot compute distance with only one point. Either set distance=FALSE or add more points")

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
		for(i in 2:length(out$depth)){
			dist.km = c(dist.km, deg2km(x1=out$lon[i-1],y1=out$lat[i-1],x2=out$lon[i],y2=out$lat[i]))
		}
		out$dist.km <- cumsum(c(0,dist.km))
		out <- out[,c(1,2,4,3)]
	}

	return(out)

}

#' @rdname mar_get_depth
#' @export
get.depth <- mar_get_depth
