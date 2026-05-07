#' Create a buffer of specified radius around one or several points
#'
#' @description
#' Create a circular buffer of user-defined radius around one or several points defined by their longitudes and latitudes.
#'
#' @rdname create_buffer
#' @usage
#' create_buffer(x, loc, radius, km = FALSE)
#' @param x an object of class \code{bathy}
#' @param loc a 2-column \code{data.frame} of longitudes and latitudes for points around which the buffer is to be created.
#' @param radius \code{numeric}. Radius of the buffer in the same unit as the \code{bathy} object (i.e. usually decimal degrees) when \code{km=FALSE} (default) or in kilometers when \code{radius=TRUE}.
#' @param km \code{logical}. If \code{TRUE}, the \code{radius} should be provided in kilometers. When \code{FALSE} (default) the radius is in the same unit as the \code{bathy} object (i.e. usually decimal degrees).
#'
#' @details
#' This function takes advantage of the \code{buffer} function from package \code{adehabitatMA} and several functions from packages \code{sp} to define the buffer around the points provided by the user.
#'
#' @return
#' An object of class \code{bathy} of the same size as \code{mat} containing only \code{NA}s outside of the buffer and values of depth/altitude (taken from \code{mat}) within the buffer.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{outline_buffer}}, \code{\link{combine_buffers}}, \code{\link{plot_bathy}}
#'
#' @examples
#' # load and plot a bathymetry
#' data(florida)
#' plot(florida, lwd = 0.2)
#' plot(florida, n = 1, lwd = 0.7, add = TRUE)
#'
#' # add a point around which a buffer will be created
#' loc <- data.frame(-80, 26)
#' points(loc, pch = 19, col = "red")
#'
#' # compute and print buffer
#' buf <- create_buffer(florida, loc, radius=1.5)
#' buf
#'
#' # highlight isobath with the buffer and add outline
#' plot(buf, outline=FALSE, n = 10, col = 2, lwd=.4)
#' plot(buf, lwd = 0.7, fg = 2)
#' @export
create_buffer <- function(x, loc, radius, km=FALSE){
	
	mat <- x # S3 compatibility
	
	if (!is(mat,"bathy")) stop("x must be an object of class bathy")
	if (!is.data.frame(loc)) stop("loc must be a two-column data.frame (longitude and latitude)")
	if (!is.numeric(radius)) stop("radius must be numeric")
	if (length(radius) > 1) warning("only the first value of radius was used")
	
	xyz <- as_xyz(mat)
	
	if (km) {
		radius.km <- radius
		radius <- 180 * radius.km/(pi*6372.798)
	} else {
		radius.km <- radius*pi*6372.798/180
	}
	
	map <- sp::SpatialPixelsDataFrame(points = xyz[,1:2], data = xyz, tolerance = 0.006)
    lo2 <- sp::SpatialPointsDataFrame(loc, data = loc)
	
	adehabitatMA::adeoptions(epsilon=0.001)
	temp <- adehabitatMA::buffer(lo2, map, radius)
	adehabitatMA::adeoptions(epsilon=0.00000001)
		
	temp <- -as_bathy(as(temp,'SpatialGridDataFrame'))
	
	mat[temp==0] <- NA

	out <- list(buffer = mat, center = loc, radius = radius, radius.km = radius.km)
	class(out) <- "buffer"
	return(out)
	
}

