#' Convert to bathymetric data in an object of class bathy
#'
#' @description
#' Reads either an object of class \code{RasterLayer}, \code{SpatialGridDataFrame} or a three-column data.frame containing longitude (x), latitude (y) and depth (z) data and converts it to a matrix of class bathy.
#'
#' @rdname as_bathy
#' @usage
#' as_bathy(x)
#' @param x Object of \code{RasterLayer} or \code{SpatialGridDataFrame}, or a three-column data.frame with longitude (x), latitude (y) and depth (z) (no default)
#'
#' @details
#' \code{x} can contain data downloaded from the NOAA GEODAS Grid Translator webpage (http://www.ngdc.noaa.gov/mgg/gdas/gd_designagrid.html) in the form of an xyz table. The function \code{as_bathy} can also be used to transform objects of class \code{raster} (see package \code{raster}) and \code{SpatialGridDataFrame} (see package \code{sp}).
#'
#' @return
#' The output of \code{as_bathy} is a matrix of class \code{bathy}, which dimensions and resolution are identical to the original object. The class \code{bathy} has its own methods for summarizing and ploting the data.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{summary_bathy}}, \code{\link{plot_bathy}}, \code{\link{read_bathy}}, \code{\link{as_xyz}}, \code{\link{as_raster}}, \code{\link{as_spatial_grid_data_frame}}.
#'
#' @examples
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # use as_bathy
#' atl <- as_bathy(nw.atlantic)
#'
#' # class "bathy"
#' class(atl)
#'
#' # summarize data of class "bathy"
#' summary(atl)
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

