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
#' classes, coordinate type, grid dimensions, coordinate bounds, geographic
#' bounding box when available, grid resolution, depth/elevation statistics,
#' number of missing values, and object size in memory. A compact print method
#' is provided for interactive use.
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
  projected <- is_projected_bathy(x)
  crs <- bathy_summary_crs(x, projected)
  crs_unit <- bathy_summary_crs_unit(crs)
  geographic_bbox <- bathy_summary_geographic_bbox(x, xyz, crs, projected)
  resolution_x <- bathy_resolution(xyz$lon)
  resolution_y <- bathy_resolution(xyz$lat)

  out <- tibble::tibble(
    class = paste(class(x), collapse = "/"),
    coord_type = if (projected) "projected" else "geographic",
    crs = crs,
    crs_unit = crs_unit,
    n_cells = nrow(xyz),
    n_lon = n_lon,
    n_lat = n_lat,
    x_min = min(xyz$lon, na.rm = TRUE),
    x_max = max(xyz$lon, na.rm = TRUE),
    y_min = min(xyz$lat, na.rm = TRUE),
    y_max = max(xyz$lat, na.rm = TRUE),
    lon_min = unname(geographic_bbox["lon_min"]),
    lon_max = unname(geographic_bbox["lon_max"]),
    lat_min = unname(geographic_bbox["lat_min"]),
    lat_max = unname(geographic_bbox["lat_max"]),
    resolution_x = resolution_x,
    resolution_y = resolution_y,
    resolution_lon = if (projected) NA_real_ else resolution_x * 60,
    resolution_lat = if (projected) NA_real_ else resolution_y * 60,
    resolution_unit = if (projected) crs_unit else "arc-minutes",
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

bathy_resolution <- function(x) {
  dx <- diff(sort(unique(x)))
  dx <- dx[is.finite(dx) & dx > 0]
  if (!length(dx)) {
    return(NA_real_)
  }
  stats::median(dx)
}

is_projected_bathy <- function(x) {
  inherits(x, "projected_bathy") || !is.null(attr(x, "crs_to", exact = TRUE))
}

bathy_summary_crs <- function(x, projected) {
  if (!projected) {
    return("EPSG:4326")
  }

  crs <- attr(x, "crs_to", exact = TRUE)
  if (is.null(crs) || !length(crs) || is.na(crs)) {
    return(NA_character_)
  }
  crs <- sf::st_crs(crs)
  if (!is.na(crs$epsg)) {
    return(paste0("EPSG:", crs$epsg))
  }
  if (!is.na(crs$input) && nzchar(crs$input)) {
    return(crs$input)
  }
  crs$wkt
}

bathy_summary_crs_unit <- function(crs) {
  if (is.na(crs)) {
    return(NA_character_)
  }

  unit <- sf::st_crs(crs)$units_gdal
  if (is.null(unit) || is.na(unit) || !nzchar(unit)) {
    return(NA_character_)
  }
  if (unit %in% c("metre", "meter")) {
    return("m")
  }
  unit
}

bathy_summary_geographic_bbox <- function(x, xyz, crs, projected) {
  fallback <- c(
    lon_min = NA_real_,
    lon_max = NA_real_,
    lat_min = NA_real_,
    lat_max = NA_real_
  )

  if (!projected) {
    return(c(
      lon_min = min(xyz$lon, na.rm = TRUE),
      lon_max = max(xyz$lon, na.rm = TRUE),
      lat_min = min(xyz$lat, na.rm = TRUE),
      lat_max = max(xyz$lat, na.rm = TRUE)
    ))
  }
  if (is.na(crs)) {
    return(fallback)
  }

  bbox <- try(
    sf::st_bbox(
      c(
        xmin = min(xyz$lon, na.rm = TRUE),
        xmax = max(xyz$lon, na.rm = TRUE),
        ymin = min(xyz$lat, na.rm = TRUE),
        ymax = max(xyz$lat, na.rm = TRUE)
      ),
      crs = sf::st_crs(crs)
    ),
    silent = TRUE
  )
  if (inherits(bbox, "try-error")) {
    return(fallback)
  }

  geographic <- try(
    sf::st_bbox(sf::st_transform(sf::st_as_sfc(bbox), 4326)),
    silent = TRUE
  )
  if (inherits(geographic, "try-error")) {
    return(fallback)
  }
  c(
    lon_min = unname(geographic["xmin"]),
    lon_max = unname(geographic["xmax"]),
    lat_min = unname(geographic["ymin"]),
    lat_max = unname(geographic["ymax"])
  )
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

  if (identical(row$coord_type, "projected")) {
    cat("Bathymetric data summary\n")
    cat("  Class:      ", row$class, "\n", sep = "")
    cat("  CRS:        ", ifelse(is.na(row$crs), "unknown", row$crs), "\n", sep = "")
    cat("  Dimensions: ", row$n_lon, " x ", row$n_lat,
        " cells (", row$n_cells, " cells)\n", sep = "")
    cat("  X range:    ", fmt_num(row$x_min), " to ", fmt_num(row$x_max),
        bathy_summary_unit_suffix(row$crs_unit), "\n", sep = "")
    cat("  Y range:    ", fmt_num(row$y_min), " to ", fmt_num(row$y_max),
        bathy_summary_unit_suffix(row$crs_unit), "\n", sep = "")
    cat("  Resolution: ", fmt_num(row$resolution_x), " x ",
        fmt_num(row$resolution_y), bathy_summary_unit_suffix(row$resolution_unit), "\n", sep = "")
    if (!any(is.na(c(row$lon_min, row$lon_max, row$lat_min, row$lat_max)))) {
      cat("  Geographic: ", fmt_lon(row$lon_min), " to ", fmt_lon(row$lon_max),
          ", ", fmt_lat(row$lat_min), " to ", fmt_lat(row$lat_max), "\n", sep = "")
    }
    cat("  Depth:      ", fmt_num(row$depth_min), " to ", fmt_num(row$depth_max),
        " (mean ", fmt_num(row$depth_mean), ", median ",
        fmt_num(row$depth_median), ")\n", sep = "")
    cat("  Missing:    ", row$n_na, "\n", sep = "")
    cat("  Memory:     ", row$memory, "\n", sep = "")

    return(invisible(x))
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

bathy_summary_unit_suffix <- function(unit) {
  if (is.na(unit) || !nzchar(unit)) {
    return("")
  }
  paste0(" ", unit)
}
