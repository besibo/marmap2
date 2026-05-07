#' Convert bathymetric data to a raster layer
#'
#' @description
#' Transforms an object of class \code{bathy} to a raster layer.
#'
#' @rdname mar_as_raster
#' @usage
#' mar_as_raster(bathy)
#' @param bathy an object of class \code{bathy}
#'
#' @details
#' \code{mar_as_raster} transforms \code{bathy} objects into objects of class \code{RasterLayer} as defined in the \code{raster} package. All methods from the \code{raster} package are thus available for bathymetric data (e.g. rotations, projections...).
#'
#' @return
#' An object of class \code{RasterLayer} with the same characteristics as the \code{bathy} object (same longitudinal and latitudinal ranges, same resolution).
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_as_xyz}}, \code{\link{mar_as_bathy}}, \code{\link{mar_as_spatial_grid_data_frame}}
#'
#' @examples
#' # load Hawaii bathymetric data
#' data(hawaii)
#'
#' # use mar_as_raster
#' r.hawaii <- mar_as_raster(hawaii)
#'
#' # class "RasterLayer"
#' class(r.hawaii)
#'
#' # Summaries
#' summary(hawaii)
#' summary(r.hawaii)
#'
#' # structure of the RasterLayer object
#' str(r.hawaii)
#'
#' \dontrun{
#' # Plots
#' #require(raster)
#' plot(hawaii,image=TRUE,lwd=.2)
#' plot(r.hawaii)
#' }
#' @export
#' @aliases as.raster
mar_as_raster <- function(bathy) {
	
	if (!is(bathy,"bathy")) stop("Objet is not of class bathy")

	lat <- as.numeric(colnames(bathy))
	lon <- as.numeric(rownames(bathy))

	r <- raster::raster(ncol = nrow(bathy), nrow = ncol(bathy), xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat))
	raster::values(r) <- as.vector(bathy[,rev(1:ncol(bathy))])

	return(r)

}

#' @rdname mar_as_raster
#' @export
as.raster <- mar_as_raster
