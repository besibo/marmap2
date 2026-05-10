#' Import, plot and analyze bathymetric and topographic data
#'
#' @description
#' marmap2 is an experimental modernization of marmap, a package designed for
#' downloading, converting and plotting bathymetric and topographic data in R.
#' This development version currently focuses on a compact modern core:
#' NOAA/GEBCO import, tibble-based workflows, conversion helpers, sf/terra
#' interoperability, and ggplot2-based bathymetric maps.
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
#' Import, convert and plot bathymetric and topographic data
#'
#' @references
#' Pante E, Simon-Bouhet B (2013) marmap: A Package for Importing, Plotting and Analyzing Bathymetric and Topographic Data in R. PLoS ONE 8(9): e73051. doi:10.1371/journal.pone.0073051
#'
#' @author
#' Eric Pante, Benoit Simon-Bouhet and Jean-Olivier Irisson
#'
#' Maintainer: Benoit Simon-Bouhet <besibo@gmail.com>
#' @importFrom ggplot2 ggplot_add
#' @importFrom methods is
#' @importFrom utils download.file read.table write.table
"_PACKAGE"
