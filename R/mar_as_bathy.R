#' Convert to bathymetric data in an object of class bathy
#'
#' @description
#' Reads either an object of class \code{RasterLayer}, \code{SpatialGridDataFrame} or a three-column data.frame containing longitude (x), latitude (y) and depth (z) data and converts it to a matrix of class bathy.
#'
#' @rdname mar_as_bathy
#' @usage
#' mar_as_bathy(x)
#' @param x Object of \code{RasterLayer} or \code{SpatialGridDataFrame}, or a three-column data.frame with longitude (x), latitude (y) and depth (z) (no default)
#'
#' @details
#' \code{x} can contain data downloaded from the NOAA GEODAS Grid Translator webpage (http://www.ngdc.noaa.gov/mgg/gdas/gd_designagrid.html) in the form of an xyz table. The function \code{mar_as_bathy} can also be used to transform objects of class \code{raster} (see package \code{raster}) and \code{SpatialGridDataFrame} (see package \code{sp}).
#'
#' @return
#' The output of \code{mar_as_bathy} is a matrix of class \code{bathy}, which dimensions and resolution are identical to the original object. The class \code{bathy} has its own methods for summarizing and ploting the data.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_summary_bathy}}, \code{\link{mar_plot_bathy}}, \code{\link{mar_read_bathy}}, \code{\link{mar_as_xyz}}, \code{\link{mar_as_raster}}, \code{\link{mar_as_spatial_grid_data_frame}}.
#'
#' @examples
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # use mar_as_bathy
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' # class "bathy"
#' class(atl)
#'
#' # summarize data of class "bathy"
#' summary(atl)
#' @export
#' @aliases as.bathy
mar_as_bathy <- function(x){

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

	if (!exists("bathy", inherits=FALSE)) stop("mar_as_bathy requires a 3-column table, or an object of class RasterLayer or SpatialDataFrame")

	ordered.mat <- mar_check_bathy(bathy)
	class(ordered.mat) <- "bathy"
	return(ordered.mat)

}

#' @rdname mar_as_bathy
#' @export
as.bathy <- mar_as_bathy
