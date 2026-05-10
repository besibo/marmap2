#' marmap2: Import, Plot, and Analyze Bathymetric and Topographic Data
#'
#' marmap2 is an experimental modernization of marmap, a package designed for
#' downloading, converting, and plotting bathymetric and topographic data in R.
#'
#' The current development version focuses on a compact modern core:
#' NOAA/GEBCO import, tibble-based workflows, conversion helpers, `sf`/`terra`
#' interoperability, and `ggplot2`-based bathymetric maps.
#'
#' @section Reference:
#' Pante E, Simon-Bouhet B (2013). marmap: A Package for Importing, Plotting
#' and Analyzing Bathymetric and Topographic Data in R. *PLoS ONE*, 8(9),
#' e73051. \doi{10.1371/journal.pone.0073051}.
#'
#' @keywords internal
#'
#' @importFrom ggplot2 ggplot_add
#' @importFrom methods is
#' @importFrom utils download.file read.table write.table
"_PACKAGE"
