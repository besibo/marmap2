#' Reduce the spatial resolution of bathymetric data
#'
#' @description
#' Reduces the spatial resolution of a regular bathymetric grid stored as a
#' tibble/data frame or as an historical \code{bathy} object. This is intended
#' for workflows where high-resolution data, for example data returned by
#' \code{\link{get_gebco}}, are downloaded once and then aggregated locally at
#' coarser resolutions.
#'
#' @param x A data frame/tibble with longitude, latitude, and depth columns, or
#'   an object inheriting from class \code{bathy}.
#' @param resolution Target grid spacing in arc-minutes. The value must be a
#'   single positive number. If \code{resolution} is finer than or equal to the
#'   current grid spacing, \code{x} is returned unchanged and an informative
#'   message is emitted.
#' @param method Reduction method. \code{"nearest"} keeps the native cell
#'   closest to each target cell centre and is the default. \code{"mean"}
#'   averages all values in each output cell, and \code{"median"} uses their
#'   median.
#'
#' @return
#' An object of the same type as \code{x}: a tibble for tibble input, a data
#' frame for data-frame input, or a \code{bathy} object for \code{bathy} input.
#'
#' @details
#' \code{resolution} is expressed in arc-minutes, like in
#' \code{\link{get_noaa}}. The function assumes that the input coordinates are
#' longitude/latitude coordinates in decimal degrees and that the input
#' represents a regular grid.
#'
#' \code{method = "nearest"} preserves original cell values exactly. Use
#' \code{method = "mean"} or \code{method = "median"} to aggregate all native
#' cells falling within each coarser output cell.
#'
#' @seealso
#' \code{\link{get_gebco}}, \code{\link{get_noaa}},
#' \code{\link{bathy_to_tbl}}, \code{\link{tbl_to_bathy}},
#' \code{\link{geom_bathy}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(seq(-5, -4, by = 0.25 / 60), each = 241),
#'   lat = rep(seq(48, 49, by = 0.25 / 60), times = 241),
#'   depth = seq_len(241 * 241)
#' )
#'
#' coarse <- reduce_bathy_resolution(xyz, resolution = 5)
#' coarse
#' @export
reduce_bathy_resolution <- function(
    x,
    resolution,
    method = c("nearest", "mean", "median")
) {
  method <- match.arg(method)

  if (!is.numeric(resolution) || length(resolution) != 1 ||
      is.na(resolution) || !is.finite(resolution) || resolution <= 0) {
    stop("resolution must be a single positive numeric value.", call. = FALSE)
  }

  input_is_bathy <- inherits(x, "bathy")
  if (input_is_bathy) {
    bathy <- x
  } else {
    if (!is.data.frame(x)) {
      stop("x must be a data frame/tibble or an object of class 'bathy'.", call. = FALSE)
    }
    if (!all(c("lon", "lat", "depth") %in% names(x))) {
      stop("x must contain columns named lon, lat, and depth.", call. = FALSE)
    }
    bathy <- tbl_to_bathy(x)
  }

  current_resolution <- bathy_current_resolution(bathy)
  if (resolution <= current_resolution) {
    message(
      "Requested resolution is finer than or equal to the current grid ",
      "resolution; returning input unchanged."
    )
    return(x)
  }

  reduced <- reduce_bathy_matrix(bathy, resolution = resolution, method = method)

  if (input_is_bathy) {
    return(reduced)
  }

  reduced_tbl <- bathy_to_tbl(reduced)
  if (inherits(x, "tbl_df")) {
    return(reduced_tbl)
  }
  as.data.frame(reduced_tbl)
}

