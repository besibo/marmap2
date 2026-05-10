#' Creates bathy objects from larger bathy objects
#'
#' @description
#' Generates rectangular or non rectangular \code{bathy} objects by extracting bathymetric data from larger \code{bathy} objects.
#'
#' @rdname subset_bathy
#' @usage
#' subset_bathy(mat, x, y=NULL, locator=TRUE, \dots)
#' @param mat Bathymetric data matrix of class \code{bathy}, as imported with \code{read_bathy}.
#' @param x Either a list of two elements (numeric vectors of longitude and latitude), a 2-column matrix or data.frame of longitudes and latitudes, or a numeric vector of longitudes.
#' @param y Either \code{NULL} (default) or a numerical vector of latitudes. Ignored if \code{x} is not a numeric vector.
#' @param locator Logical. Whether to choose data points interactively with a map or not. If \code{TRUE} (default), a bathymetric map must have been plotted and both \code{x} and \code{y} are both ignored.
#' @param ... Further arguments to be passed to \code{locator} when the interactive mode is used (\code{locator=TRUE}).
#'
#' @details
#' \code{subset_bathy} allows the user to generate new \code{bathy} objects by extracting data from larger \code{bathy} objects. The extraction of bathymetric data can be done interactively by clicking on a bathymetric map, or by providing longitudes and latitudes for the boundaries for the new \code{bathy} object. If two data points are provided, a rectangular area is selected. If more than two points are provided, a polygon is defined by linking the points and the bathymetic data is extracted within the polygon only. \code{subset_bathy} relies on the \code{point.in.polygon} function from package \code{sp} to identify which points of the initial bathy matrix lie witin the boundaries of the user-defined polygon.
#'
#' @return
#' A matrix of class \code{bathy}.
#'
#' @references
#' Pebesma, EJ, RS Bivand, (2005). Classes and methods for spatial data in R. R News 5 (2), \url{https://cran.r-project.org/doc/Rnews/}
#'
#' Bivand RS, Pebesma EJ, Gomez-Rubio V (2013). Applied spatial data analysis with R, Second edition. Springer, NY. \url{https://asdar-book.org}
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{plot_bathy}}, \code{\link{get_depth}}, \code{\link{summary_bathy}}, \code{\link{aleutians}}
#'
#' @examples
#' # load aleutians dataset
#' data(aleutians)
#'
#' # create vectors of latitude and longitude to define the boundary of a polygon
#' lon <- c(188.56, 189.71, 191, 193.18, 196.18, 196.32, 196.32, 194.34, 188.83)
#' lat <- c(54.33, 55.88, 56.06, 55.85, 55.23, 54.19, 52.01, 50.52, 51.71)
#'
#'
#' # plot the initial bathy and overlay the polygon
#' plot(aleutians, image=TRUE, land=TRUE, lwd=.2)
#' polygon(lon,lat)
#'
#' # Use of subset_bathy to extract the new bathy object
#' zoomed <- subset_bathy(aleutians, x=lon, y=lat, locator=FALSE)
#'
#' # plot the new bathy object
#' dev.new() ; plot(zoomed, land=TRUE, image=TRUE, lwd=.2)
#'
#' # alternativeley once the map is plotted, use the interactive mode:
#' \dontrun{
#' plot(aleutians, image=TRUE, land=TRUE, lwd=.2)
#' zoomed2 <- subset_bathy(aleutians, pch=19, col=3)
#' dev.new() ; plot(zoomed2, land=TRUE, image=TRUE, lwd=.2)
#' }
#' # click several times and press Escape
#' @export
subset_bathy <- function(mat, x, y=NULL, locator=TRUE, ...) {

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
			message('Waiting for interactive input: click any number of times on the map')
			coord <- locator(type="o",...)
		}

		as.numeric(rownames(mat)) -> lon
		as.numeric(colnames(mat)) -> lat

		outside.lon <- any(findInterval(coord$x,range(lon),rightmost.closed=TRUE) != 1)
		outside.lat <- any(findInterval(coord$y,range(lat),rightmost.closed=TRUE) != 1)
		if (outside.lon | outside.lat) stop("Some data points are oustide the range of mat")

		out <- data.frame(Lon=coord$x, Lat=coord$y)

		if (nrow(out)==1) stop("'subset.bathy' needs at least two points")

		if (nrow(out)==2) {
			try(rect(min(out$Lon),min(out$Lat),max(out$Lon),max(out$Lat)),silent=TRUE)
			x1 <- which(abs(lon-out$Lon[1])==min(abs(lon-out$Lon[1])))
			y1 <- which(abs(lat-out$Lat[1])==min(abs(lat-out$Lat[1])))
			x2 <- which(abs(lon-out$Lon[2])==min(abs(lon-out$Lon[2])))
			y2 <- which(abs(lat-out$Lat[2])==min(abs(lat-out$Lat[2])))
			new.bathy <- mat[x1:x2, y1:y2]
			new.bathy <- check_bathy(new.bathy)
			class(new.bathy) <- "bathy"

		}

		if (nrow(out)>2) {
			x1 <- which(abs(lon-min(out$Lon))==min(abs(lon-min(out$Lon))))
			y1 <- which(abs(lat-min(out$Lat))==min(abs(lat-min(out$Lat))))
			x2 <- which(abs(lon-max(out$Lon))==min(abs(lon-max(out$Lon))))
			y2 <- which(abs(lat-max(out$Lat))==min(abs(lat-max(out$Lat))))
			new.bathy <- mat[x1:x2, y1:y2]
			new.bathy <- check_bathy(new.bathy)
			class(new.bathy) <- "bathy"

			xyz <- as.matrix(as_xyz(new.bathy))
			out <- as.matrix(out)
			inside <- sp::point.in.polygon(xyz[,1],xyz[,2],out[,1],out[,2])
			xyz[inside==0,3] <- NA
			new.bathy <- as_bathy(xyz)
		}


		return(new.bathy)

}

