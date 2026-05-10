#' Plots a circular buffer and or its outline
#'
#' @description
#' \code{plot_buffer} is a generic function that allows the plotting of objects of class \code{buffer}, either as new plots or as a new layer added on top of an existing one. The plotting of both the bathymetry/hypsometry as well as the outline of the buffer is possible.
#'
#' @rdname plot_buffer
#' @param x an object of class \code{buffer} as produced by the \code{create_buffer()} function.
#' @param outline Should the outline of the buffer be plotted (default) or the bathymetric/hypsometric data within the buffer.
#' @param add Should the plot be added on top of an existing bathymetric/hypsometric plot (default) or as a new plot
#' @param ... Further arguments to be passed to the \code{symbols()} function from the \code{graphics} package when \code{outline = TRUE} (default) or to \code{plot_bathy()} when \code{outline = FALSE}.
#'
#' @return
#' Either a plot of the outline of a buffer (default) or a bathymetric map with isobaths of a buffer when \code{outline = FALSE}
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{create_buffer}}, \code{\link{combine_buffers}}, \code{\link{plot_bathy}}
#'
#' @examples
#' # load and plot a bathymetry
#' data(florida)
#' plot(florida, lwd = 0.2)
#' plot(florida, n = 0, lwd = 0.7, add = TRUE)
#'
#' # add points around which a buffer will be computed
#' loc <- data.frame(-80, 26)
#' points(loc, pch = 19, col = "red")
#'
#' # compute buffer
#' buf <- create_buffer(florida, loc, radius=1.5)
#'
#' # plot buffer bathymetry
#' plot(buf, outline=FALSE, n=10, lwd=.5, col=2)
#'
#' # add buffer outline
#' plot(buf, lwd=.7, fg=2)
#' @name plot_buffer
NULL

#' @export
#' @noRd
plot.buffer <- function(x, outline = TRUE, add = TRUE, ...) {

	buffer <- x  # S3 compatibility

	if (!is(buffer,'buffer')) stop("'buffer' must be an object of class bathy as produced by create_buffer()")

	ll <- list(...)

	if (outline) {
		symbols(buffer[[2]], circles = buffer[[3]], add = add, inches = F, ...)
	} else {
		plot_bathy(buffer[[1]], add=add, ...)
	}

}

#' @rdname plot_buffer
#' @export
plot_buffer <- plot.buffer
