#' Get bathymetric information of a belt transect
#'
#' @description
#' \code{mar_get_box} gets depth information of a belt transect of width \code{width} around a transect defined by two points on a bathymetric map.
#'
#' @rdname mar_get_box
#' @usage
#' mar_get_box(bathy,x1,x2,y1,y2,width,locator=FALSE,ratio=FALSE, \dots)
#' @param bathy Bathymetric data matrix of class \code{bathy}.
#' @param x1 Numeric. Start longitude of the transect. Requested when \code{locator=FALSE}.
#' @param x2 Numeric. Stop longitude of the transect. Requested when \code{locator=FALSE}.
#' @param y1 Numeric. Start latitude of the transect. Requested when \code{locator=FALSE}.
#' @param y2 Numeric. Stop latitude of the transect. Requested when \code{locator=FALSE}.
#' @param width Numeric. Width of the belt transect in degrees.
#' @param locator Logical. Whether to choose transect bounds interactively with a map or not. When \code{FALSE} (default), a bathymetric map  (\code{mar_plot_bathy(bathy,image=TRUE)}) is automatically plotted and the position of the belt transect is added.
#' @param ratio Logical. Should aspect ratio for the \code{wireframe} plotting function (package \code{lattice}) be computed (default is \code{FALSE}).
#' @param \dots Other arguments to be passed to \code{\link{locator}} and \code{\link{lines}} to specify the characteristics of the points and lines to draw on the bathymetric map for both the transect and the bounding box of belt transect.
#'
#' @details
#' \code{mar_get_box} allows the user to get depth data for a rectangle area of the map around an approximate linear transect (belt transect). Both the position and size of the belt transect are user defined. The position of the transect can be specified either by inputing start and stop coordinates, or by clicking on a map created with \code{mar_plot_bathy}. In its interactive mode, this function uses the \code{locator} function (\code{\link{graphics}} package) to retrieve and plot the coordinates of the selected transect. The argument \code{width} allows the user to specify the width of the belt transect in degrees.
#'
#' @return
#' A matrix containing depth values for the belt transect. \code{rownames} indicate the kilometric distance from the start of the transect and \code{colnames} indicate the distance form the central transect in degrees.
#' If \code{ratio=TRUE}, a list of two elements: \code{depth}, a matrix containing depth values for the belt transect similar to the description above and \code{ratios} a vector of length two specifying the ratio between (i) the width and length of the belt transect and (ii) the depth range and the length of the belt transect. These ratios can be used by the function \code{wireframe} to produce realistic 3D bathymetric plots of the selected belt transect.
#'
#' @author
#' Benoit Simon-Bouhet and Eric Pante
#'
#' @seealso
#' \code{\link{mar_plot_bathy}}, \code{\link{mar_get_transect}}, \code{\link{mar_get_depth}}
#'
#' @examples
#' # load and plot bathymetry
#' 	data(hawaii)
#' 	plot(hawaii,im=TRUE)
#'
#' # get the depth matrix for a belt transect
#' 	depth <- mar_get_box(hawaii,x1=-157,y1=20,x2=-155.5,y2=21,width=0.5,col=2)
#'
#' # plotting a 3D bathymetric map of the belt transect
#' 	require(lattice)
#' 	wireframe(depth,shade=TRUE)
#'
#' # get the depth matrix for a belt transect with realistic aspect ratios
#' 	depth <- mar_get_box(hawaii,x1=-157,y1=20,x2=-155.5,y2=21,width=0.5,col=2,ratio=TRUE)
#'
#' # plotting a 3D bathymetric map of the belt transect with realistic aspect ratios
#' 	require(lattice)
#' 	wireframe(depth[[1]],shade=TRUE,aspect=depth[[2]])
#' @export
#' @aliases get.box
mar_get_box <- function(bathy,x1,x2,y1,y2,width,locator=FALSE,ratio=FALSE,...) {

  if (!is(bathy, "bathy")) stop("The matrix provided is not of class bathy")
	if (width<=0) stop("Width must be a positive number")
	if (!locator & (missing(x1)|missing(x2)|missing(y1)|missing(y2))) stop("You need to either use locator=TRUE or specify values for x1, x2, y1 and y2")

	as.numeric(rownames(bathy)) -> lon
	as.numeric(colnames(bathy)) -> lat

	if (locator) {
		pts <- locator(n=2,type="o",...)
		if (length(pts$x) == 1) stop("Please choose two points from the map")
		x1 <- pts$x[1]
		x2 <- pts$x[2]
		y1 <- pts$y[1]
		y2 <- pts$y[2]
	}

	alpha <- -atan((x2-x1)/(y2-y1))

	p1.x <- x1 + cos(alpha)*width/2
	p2.x <- x2 + cos(alpha)*width/2
	p3.x <- x2 - cos(alpha)*width/2
	p4.x <- x1 - cos(alpha)*width/2

	p1.y <- y1 + sin(alpha)*width/2
	p2.y <- y2 + sin(alpha)*width/2
	p3.y <- y2 - sin(alpha)*width/2
	p4.y <- y1 - sin(alpha)*width/2

	which.min(abs(lon-p1.x)) -> p1x
	which.min(abs(lat-p1.y)) -> p1y
	which.min(abs(lon-p4.x)) -> p4x
	which.min(abs(lat-p4.y)) -> p4y

	which.min(abs(lon-p2.x)) -> p2x
	which.min(abs(lat-p2.y)) -> p2y
	which.min(abs(lon-p3.x)) -> p3x
	which.min(abs(lat-p3.y)) -> p3y

	if (p1x==p4x | p1y==p4y) {
		coord1 <- matrix(as.vector(bathy[p1x:p4x, p1y:p4y]),ncol=length(p1y:p4y),nrow=length(p1x:p4x),dimnames=list(lon[p1x:p4x],lat[p1y:p4y]))
		coord1 <- cbind(as.numeric(dimnames(coord1)[[1]]),as.numeric(dimnames(coord1)[[2]]))
	} else {
		coord1 <- mar_diag_bathy(bathy[p1x:p4x,p1y:p4y],coord=TRUE)
	}

	if (p2x==p3x | p2y==p3y) {
		coord2 <- matrix(as.vector(bathy[p2x:p3x, p2y:p3y]),ncol=length(p2y:p3y),nrow=length(p2x:p3x),dimnames=list(lon[p2x:p3x],lat[p2y:p3y]))
		coord2 <- cbind(as.numeric(dimnames(coord2)[[1]]),as.numeric(dimnames(coord2)[[2]]))
	} else {
		coord2 <- mar_diag_bathy(bathy[p2x:p3x,p2y:p3y],coord=TRUE)
	}

	n1 <- nrow(coord1)
	n2 <- nrow(coord2)
	if (n1<n2) coord2 <- coord2[1:nrow(coord1),]
	if (n1>n2) coord1 <- coord1[1:nrow(coord2),]
	tr <- cbind(coord1,coord2)

	out <- apply(tr,1,function(x) mar_get_transect(x1=x[1],x2=x[3],y1=x[2],y2=x[4],mat=bathy,distance=TRUE))

	di <- round(out[[1]][,3],2)
	prof <- sapply(out,function(x) x[,4])

	if (is.list(prof)) {
		nr <- sapply(prof,length)
		prof <- sapply(prof, function(x) x<-x[1:min(nr)])
	}

	rownames(prof) <- round(di[1:nrow(prof)])
	colnames(prof) <- round(seq(from=-width/2,to=width/2,len=min(n1,n2)),2)

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

	d <- max(as.numeric(rownames(prof)))
	pmax <- -min(prof)/1000
	w <- deg2km(p1.x,p1.y,p4.x,p4.y)
	ratios <- round(c(w/d,pmax/d),3)

	if (!locator) # plot(bathy,im=TRUE)
	lines(c(x1,x2),c(y1,y2),type="o",...)
	lines(c(p1.x,p2.x,p3.x,p4.x,p1.x),c(p1.y,p2.y,p3.y,p4.y,p1.y),...)

	if (ratio) return(list(depth=prof,ratios=ratios)) else return(prof)
}

#' @rdname mar_get_box
#' @export
get.box <- mar_get_box
