bathy_to_spatraster <- function(x, crs = "EPSG:4326") {
  if (!inherits(x, "bathy")) {
    stop("x must inherit from class 'bathy'.", call. = FALSE)
  }
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("Package 'terra' is required.", call. = FALSE)
  }

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

as_terra_bathy <- bathy_to_spatraster
