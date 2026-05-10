#' Get a composite buffer in a format suitable for plotting its outline
#'
#' @description
#' Get a buffer (i.e. a non-circular buffer as produced by \code{combine_buffers()}) in a format suitable for plotting its outline. \code{outline_buffer()} replaces any \code{NA} values in a \code{buffer} or \code{bathy} object by 0 and non-\code{NA} values by -1.
#'
#' @rdname outline_buffer
#' @usage
#' outline_buffer(buffer)
#' @param buffer a buffer object of class \code{bathy} (i.e. \code{bathy} matrix containing depth/altitude values within the buffer and \code{NA}s outside)
#'
#' @details
#' This function is essentially used to prepare a composite buffer for plotting its outline on a bathymetric map. Plotting a single circular buffer should be done using the \code{plot_buffer()} function since it offers a more straightforward method for plotting and much smoother outlines, especially for low-resolution bathymetries.
#'
#' @return
#' An object of class \code{bathy} of the same dimensions as \code{buffer} containing only zeros (outside the buffer area) and -1 values (within the buffer).
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
#' plot(florida, n = 1, lwd = 0.7, add = TRUE)
#'
#' # add points around which a buffer will be computed
#' loc <- data.frame(c(-80,-82), c(26,24))
#' points(loc, pch = 19, col = "red")
#'
#' # create 2 distinct buffer objects with different radii
#' buf1 <- create_buffer(florida, loc[1,], radius=1.9)
#' buf2 <- create_buffer(florida, loc[2,], radius=1.2)
#'
#' # combine both buffers
#' buf <- combine_buffers(buf1,buf2)
#'
#' \dontrun{
#' # Add outline of the resulting buffer in red
#' # and the outline of the original buffers in blue
#' plot(outline_buffer(buf), lwd = 3, col = 2, add=TRUE)
#' plot(buf1, lwd = 0.5, fg="blue")
#' plot(buf2, lwd = 0.5, fg="blue")
#' }
#' @export
outline_buffer <- function(buffer) {
  if (!is(buffer,'bathy')) stop("'buffer' must be a buffer of class bathy")
  buffer[!is.na(buffer)] <- -1
  buffer[is.na(buffer)] <- 0
  return(buffer)
}

