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
#' The use of \code{as_bathy} and \code{as_xyz} allows to swicth back and forth between the long format (xyz) and the wide format of class \code{bathy} suitable for plotting bathymetric maps, computing least cost distances, etc. \code{as_xyz} is especially usefull for exporting xyz files when data are obtained using \code{subset_sql}, i.e. bathymetric matrices of class \code{bathy}.
#'
#' @return
#' Three-column data.frame with a format similar to xyz files downloaded from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}). The first column contains longitude data, the second contains latitude data and the third contains depth/elevation data.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{as_bathy}}, \code{\link{summary_bathy}}
#'
#' @examples
#' # load celt data
#' data(celt)
#' dim(celt)
#' class(celt)
#' summary(celt)
#' plot(celt,deep= -300,shallow= -25,step=25)
#'
#' # use as_xyz
#' celt2 <- as_xyz(celt)
#' dim(celt2)
#' class(celt2)
#' summary(celt2)
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

