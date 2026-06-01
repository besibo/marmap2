#' Grid irregularly spaced bathymetric data
#'
#' @description
#' `griddify()` converts irregularly spaced longitude/latitude/depth data to a
#' regular bathymetric grid. It is useful when external data are available as
#' scattered xyz points rather than as a regular raster-like grid.
#'
#' @param x A data frame/tibble with longitude, latitude, and depth columns, a
#'   three-column matrix, a point `sf` object, a `terra::SpatRaster`, or a
#'   historical `bathy` object.
#' @param nlon,nlat Integer. Number of longitude and latitude cells in the
#'   target grid.
#' @param lon,lat,depth Character. Names of the longitude, latitude, and depth
#'   columns when `x` is tabular.
#' @param crs Coordinate reference system assigned to the target grid. Can be a
#'   CRS string such as `"EPSG:4326"` or a numeric EPSG code such as `4326`.
#' @param interpolate Logical. If `TRUE`, empty target cells are filled where
#'   possible by inverse distance weighting from the input points.
#' @param radius Numeric. Search radius used for inverse distance weighting when
#'   `interpolate = TRUE`. If `NULL`, a radius based on the target cell size is
#'   used.
#' @param power Numeric. Distance weighting power passed to
#'   \code{\link[terra:interpIDW]{terra::interpIDW}}.
#' @param class Character. Output class. `"tbl"` returns a tibble with columns
#'   `lon`, `lat`, and `depth`; `"bathy"` returns a historical `bathy` matrix;
#'   `"spatraster"` returns a `terra::SpatRaster`.
#'
#' @return A tibble by default, or an object of class `bathy` or
#'   `terra::SpatRaster`.
#'
#' @details
#' Points falling in the same target cell are averaged. When
#' `interpolate = TRUE`, cells without observations are filled with inverse
#' distance weighting. This interpolation is intended as a pragmatic gridding
#' step for visualisation and exploratory mapping; it should not be interpreted
#' as a substitute for a domain-specific spatial interpolation model.
#'
#' @seealso
#' \code{\link{as_bathy}}, \code{\link{as_spatraster}},
#' \code{\link{geom_bathy}}, \code{\link{quickplot_bathy}}
#'
#' @examples
#' set.seed(1)
#' xyz <- data.frame(
#'   lon = runif(100, -5, -3),
#'   lat = runif(100, 47, 49),
#'   depth = rnorm(100, -100, 30)
#' )
#'
#' grid <- griddify(xyz, nlon = 30, nlat = 30)
#' summarise_bathy(grid)
#' @export
griddify <- function(
    x,
    nlon,
    nlat,
    lon = "lon",
    lat = "lat",
    depth = "depth",
    crs = 4326,
    interpolate = TRUE,
    radius = NULL,
    power = 2,
    class = c("tbl", "bathy", "spatraster")
) {
  output_class <- match.arg(class)
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("Package 'terra' is required.", call. = FALSE)
  }
  crs <- normalize_bathy_crs(crs, "crs")
  nlon <- griddify_dimension(nlon, "nlon")
  nlat <- griddify_dimension(nlat, "nlat")
  if (!is.logical(interpolate) || length(interpolate) != 1 || is.na(interpolate)) {
    stop("interpolate must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.numeric(power) || length(power) != 1 || !is.finite(power) || power <= 0) {
    stop("power must be a single positive number.", call. = FALSE)
  }

  xyz <- griddify_xyz(x, lon = lon, lat = lat, depth = depth)
  target <- terra::rast(
    xmin = min(xyz$lon),
    xmax = max(xyz$lon),
    ymin = min(xyz$lat),
    ymax = max(xyz$lat),
    ncols = nlon,
    nrows = nlat,
    crs = crs
  )
  points <- terra::vect(xyz, geom = c("lon", "lat"), crs = crs)
  grid <- terra::rasterize(points, target, field = "depth", fun = mean)
  names(grid) <- "depth"

  if (isTRUE(interpolate) && any(is.na(terra::values(grid, mat = FALSE)))) {
    if (is.null(radius)) {
      cell_size <- max(terra::res(grid))
      radius <- cell_size * 3
    }
    if (!is.numeric(radius) || length(radius) != 1 || !is.finite(radius) || radius <= 0) {
      stop("radius must be a single positive number.", call. = FALSE)
    }
    idw <- terra::interpIDW(
      target,
      as.matrix(xyz[, c("lon", "lat", "depth")]),
      radius = radius,
      power = power,
      fill = NA
    )
    names(idw) <- "depth"
    grid <- terra::cover(grid, idw)
    names(grid) <- "depth"
  }

  switch(
    output_class,
    tbl = spatraster_to_bathy_tbl(grid),
    bathy = as_bathy(grid),
    spatraster = grid
  )
}

griddify_dimension <- function(x, arg) {
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x) || x < 2 || x != round(x)) {
    stop(arg, " must be a single whole number greater than or equal to 2.", call. = FALSE)
  }
  as.integer(x)
}

griddify_xyz <- function(x, lon = "lon", lat = "lat", depth = "depth") {
  if (inherits(x, "bathy")) {
    x <- bathy_to_tbl(x)
  } else if (inherits(x, "SpatRaster")) {
    if (!requireNamespace("terra", quietly = TRUE)) {
      stop("Package 'terra' is required.", call. = FALSE)
    }
    x <- spatraster_to_bathy_tbl(x)
  } else if (inherits(x, "sf")) {
    if (!requireNamespace("sf", quietly = TRUE)) {
      stop("Package 'sf' is required.", call. = FALSE)
    }
    geom <- sf::st_geometry(x)
    if (!all(as.character(sf::st_geometry_type(geom)) %in% c("POINT", "MULTIPOINT"))) {
      stop("sf input must contain point geometries.", call. = FALSE)
    }
    coords <- sf::st_coordinates(x)
    x <- cbind(sf::st_drop_geometry(x), lon = coords[, "X"], lat = coords[, "Y"])
  } else if (is.matrix(x)) {
    x <- as.data.frame(x)
  }

  if (!is.data.frame(x)) {
    stop("x must be a data frame/tibble, matrix, sf object, SpatRaster, or bathy object.", call. = FALSE)
  }

  if (ncol(x) == 3 && !all(c(lon, lat, depth) %in% names(x))) {
    names(x)[seq_len(3)] <- c(lon, lat, depth)
  }
  cols <- c(lon, lat, depth)
  if (!all(cols %in% names(x))) {
    stop("x must contain longitude, latitude, and depth columns.", call. = FALSE)
  }
  if (!is.numeric(x[[lon]]) || !is.numeric(x[[lat]]) || !is.numeric(x[[depth]])) {
    stop("Longitude, latitude, and depth columns must be numeric.", call. = FALSE)
  }

  out <- data.frame(
    lon = x[[lon]],
    lat = x[[lat]],
    depth = x[[depth]]
  )
  out <- out[is.finite(out$lon) & is.finite(out$lat) & is.finite(out$depth), , drop = FALSE]
  if (nrow(out) == 0) {
    stop("x does not contain any complete finite lon/lat/depth row.", call. = FALSE)
  }
  if (length(unique(out$lon)) < 2 || length(unique(out$lat)) < 2) {
    stop("x must span at least two unique longitudes and two unique latitudes.", call. = FALSE)
  }
  out
}

spatraster_to_bathy_tbl <- function(x) {
  xyz <- terra::as.data.frame(x[[1]], xy = TRUE, na.rm = FALSE)
  names(xyz)[seq_len(3)] <- c("lon", "lat", "depth")
  tibble::as_tibble(xyz[, c("lon", "lat", "depth")])
}
