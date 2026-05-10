#' Convert bathymetric data to sf
#'
#' @description
#' Converts an object of class \code{bathy}, or a long table containing
#' longitude and latitude columns, to an \code{sf} object with point geometries.
#'
#' @param x An object of class \code{bathy}, or a data frame/tibble containing
#'   longitude and latitude columns.
#' @param lon,lat Character. Names of the longitude and latitude columns used
#'   when \code{x} is a data frame or tibble.
#' @param crs Coordinate reference system assigned to the returned
#'   \code{sf} object. Defaults to \code{4326}, i.e. WGS84 longitude/latitude.
#' @param remove Logical. If \code{TRUE}, the coordinate columns are removed
#'   from the returned attribute table. Defaults to \code{FALSE}.
#' @param ... Additional arguments passed to \code{\link[sf:st_as_sf]{sf::st_as_sf}}.
#'
#' @return
#' An object of class \code{sf} with point geometries.
#'
#' @seealso
#' \code{\link{bathy_to_tbl}}, \code{\link{tbl_to_bathy}},
#' \code{\link{as_spatraster}}, \code{\link{project_bathy}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' xyz_sf <- as_sf(xyz)
#' class(xyz_sf)
#' @export
as_sf <- function(
    x,
    lon = "lon",
    lat = "lat",
    crs = 4326,
    remove = FALSE,
    ...
) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Package 'sf' is required.", call. = FALSE)
  }

  if (is(x, "bathy")) {
    x <- bathy_to_tbl(x)
  } else if (!is.data.frame(x)) {
    stop("x must be an object of class 'bathy', or a data.frame/tibble.", call. = FALSE)
  }

  coords <- c(lon, lat)
  if (!is.character(coords) || length(coords) != 2 || anyNA(coords) || any(!nzchar(coords))) {
    stop("lon and lat must be column names.", call. = FALSE)
  }
  if (!all(coords %in% names(x))) {
    stop("x must contain columns named by lon and lat.", call. = FALSE)
  }
  if (!is.numeric(x[[lon]]) || !is.numeric(x[[lat]])) {
    stop("Longitude and latitude columns must be numeric.", call. = FALSE)
  }

  sf::st_as_sf(x, coords = coords, crs = crs, remove = remove, ...)
}
