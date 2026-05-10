#' Convert bathymetric data to a terra SpatRaster
#'
#' @description
#' Converts bathymetric data stored as a long table or as a historical
#' \code{bathy} matrix to a modern \code{terra::SpatRaster}.
#'
#' @param x A data frame/tibble with longitude, latitude, and depth columns, or
#'   an object inheriting from class \code{bathy}.
#' @param crs Coordinate reference system assigned to the returned raster.
#'   Can be a CRS string such as \code{"EPSG:4326"}, or a numeric EPSG code
#'   such as \code{4326}. Defaults to \code{"EPSG:4326"}.
#' @param lon,lat,depth Column names used when \code{x} is a data frame/tibble.
#'
#' @return
#' A \code{terra::SpatRaster} object.
#'
#' @details
#' For tabular input, \code{x} must represent a complete regular grid. The first
#' two coordinate columns are interpreted as cell centres. For \code{bathy}
#' input, row names are interpreted as longitude and column names as latitude.
#'
#' @examples
#' if (requireNamespace("terra", quietly = TRUE)) {
#'   xyz <- data.frame(
#'     lon = rep(c(-5, -4, -3), each = 3),
#'     lat = rep(c(48, 49, 50), times = 3),
#'     depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#'   )
#'
#'   r <- as_spatraster(xyz)
#' }
#' @export
as_spatraster <- function(x, crs = "EPSG:4326", lon = "lon", lat = "lat", depth = "depth") {
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("Package 'terra' is required.", call. = FALSE)
  }
  crs <- normalize_bathy_crs(crs, "crs")

  if (inherits(x, "bathy")) {
    return(bathy_matrix_to_spatraster(x, crs = crs))
  }

  if (!is.data.frame(x)) {
    stop("x must be a data.frame/tibble or an object of class 'bathy'.", call. = FALSE)
  }

  cols <- c(lon, lat, depth)
  if (!is.character(cols) || length(cols) != 3 || anyNA(cols) || any(!nzchar(cols))) {
    stop("lon, lat, and depth must be column names.", call. = FALSE)
  }
  if (!all(cols %in% names(x))) {
    stop("x must contain columns named by lon, lat, and depth.", call. = FALSE)
  }
  if (!is.numeric(x[[lon]]) || !is.numeric(x[[lat]]) || !is.numeric(x[[depth]])) {
    stop("Longitude, latitude, and depth columns must be numeric.", call. = FALSE)
  }

  xyz <- data.frame(
    x = x[[lon]],
    y = x[[lat]],
    depth = x[[depth]]
  )
  r <- terra::rast(xyz, type = "xyz", crs = crs)
  names(r) <- depth
  r
}

bathy_matrix_to_spatraster <- function(x, crs = "EPSG:4326") {
  if (!inherits(x, "bathy")) {
    stop("x must inherit from class 'bathy'.", call. = FALSE)
  }
  crs <- normalize_bathy_crs(crs, "crs")

  m <- unclass(x)
  if (!is.matrix(m)) {
    m <- as.matrix(m)
  }

  lon <- suppressWarnings(as.numeric(rownames(m)))
  lat <- suppressWarnings(as.numeric(colnames(m)))

  if (anyNA(lon) || length(lon) != nrow(m)) {
    stop("Longitudes are unreadable: bathy row names must be numeric.", call. = FALSE)
  }
  if (anyNA(lat) || length(lat) != ncol(m)) {
    stop("Latitudes are unreadable: bathy column names must be numeric.", call. = FALSE)
  }

  dx <- stats::median(abs(diff(lon)))
  dy <- stats::median(abs(diff(lat)))
  if (!is.finite(dx) || dx == 0 || !is.finite(dy) || dy == 0) {
    stop("Invalid bathy grid resolution.", call. = FALSE)
  }

  r <- terra::rast(t(m))
  terra::ext(r) <- terra::ext(
    min(lon) - dx / 2,
    max(lon) + dx / 2,
    min(lat) - dy / 2,
    max(lat) + dy / 2
  )
  terra::crs(r) <- crs

  if (lat[1] < lat[length(lat)]) {
    r <- terra::flip(r, "vertical")
  }
  if (lon[1] > lon[length(lon)]) {
    r <- terra::flip(r, "horizontal")
  }

  r
}

normalize_bathy_crs <- function(crs, arg = "crs") {
  if (is.numeric(crs) && length(crs) == 1 && is.finite(crs)) {
    if (crs != round(crs)) {
      stop(arg, " must be a CRS string or a whole-number EPSG code.", call. = FALSE)
    }
    return(paste0("EPSG:", as.integer(crs)))
  }

  if (is.character(crs) && length(crs) == 1 && !is.na(crs) && nzchar(crs)) {
    return(crs)
  }

  stop(arg, " must be a CRS string or a numeric EPSG code.", call. = FALSE)
}
