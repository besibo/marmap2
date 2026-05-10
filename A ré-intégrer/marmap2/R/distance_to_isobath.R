#' Computes the shortest great circle distance between any point and a given isobath
#'
#' @description
#' Computes the shortest (great circle) distance between a set of points and an isoline of depth or altitude. Points can be selected interactively by clicking on a map.
#'
#' @rdname distance_to_isobath
#' @usage
#' distance_to_isobath(mat, x, y=NULL, isobath=0, locator=FALSE, \dots)
#' @param mat Bathymetric data matrix of class \code{bathy}, as imported with \code{read_bathy}.
#' @param x Either a list of two elements (numeric vectors of longitude and latitude), a 2-column matrix or data.frame of longitudes and latitudes, or a numeric vector of longitudes.
#' @param y Either \code{NULL} (default) or a numerical vector of latitudes. Ignored if \code{x} is not a numeric vector.
#' @param isobath A single numerical value indicating the isobath to which the shortest distance is to be computed (default is set to 0, \emph{i.e.} the coastline).
#' @param locator Logical. Whether to choose data points interactively with a map or not. If \code{TRUE}, a bathymetric map must have been plotted and both \code{x} and \code{y} are both ignored.
#' @param ... Further arguments to be passed to \code{locator} when the interactive mode is used (\code{locator=TRUE}).
#'
#' @details
#' \code{distance_to_isobath} allows the user to compute the shortest great circle distance between a set of points (selected interactively on a map or not) and a user-defined isobath. \code{distance_to_isobath} takes advantage of functions from packages \code{sp} (\code{Lines()} and \code{SpatialLines()}) and \code{geosphere} (\code{dist2Line}) to compute the coordinates of the nearest location along a given isobath for each point provided by the user.
#'
#' @return
#' A 5-column data.frame. The first column contains the distance in meters between each point and the nearest point located on the given \code{isobath}. Columns 2 and 3 indicate the longitude and latitude of starting points (\emph{i.e.} either coordinates provided as \code{x} and \code{y} or coordinates of points selected interactively on a map when \code{locator=TRUE}) and columns 4 and 5 contains coordinates (longitudes and latitudes) arrival points \emph{i.e.} the nearest points on the \code{isobath}.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{lines_gc}}, \code{\link{least_cost_distance}}
#'
#' @examples
#' # Load NW Atlantic data and convert to class bathy
#' data(nw.atlantic)
#' atl <- as_bathy(nw.atlantic)
#'
#' # Create vectors of latitude and longitude
#' lon <- c(-70, -65, -63, -55, -48)
#' lat <- c(33, 35, 40, 37, 33)
#'
#' # Compute distances between each point and the -200m isobath
#' d <- distance_to_isobath(atl, lon, lat, isobath = -200)
#' d
#'
#' # Visualize the great circle distances
#' blues <- c("lightsteelblue4","lightsteelblue3","lightsteelblue2","lightsteelblue1")
#' plot(atl, image=TRUE, lwd=0.1, land=TRUE, bpal = list(c(0,max(atl),"grey"), c(min(atl),0,blues)))
#' plot(atl, deep=-200, shallow=-200, step=0, lwd=0.6, add=TRUE)
#' points(lon,lat, pch=21, col="orange4", bg="orange2", cex=.8)
#' lines_gc(d[2:3],d[4:5])
#' @export
distance_to_isobath <- function(mat, x, y=NULL, isobath=0, locator=FALSE, ...) {

	if (!is(mat,"bathy")) stop("'mat' must be of class 'bathy'")

	if (!is.numeric(isobath)) stop("'isobath' must be numeric")
	if (length(isobath) >1) {
		isobath <- isobath[1]
		warning("'isobath' must be a single depth or altitude value. Only the first value was used.")
	}

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

	coord <- data.frame(x = coord$x, y = coord$y)

	# Get contour lines for a given isobath
	lon <- unique(as.numeric(rownames(mat)))
	lat <- unique(as.numeric(colnames(mat)))
	iso <- contourLines(lon, lat, mat, levels = isobath)

	# Transform the list from contourLines into a SpatialLines
	iso <- lapply(iso, function(k) sp::Line(matrix(c(k$x,k$y),ncol=2)))
	iso <- sp::SpatialLines(list(sp::Lines(iso, ID = "a")))

	# Compute the shortest great circle distance between each point and the isobath
	d <- suppressWarnings(geosphere::dist2Line(coord,iso))

	d <- data.frame(d[,1],coord,d[,2:3])
	colnames(d) <- c("distance", "start.lon", "start.lat", "end.lon", "end.lat")
	return(d)
}

