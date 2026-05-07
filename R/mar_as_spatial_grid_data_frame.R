#' Convert bathymetric data to a spatial grid
#'
#' @description
#' Transforms an object of class \code{bathy} to a \code{SpatialGridDataFrame} object.
#'
#' @rdname mar_as_spatial_grid_data_frame
#' @usage
#' mar_as_spatial_grid_data_frame(bathy)
#' @param bathy an object of class \code{bathy}
#'
#' @details
#' \code{mar_as_spatial_grid_data_frame} transforms \code{bathy} objects into objects of class \code{SpatialGridDataFrame} as defined in the \code{sp} package. All methods from the \code{sp} package are thus available for bathymetric data (e.g. rotations, projections...).
#'
#' @return
#' An object of class \code{SpatialGridDataFrame} with the same characteristics as the \code{bathy} object (same longitudinal and latitudinal ranges, same resolution).
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_as_xyz}}, \code{\link{mar_as_bathy}}, \code{\link{mar_as_raster}}
#'
#' @examples
#' # load Hawaii bathymetric data
#' data(hawaii)
#'
#' # use mar_as_spatial_grid_data_frame
#' sp.hawaii <- mar_as_spatial_grid_data_frame(hawaii)
#'
#' # Summaries
#' summary(hawaii)
#' summary(sp.hawaii)
#'
#' # structure of the SpatialGridDataFrame object
#' str(sp.hawaii)
#'
#' # Plots
#' plot(hawaii,image=TRUE,lwd=.2)
#' image(sp.hawaii)
#' @export
#' @aliases as.SpatialGridDataFrame
mar_as_spatial_grid_data_frame <- function(bathy) {
	
	out <- as(mar_as_raster(bathy), "SpatialGridDataFrame")
	return(out)
}

#' @rdname mar_as_spatial_grid_data_frame
#' @export
as.SpatialGridDataFrame <- mar_as_spatial_grid_data_frame
