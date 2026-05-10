#' Project bathymetric grids
#'
#' @description
#' Projects bathymetric data to a destination coordinate reference system and
#' returns a tibble suitable for plotting with \code{\link{geom_bathy}}.
#'
#' @param x A data frame/tibble with longitude, latitude, and depth columns, or
#'   an object inheriting from class \code{bathy}.
#' @param crs_to Destination coordinate reference system. Can be a CRS string
#'   such as \code{"EPSG:3857"}, or a numeric EPSG code such as \code{3857}.
#'   Passed to \code{\link[terra:project]{terra::project}}.
#' @param crs_from Source coordinate reference system. Defaults to
#'   \code{"EPSG:4326"}. Can also be supplied as a numeric EPSG code such as
#'   \code{4326}.
#' @param resolution Optional output resolution in destination map units. If
#'   \code{NULL}, terra chooses a suitable resolution.
#' @param method Resampling method passed to
#'   \code{\link[terra:project]{terra::project}}. Use \code{"bilinear"} for
#'   continuous bathymetry/elevation values or \code{"near"} for nearest
#'   neighbour resampling.
#' @param lon,lat,depth Column names used when \code{x} is a data frame/tibble.
#' @param names Character vector of length 3 giving the names of the projected
#'   coordinate and depth columns in the returned tibble. Defaults to
#'   \code{c("lon", "lat", "depth")}.
#' @param na.rm Logical. If \code{TRUE}, cells with missing depth values are
#'   removed from the returned tibble.
#'
#' @return
#' A tibble with projected coordinates and depth values. The source CRS,
#' destination CRS, and projected \code{terra::SpatRaster} are stored in
#' attributes named \code{crs_from}, \code{crs_to}, and \code{spatraster}.
#'
#' @details
#' Projection of a regular longitude/latitude bathymetric grid generally
#' requires resampling. \code{project_bathy()} therefore converts the input to a
#' \code{terra::SpatRaster}, projects the raster with \code{terra::project()},
#' and converts the projected grid back to a long tibble. The output is not a
#' \code{bathy} object because projected coordinates are not longitude/latitude
#' row and column names.
#'
#' To plot the projected result with \code{geom_bathy()}, use
#' \code{coord = "fixed"} because the returned \code{lon} and \code{lat}
#' columns contain projected coordinates, not geographic longitude/latitude
#' values:
#'
#' \preformatted{
#' dat_proj |>
#'   ggplot2::ggplot() +
#'   geom_bathy(
#'     ggplot2::aes(lon, lat, fill = depth),
#'     coord = "fixed"
#'   ) +
#'   ggplot2::labs(x = "Easting", y = "Northing")
#' }
#'
#' @seealso
#' \code{\link{as_spatraster}}, \code{\link{geom_bathy}},
#' \code{\link[terra:project]{terra::project}}
#'
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   xyz <- data.frame(
#'     lon = rep(c(-5, -4, -3), each = 3),
#'     lat = rep(c(48, 49, 50), times = 3),
#'     depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#'   )
#'
#'   xyz_proj <- project_bathy(xyz, crs_to = 3857)
#'   head(xyz_proj)
#' }
#' @export
project_bathy <- function(
    x,
    crs_to,
    crs_from = "EPSG:4326",
    resolution = NULL,
    method = "bilinear",
    lon = "lon",
    lat = "lat",
    depth = "depth",
    names = c("lon", "lat", "depth"),
    na.rm = TRUE
) {
  if (missing(crs_to) || is.null(crs_to)) {
    stop("crs_to must be supplied.", call. = FALSE)
  }
  if (!is.character(names) || length(names) != 3 || anyNA(names) || any(!nzchar(names))) {
    stop("names must be a character vector of length 3.", call. = FALSE)
  }
  if (!is.null(resolution) &&
      (!is.numeric(resolution) || length(resolution) > 2 ||
        anyNA(resolution) || any(resolution <= 0))) {
    stop("resolution must be NULL or a positive numeric value of length 1 or 2.", call. = FALSE)
  }
  if (!is.character(method) || length(method) != 1 || is.na(method) || !nzchar(method)) {
    stop("method must be a single character string.", call. = FALSE)
  }
  if (!is.logical(na.rm) || length(na.rm) != 1 || is.na(na.rm)) {
    stop("na.rm must be TRUE or FALSE.", call. = FALSE)
  }
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("Package 'terra' is required.", call. = FALSE)
  }

  crs_from <- normalize_bathy_crs(crs_from, "crs_from")
  crs_to <- normalize_bathy_crs(crs_to, "crs_to")
  r <- as_spatraster(x, crs = crs_from, lon = lon, lat = lat, depth = depth)
  projected <- if (is.null(resolution)) {
    terra::project(r, crs_to, method = method)
  } else {
    terra::project(r, crs_to, res = resolution, method = method)
  }

  out <- terra::as.data.frame(projected, xy = TRUE, na.rm = na.rm)
  if (ncol(out) < 3) {
    stop("Projected raster did not produce x, y, and depth columns.", call. = FALSE)
  }
  out <- out[, seq_len(3), drop = FALSE]
  names(out) <- names
  out <- tibble::as_tibble(out)
  class(out) <- unique(c("projected_bathy", class(out)))
  attr(out, "crs_from") <- terra::crs(r)
  attr(out, "crs_to") <- terra::crs(projected)
  attr(out, "spatraster") <- projected
  out
}
