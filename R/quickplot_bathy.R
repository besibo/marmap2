#' Quickly plot bathymetric data
#'
#' @description
#' `quickplot_bathy()` creates a simple bathymetric/topographic map from a
#' tibble/data frame or a historical `bathy` object, with sensible defaults for most situations. It is intended for quick
#' visual checks after downloading data with \code{\link{get_noaa}} or
#' \code{\link{get_gebco}}.
#'
#' @param x A data frame/tibble with longitude, latitude, and depth columns, or
#'   an object inheriting from class `bathy`.
#' @param lon,lat,depth Character. Names of the longitude, latitude, and depth
#'   columns when `x` is a data frame/tibble.
#' @param ocean_breaks,land_breaks Numeric vectors giving contour breaks for
#'   ocean depths and land elevations.
#' @param contour_colour,contour_linewidth Colour and linewidth used for
#'   bathymetric/topographic contour lines.
#' @param coastline_colour,coastline_linewidth Colour and linewidth used for
#'   the coastline.
#' @param palette_ocean,palette_land Palettes passed to
#'   \code{\link{scale_fill_bathy}}.
#' @param expand Logical or character vector passed to \code{\link{geom_bathy}}.
#'   Defaults to \code{FALSE} to remove padding around the downloaded grid.
#' @param theme ggplot2 theme added to the plot. Defaults to
#'   \code{\link[ggplot2:theme_bw]{ggplot2::theme_bw}}.
#' @param ... Additional arguments passed to \code{\link{geom_bathy}}.
#'
#' @return A ggplot object.
#'
#' @seealso
#' \code{\link{geom_bathy}}, \code{\link{geom_coastline}},
#' \code{\link{scale_fill_bathy}}
#'
#' @examples
#' \dontrun{
#' dat <- get_gebco(lon = c(2, 7), lat = c(42, 44))
#' quickplot_bathy(dat)
#' }
#' @export
quickplot_bathy <- function(
  x,
  lon = "lon",
  lat = "lat",
  depth = "depth",
  ocean_breaks = seq(0, -6000, by = -500),
  land_breaks = seq(0, 2500, by = 500),
  contour_colour = "grey20",
  contour_linewidth = 0.2,
  coastline_colour = "black",
  coastline_linewidth = 0.4,
  palette_ocean = "ocean_blues",
  palette_land = "land_hcl",
  expand = FALSE,
  theme = ggplot2::theme_bw(),
  ...
) {
  data <- quickplot_bathy_data(x, lon = lon, lat = lat, depth = depth)
  mapping <- ggplot2::aes(
    x = !!rlang::sym(lon),
    y = !!rlang::sym(lat),
    fill = !!rlang::sym(depth)
  )
  contour_mapping <- ggplot2::aes(
    x = !!rlang::sym(lon),
    y = !!rlang::sym(lat),
    z = !!rlang::sym(depth)
  )

  ggplot2::ggplot(data) +
    geom_bathy(
      mapping,
      expand = expand,
      lon = lon,
      lat = lat,
      depth = depth,
      ...
    ) +
    geom_coastline(
      lon = lon,
      lat = lat,
      depth = depth,
      colour = coastline_colour,
      linewidth = coastline_linewidth
    ) +
    ggplot2::geom_contour(
      contour_mapping,
      breaks = ocean_breaks,
      colour = contour_colour,
      linewidth = contour_linewidth
    ) +
    ggplot2::geom_contour(
      contour_mapping,
      breaks = land_breaks,
      colour = contour_colour,
      linewidth = contour_linewidth
    ) +
    scale_fill_bathy(
      palette_ocean = palette_ocean,
      palette_land = palette_land
    ) +
    theme
}

quickplot_bathy_data <- function(x, lon = "lon", lat = "lat", depth = "depth") {
  if (inherits(x, "bathy")) {
    out <- bathy_to_tbl(x, names = c(lon, lat, depth))
    return(out)
  }

  if (!is.data.frame(x)) {
    stop(
      "x must be a data.frame/tibble or an object of class 'bathy'.",
      call. = FALSE
    )
  }

  cols <- c(lon, lat, depth)
  if (
    !is.character(cols) ||
      length(cols) != 3 ||
      anyNA(cols) ||
      any(!nzchar(cols))
  ) {
    stop("lon, lat, and depth must be column names.", call. = FALSE)
  }
  if (!all(cols %in% names(x))) {
    stop("x must contain columns named by lon, lat, and depth.", call. = FALSE)
  }
  x
}
