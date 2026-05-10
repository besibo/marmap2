#' Convert to bathymetric data in an object of class bathy
#'
#' @description
#' Converts a three-column data frame containing longitude, latitude and depth
#' values to a matrix of class \code{bathy}.
#'
#' @rdname as_bathy
#' @usage
#' as_bathy(x)
#' @param x Three-column data frame with longitude, latitude and depth values.
#'
#' @details
#' The first column is interpreted as longitude, the second as latitude, and
#' the third as depth or elevation.
#'
#' @return
#' The output of \code{as_bathy} is a matrix of class \code{bathy}, with
#' longitude stored in row names and latitude stored in column names.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{summary_bathy}}, \code{\link{read_bathy}},
#' \code{\link{as_xyz}}, \code{\link{bathy_to_tbl}}, \code{\link{tbl_to_bathy}}.
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' bathy <- as_bathy(xyz)
#' class(bathy)
#' summary(bathy)
#' @export
as_bathy <- function(x){

	if (is(x,"bathy")) stop("Object is already of class 'bathy'")

	if (is(x,"SpatialGridDataFrame")) x <- raster::raster(x)

	# if x is a RasterLayer do this
	if (is(x,"RasterLayer")) {
		lat.min <- x@extent@xmin
		lat.max <- x@extent@xmax
		lon.min <- x@extent@ymin
		lon.max <- x@extent@ymax
		
		nlat <- x@ncols
		nlon <- x@nrows
		
		lon <- seq(lon.min, lon.max, length.out = nlon)
		lat <- seq(lat.min, lat.max, length.out = nlat)
		
		bathy <- t(raster::as.matrix(raster::flip(x,direction="y")))
		colnames(bathy) <- lon
		rownames(bathy) <- lat
	}
	
	# if not, it has to be a 3-column table (xyz format)
	if (ncol(x)==3 & !exists("bathy", inherits=FALSE)) {
		bath <- x
	    bath <- bath[order(bath[, 2], bath[, 1], decreasing = FALSE), ]

	    lat <- unique(bath[, 2]) ; bcol <- length(lat)
	    lon <- unique(bath[, 1]) ; brow <- length(lon)

		if ((bcol*brow) == nrow(bath)) {
			bathy <- matrix(bath[, 3], nrow = brow, ncol = bcol, byrow = FALSE, dimnames = list(lon, lat))
			} else {
				colnames(bath) <- paste("V",1:3,sep="")
				bathy <- reshape2::acast(bath, V1~V2, value.var="V3")
			}
	}

	if (!exists("bathy", inherits=FALSE)) stop("as_bathy requires a 3-column table, or an object of class RasterLayer or SpatialDataFrame")

	ordered.mat <- check_bathy(bathy)
	class(ordered.mat) <- "bathy"
	return(ordered.mat)

}
