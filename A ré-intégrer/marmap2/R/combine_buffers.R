#' Create a new, (non circular) composite buffer from a list of existing buffers.
#'
#' @description
#' Creates a new bathy object from a list of existing buffers of compatible dimensions.
#'
#' @rdname combine_buffers
#' @usage
#' combine_buffers(...)
#' @param ... 2 or more buffer objects as produced by \code{\link{create_buffer}}. All \code{bathy} objects within the \code{buffer} objects must be compatible: they should have the same dimensions (same number of rows and columns) and cover the same area (same longitudes and latitudes).
#'
#' @return
#' An object of class \code{bathy} of the same dimensions as the original \code{bathy} objects contained within each \code{buffer} objects. The resulting \code{bathy} object contains only \code{NA}s outside of the combined buffer and values of depth/altitude inside the combined buffer.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{create_buffer}}, \code{\link{plot_buffer}}, \code{\link{plot_bathy}}
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
combine_buffers <- function(...) {
	
	buf <- list(...)
	
	if (length(buf) == 0) {
		stop("You must provide at least one 'buffer' object.\n")
	} else { 
		if (length(buf) == 1) {
			if (!is(buf[[1]],'buffer')) stop("combine_buffers needs at least one 'buffer' object as produced by create_buffer().\n")
			warning("You provided only one buffer object: ther's nothing to combine.\n You will only get a new bathy object...\n")
			return(buf[[1]])
		} else {
			
			if (!all(sapply(buf, function(x) is(x,"buffer")))) stop("At least one object is not of class 'buffer'. See create_buffer() to produce such objects.")
			if (any(apply(sapply(buf, function(x) dim(x[[1]])), 1, function(x) length(table(x))) != 1)) stop("All buffer objects provided must contain a bathy object of compatible caracteristics (identical dimensions and location)")

			buf <- lapply(buf, function(x) x[[1]])

			lon <- rownames(buf[[1]])
			lat <- colnames(buf[[1]])

			# Stack buffers in a new array
			buf <- array(as.vector(sapply(buf,as.vector)),dim=c(dim(buf[[1]]),length(buf)))

			# Apply element wise function : if all elements in a position are NA, leave it that way, otherwise leave the depth/altitude value
			res <- apply(buf, 1:2, function(x) ifelse(any(!is.na(x)),na.omit(x)[1],NA))
			rownames(res) <- lon
			colnames(res) <- lat

			class(res) <- "bathy"

			return(res)
		}
	
	}
	
}

