resolve_lon_lat_args <- function(lon1, lon2, lat1, lat2, lon, lat) {
  lon_args <- c(!is.null(lon1), !is.null(lon2))
  lat_args <- c(!is.null(lat1), !is.null(lat2))

  if (!is.null(lon) && any(lon_args)) {
    stop("Use either lon or lon1/lon2, not both.", call. = FALSE)
  }
  if (!is.null(lat) && any(lat_args)) {
    stop("Use either lat or lat1/lat2, not both.", call. = FALSE)
  }

  if (!is.null(lon)) {
    if (!is.numeric(lon) || length(lon) != 2 || anyNA(lon) || any(!is.finite(lon))) {
      stop("lon must be a numeric vector of length 2.", call. = FALSE)
    }
    lon1 <- lon[1]
    lon2 <- lon[2]
  } else if (!all(lon_args)) {
    stop("Provide either lon or both lon1 and lon2.", call. = FALSE)
  }

  if (!is.null(lat)) {
    if (!is.numeric(lat) || length(lat) != 2 || anyNA(lat) || any(!is.finite(lat))) {
      stop("lat must be a numeric vector of length 2.", call. = FALSE)
    }
    lat1 <- lat[1]
    lat2 <- lat[2]
  } else if (!all(lat_args)) {
    stop("Provide either lat or both lat1 and lat2.", call. = FALSE)
  }

  list(lon1 = lon1, lon2 = lon2, lat1 = lat1, lat2 = lat2)
}

regular_gebco_axis <- function(x, lower, upper, resolution) {
  if (length(x) <= 2 || resolution <= 0.25) {
    return(list(index = seq_along(x), values = x))
  }
  step <- stats::median(abs(diff(sort(unique(x)))), na.rm = TRUE) * 60
  if (!is.finite(step) || step <= 0) {
    return(list(index = seq_along(x), values = x))
  }
  target_step <- resolution / 60
  target <- seq(lower + target_step / 2, upper - target_step / 2, by = target_step)
  if (length(target) == 0) {
    target <- mean(c(lower, upper))
  }
  index <- vapply(target, function(value) which.min(abs(x - value)), integer(1))
  keep <- !duplicated(index)
  list(index = index[keep], values = target[keep])
}
