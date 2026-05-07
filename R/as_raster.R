#' Convert bathymetric data to a raster layer
#'
#' @description
#' Transforms an object of class \code{bathy} to a raster layer.
#'
#' @rdname as_raster
#' @usage
#' as_raster(bathy)
#' @param bathy an object of class \code{bathy}
#'
#' @details
#' \code{as_raster} transforms \code{bathy} objects into objects of class \code{RasterLayer} as defined in the \code{raster} package. All methods from the \code{raster} package are thus available for bathymetric data (e.g. rotations, projections...).
#'
#' @return
#' An object of class \code{RasterLayer} with the same characteristics as the \code{bathy} object (same longitudinal and latitudinal ranges, same resolution).
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{as_xyz}}, \code{\link{as_bathy}}, \code{\link{as_spatial_grid_data_frame}}
#'
#' @examples
#' # load Hawaii bathymetric data
#' data(hawaii)
#'
#' # use as_raster
#' r.hawaii <- as_raster(hawaii)
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
as_raster <- function(bathy) {
	
	if (!is(bathy,"bathy")) stop("Objet is not of class bathy")

	lat <- as.numeric(colnames(bathy))
	lon <- as.numeric(rownames(bathy))

	r <- raster::raster(ncol = nrow(bathy), nrow = ncol(bathy), xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat))
	raster::values(r) <- as.vector(bathy[,rev(1:ncol(bathy))])

	return(r)

}

