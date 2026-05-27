#' Summarise bathymetric data
#'
#' @description
#' Returns a compact one-row summary of bathymetric data stored as a tibble/data
#' frame with \code{lon}, \code{lat}, and \code{depth} columns, or as an
#' historical \code{bathy} object.
#'
#' @param x A data frame/tibble with columns \code{lon}, \code{lat}, and
#'   \code{depth}, or an object inheriting from class \code{bathy}.
#' @param \dots Reserved for future use.
#'
#' @return
#' A one-row tibble with class \code{bathy_summary}. It contains the input
#' classes, grid dimensions, geographic bounding box, grid resolution in
#' arc-minutes, depth/elevation statistics, number of missing values, and object
#' size in memory. A compact print method is provided for interactive use.
#'
#' @seealso
#' \code{\link{get_gebco}}, \code{\link{get_noaa}},
#' \code{\link{geom_bathy}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' summarise_bathy(xyz)
#' summarise_bathy(as_bathy(xyz))
#' @export
summarise_bathy <- function(x, ...) {
  UseMethod("summarise_bathy")
}

#' @export
summarise_bathy.bathy <- function(x, ...) {
  summarise_bathy_data(
    x = x,
    xyz = bathy_to_tbl(x),
    n_lon = nrow(x),
    n_lat = ncol(x)
  )
}

#' @export
summarise_bathy.data.frame <- function(x, ...) {
  if (!all(c("lon", "lat", "depth") %in% names(x))) {
    stop("x must contain columns named lon, lat, and depth.", call. = FALSE)
  }
  if (!is.numeric(x$lon) || !is.numeric(x$lat) || !is.numeric(x$depth)) {
    stop("lon, lat, and depth columns must be numeric.", call. = FALSE)
  }

  summarise_bathy_data(
    x = x,
    xyz = x[, c("lon", "lat", "depth")],
    n_lon = length(unique(x$lon)),
    n_lat = length(unique(x$lat))
  )
}

#' @export
summarise_bathy.default <- function(x, ...) {
  stop("x must be a data frame/tibble or an object of class 'bathy'.", call. = FALSE)
}

summarise_bathy_data <- function(x, xyz, n_lon, n_lat) {
  depth <- xyz$depth
  finite_depth <- depth[is.finite(depth)]

  out <- tibble::tibble(
    class = paste(class(x), collapse = "/"),
    n_cells = nrow(xyz),
    n_lon = n_lon,
    n_lat = n_lat,
    lon_min = min(xyz$lon, na.rm = TRUE),
    lon_max = max(xyz$lon, na.rm = TRUE),
    lat_min = min(xyz$lat, na.rm = TRUE),
    lat_max = max(xyz$lat, na.rm = TRUE),
    resolution_lon = bathy_resolution_minutes(xyz$lon),
    resolution_lat = bathy_resolution_minutes(xyz$lat),
    resolution_unit = "arc-minutes",
    depth_min = if (length(finite_depth)) min(finite_depth) else NA_real_,
    depth_max = if (length(finite_depth)) max(finite_depth) else NA_real_,
    depth_mean = if (length(finite_depth)) mean(finite_depth) else NA_real_,
    depth_median = if (length(finite_depth)) stats::median(finite_depth) else NA_real_,
    n_na = sum(is.na(depth)),
    memory = format(utils::object.size(x), units = "auto")
  )

  class(out) <- c("bathy_summary", class(out))
  out
}

bathy_resolution_minutes <- function(x) {
  dx <- diff(sort(unique(x)))
  dx <- dx[is.finite(dx) & dx > 0]
  if (!length(dx)) {
    return(NA_real_)
  }
  stats::median(dx) * 60
}

#' @export
print.bathy_summary <- function(x, ...) {
  row <- x[1, , drop = FALSE]
  fmt_num <- function(value, digits = 4) {
    if (is.na(value)) {
      return("NA")
    }
    format(signif(value, digits), trim = TRUE, scientific = FALSE)
  }
  fmt_lon <- function(value) {
    if (is.na(value)) {
      return("NA")
    }
    lon <- ifelse(value > 180, value - 360, value)
    if (lon == 0) {
      return("0")
    }
    suffix <- ifelse(lon < 0, "W", "E")
    paste0(fmt_num(abs(lon)), " ", suffix)
  }
  fmt_lat <- function(value) {
    if (is.na(value)) {
      return("NA")
    }
    if (value == 0) {
      return("0")
    }
    suffix <- ifelse(value < 0, "S", "N")
    paste0(fmt_num(abs(value)), " ", suffix)
  }

  cat("Bathymetric data summary\n")
  cat("  Class:      ", row$class, "\n", sep = "")
  cat("  Dimensions: ", row$n_lon, " longitude x ", row$n_lat,
      " latitude (", row$n_cells, " cells)\n", sep = "")
  cat("  Longitude:  ", fmt_lon(row$lon_min), " to ", fmt_lon(row$lon_max), "\n", sep = "")
  cat("  Latitude:   ", fmt_lat(row$lat_min), " to ", fmt_lat(row$lat_max), "\n", sep = "")
  cat("  Resolution: ", fmt_num(row$resolution_lon), " x ",
      fmt_num(row$resolution_lat), " arc-minutes\n", sep = "")
  cat("  Depth:      ", fmt_num(row$depth_min), " to ", fmt_num(row$depth_max),
      " (mean ", fmt_num(row$depth_mean), ", median ",
      fmt_num(row$depth_median), ")\n", sep = "")
  cat("  Missing:    ", row$n_na, "\n", sep = "")
  cat("  Memory:     ", row$memory, "\n", sep = "")

  invisible(x)
}