reduce_bathy_matrix <- function(x, resolution, method) {
  if (!inherits(x, "bathy")) {
    stop("x must inherit from class 'bathy'.", call. = FALSE)
  }

  lon <- suppressWarnings(as.numeric(rownames(x)))
  lat <- suppressWarnings(as.numeric(colnames(x)))
  if (anyNA(lon) || anyNA(lat) || length(lon) < 2 || length(lat) < 2) {
    stop("x must be a regular bathy grid with numeric longitude and latitude names.", call. = FALSE)
  }

  if (identical(method, "nearest")) {
    return(reduce_bathy_matrix_nearest(x, resolution = resolution))
  }

  xyz <- bathy_to_tbl(x)
  step <- resolution / 60
  lon_min <- min(xyz$lon, na.rm = TRUE)
  lon_max <- max(xyz$lon, na.rm = TRUE)
  lat_min <- min(xyz$lat, na.rm = TRUE)
  lat_max <- max(xyz$lat, na.rm = TRUE)
  n_lon_bins <- bathy_n_bins(lon_min, lon_max, step)
  n_lat_bins <- bathy_n_bins(lat_min, lat_max, step)
  lon_bin <- pmin(floor((xyz$lon - lon_min) / step), n_lon_bins - 1)
  lat_bin <- pmin(floor((xyz$lat - lat_min) / step), n_lat_bins - 1)

  aggregate_fun <- switch(
    method,
    mean = function(value) {
      if (all(is.na(value))) NA_real_ else mean(value, na.rm = TRUE)
    },
    median = function(value) {
      if (all(is.na(value))) NA_real_ else stats::median(value, na.rm = TRUE)
    }
  )

  reduced <- stats::aggregate(
    xyz$depth,
    by = list(lon_bin = lon_bin, lat_bin = lat_bin),
    FUN = aggregate_fun
  )
  names(reduced)[3] <- "depth"
  reduced$lon <- if (n_lon_bins == 1) {
    mean(c(lon_min, lon_max))
  } else {
    lon_min + (reduced$lon_bin + 0.5) * step
  }
  reduced$lat <- if (n_lat_bins == 1) {
    mean(c(lat_min, lat_max))
  } else {
    lat_min + (reduced$lat_bin + 0.5) * step
  }
  reduced <- reduced[order(reduced$lon, reduced$lat), c("lon", "lat", "depth")]

  as_bathy(reduced)
}

reduce_bathy_matrix_nearest <- function(x, resolution) {
  lon <- as.numeric(rownames(x))
  lat <- as.numeric(colnames(x))
  lon_target <- bathy_target_axis(lon, resolution)
  lat_target <- bathy_target_axis(lat, resolution)
  lon_index <- vapply(lon_target, function(value) which.min(abs(lon - value)), integer(1))
  lat_index <- vapply(lat_target, function(value) which.min(abs(lat - value)), integer(1))
  lon_keep <- !duplicated(lon_index)
  lat_keep <- !duplicated(lat_index)
  lon_index <- lon_index[lon_keep]
  lat_index <- lat_index[lat_keep]
  lon_target <- lon_target[lon_keep]
  lat_target <- lat_target[lat_keep]

  reduced <- x[lon_index, lat_index, drop = FALSE]
  rownames(reduced) <- lon_target
  colnames(reduced) <- lat_target
  class(reduced) <- "bathy"
  reduced
}

bathy_n_bins <- function(lower, upper, step) {
  max(1, floor(((upper - lower) / step) + sqrt(.Machine$double.eps)))
}

bathy_current_resolution <- function(x) {
  lon <- suppressWarnings(as.numeric(rownames(x)))
  lat <- suppressWarnings(as.numeric(colnames(x)))
  if (anyNA(lon) || anyNA(lat) || length(lon) < 2 || length(lat) < 2) {
    stop("x must be a regular bathy grid with numeric longitude and latitude names.", call. = FALSE)
  }

  current_resolution <- max(
    stats::median(abs(diff(sort(unique(lon)))), na.rm = TRUE),
    stats::median(abs(diff(sort(unique(lat)))), na.rm = TRUE)
  ) * 60

  if (!is.finite(current_resolution) || current_resolution <= 0) {
    stop("The current grid resolution cannot be determined.", call. = FALSE)
  }

  current_resolution
}

bathy_target_axis <- function(x, resolution) {
  step <- resolution / 60
  lower <- min(x, na.rm = TRUE)
  upper <- max(x, na.rm = TRUE)
  target <- seq(lower + step / 2, upper - step / 2, by = step)
  if (length(target) == 0) {
    target <- mean(c(lower, upper))
  }
  target
}
