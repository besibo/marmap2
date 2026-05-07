#' Fill a grid with irregularly spaced data
#'
#' @description
#' Transforms irregularly spaced xyz data into a raster object suitable to create a bathy object with regularly spaced longitudes and latitudes.
#'
#' @rdname griddify
#' @usage
#' griddify(xyz, nlon, nlat)
#' @param xyz 3-column matrix or data.frame containing (in this order) arbitrary longitude, latitude and altitude/depth values.
#' @param nlon integer. The number of unique regularly-spaced longitude values that will be used to create the grid.
#' @param nlat integer. The number of unique regularly-spaced latitude values that will be used to create the grid.
#'
#' @details
#' \code{griddify} takes anys dataset with irregularly spaced xyz data and transforms it into a raster object (i.e. a grid) with user specified dimensions. \code{griddify} relies on several functions from the \code{raster} package, especially \code{rasterize} and \code{resample}.
#' If a cell of the user-defined grig does not contain any depth/altitude value in the original xyz matrix/data.frame, a \code{NA} is added in that cell. A bilinear interpolation is then applied in order to fill in most of the missing cells. For cells of the user-defined grig containing more than one depth/altitude value in the original xyz matrix/data.frame, the mean depth/altitude value is computed.
#'
#' @return
#' The output of \code{griddify} is an object of class \code{raster}, with \code{nlon} unique longitude values and \code{nlat} unique latitude values.
#'
#' @references
#' Robert J. Hijmans (2015). raster: Geographic Data Analysis and Modeling. R package version 2.4-20. \url{https://CRAN.R-project.org/package=raster}
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{read_bathy}}, \code{\link{read_gebco_bathy}}, \code{\link{plot_bathy}}
#'
#' @examples
#' # load irregularly spaced xyz data
#' data(irregular)
#' head(irregular)
#'
#' # use griddify to create a 40x60 grid
#' reg <- griddify(irregular, nlon = 40, nlat = 60)
#'
#' # switch to class "bathy"
#' class(reg)
#' bat <- as_bathy(reg)
#' summary(bat)
#'
#' # Plot the new bathy object and overlay the original data points
#' plot(bat, image = TRUE, lwd = 0.1)
#' points(irregular$lon, irregular$lat, pch = 19, cex = 0.3, col = color_to_alpha(3))
#' @export
griddify <- function(xyz, nlon, nlat) {
    
	
	if (ncol(xyz) != 3) stop("xyz must be a 3-column matrix or data.frame of longitudes, latitudes and depths/altitudes")
	
    colnames(xyz) <- c("lon", "lat", "depth")
    
    r <- raster::raster(xmn = min(xyz$lon, na.rm = TRUE),
                        xmx = max(xyz$lon, na.rm = TRUE),
                        ymn = min(xyz$lat, na.rm = TRUE),
                        ymx = max(xyz$lat, na.rm = TRUE), ncol = nlon, nrow = nlat)
    
    x <- raster::rasterize(xyz[, c("lon", "lat")], r, xyz$depth, fun = mean)
    
    s <- raster::raster(nrow = nlat, ncol = nlon)
    raster::extent(s) <- raster::extent(x)
    s <- raster::resample(x, s, method='bilinear')
    
    return(s)
}

