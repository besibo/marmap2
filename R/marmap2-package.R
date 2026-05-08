#' Import, plot and analyze bathymetric and topographic data
#'
#' @description
#' marmap2 is an experimental modernization of marmap, a package designed for downloading, plotting and manipulating bathymetric and topographic data in R. It can query the ETOPO 2022 bathymetry and topography database hosted by the NOAA, use simple latitude-longitude-depth data in ascii format, and take advantage of the advanced plotting tools available in R to build publication-quality bathymetric maps. Functions to query data (bathymetry, sampling information, etc...) are available interactively by clicking on marmap maps. Bathymetric and topographic data can also be used to calculate projected surface areas within specified depth/altitude intervals, and constrain the calculation of realistic shortest path distances.
#'
#' @name marmap2-package
#' @docType package
#'
#' @details
#' \tabular{ll}{
#' Package: \tab marmap2\cr
#' Type: \tab Package\cr
#' Version: \tab 0.0.0.9000\cr
#' }
#' Import, plot and analyze bathymetric and topographic data
#'
#' @references
#' Pante E, Simon-Bouhet B (2013) marmap: A Package for Importing, Plotting and Analyzing Bathymetric and Topographic Data in R. PLoS ONE 8(9): e73051. doi:10.1371/journal.pone.0073051
#'
#' @author
#' Eric Pante, Benoit Simon-Bouhet and Jean-Olivier Irisson
#'
#' Maintainer: Benoit Simon-Bouhet <besibo@gmail.com>
#' @importFrom adehabitatMA buffer adeoptions
#' @importFrom DBI dbConnect dbWriteTable dbSendQuery fetch dbClearResult dbDisconnect dbListFields
#' @importFrom gdistance costDistance shortestPath geoCorrection transition
#' @importFrom ggplot2 aes aes_string geom_tile ggplot scale_x_continuous scale_y_continuous geom_raster geom_contour coord_quickmap coord_map scale_fill_gradientn scale_colour_gradientn
#' @importFrom grDevices as.graphicsAnnot col2rgb colorRampPalette contourLines dev.new rgb xy.coords
#' @importFrom graphics abline arrows axis box contour image lines locator par plot polygon rect segments strheight strwidth symbols text
#' @importFrom methods as is
#' @importFrom ncdf4 nc_open ncvar_get
#' @importFrom raster raster rasterize extent resample
#' @importFrom reshape2 acast
#' @importFrom RSQLite SQLite
#' @importFrom shape colorlegend
#' @importFrom sp SpatialPixelsDataFrame SpatialPointsDataFrame
#' @importFrom stats na.omit runif
#' @importFrom utils combn read.table setTxtProgressBar txtProgressBar write.table download.file
"_PACKAGE"
