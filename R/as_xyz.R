#' Convert to xyz format
#'
#' @description
#' Converts a matrix of class \code{bathy} into a three-column data.frame containing longitude, latitude and depth data.
#'
#' @rdname as_xyz
#' @usage
#' as_xyz(bathy)
#' @param bathy matrix of class \code{bathy}.
#'
#' @details
#' The use of \code{as_bathy} and \code{as_xyz} allows switching back and forth
#' between the long xyz format and the historical matrix format of class
#' \code{bathy}.
#'
#' @return
#' Three-column data.frame with a format similar to xyz files downloaded from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}). The first column contains longitude data, the second contains latitude data and the third contains depth/elevation data.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{as_bathy}}, \code{\link{bathy_to_tbl}},
#' \code{\link{tbl_to_bathy}}, \code{\link{summary_bathy}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' bathy <- as_bathy(xyz)
#' as_xyz(bathy)
#' @export
as_xyz <- function(bathy) {

	if (!is(bathy, "bathy")) stop("Objet is not of class bathy")

	lon <- as.numeric(rownames(bathy))
	lat <- as.numeric(colnames(bathy))

	xyz <- data.frame(expand.grid(lon,lat),as.vector(bathy))
	xyz <- xyz[order(xyz[,2], decreasing=TRUE),]
	names(xyz) <- c("V1","V2","V3")
	rownames(xyz) <- 1:nrow(xyz)

	return(xyz)
}
