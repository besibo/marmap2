#' Convert to bathymetric data in an object of class bathy
#'
#' @description
#' Converts a three-column data frame containing longitude, latitude and depth
#' values, or a \code{terra::SpatRaster}, to a matrix of class \code{bathy}.
#'
#' @rdname as_bathy
#' @usage
#' as_bathy(x)
#' @param x Three-column data frame with longitude, latitude and depth values,
#'   or a \code{terra::SpatRaster}.
#'
#' @details
#' For tabular input, the first column is interpreted as longitude, the second
#' as latitude, and the third as depth or elevation. Missing grid cells are
#' represented as \code{NA}. For \code{terra::SpatRaster} input, the first layer
#' is converted to xyz cell centres before creating the \code{bathy} matrix.
#'
#' @return
#' The output of \code{as_bathy} is a matrix of class \code{bathy}, with
#' longitude stored in row names and latitude stored in column names.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{summarise_bathy}}, \code{\link{read_bathy}},
#' \code{\link{as_xyz}}, \code{\link{bathy_to_tbl}}, \code{\link{tbl_to_bathy}}.
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' bathy <- as_bathy(xyz)
#' class(bathy)
#' summarise_bathy(bathy)
#' @export
as_bathy <- function(x) {
  if (inherits(x, "bathy")) {
    stop("Object is already of class 'bathy'")
  }

  if (inherits(x, "SpatRaster")) {
    if (!requireNamespace("terra", quietly = TRUE)) {
      stop("Package 'terra' is required.", call. = FALSE)
    }
    x <- terra::as.data.frame(x[[1]], xy = TRUE, na.rm = FALSE)
  }

  if (!is.data.frame(x) || ncol(x) != 3) {
    stop("as_bathy requires a 3-column table, or an object of class SpatRaster")
  }

  bathy <- xyz_to_bathy_matrix(x)
  ordered.mat <- check_bathy(bathy)
  class(ordered.mat) <- "bathy"
  ordered.mat
}

xyz_to_bathy_matrix <- function(x) {
  if (!is.data.frame(x) || ncol(x) != 3) {
    stop("x must be a 3-column table.", call. = FALSE)
  }

  x <- data.frame(
    lon = x[[1]],
    lat = x[[2]],
    depth = x[[3]]
  )
  if (!is.numeric(x$lon) || !is.numeric(x$lat) || !is.numeric(x$depth)) {
    stop("Longitude, latitude, and depth columns must be numeric.", call. = FALSE)
  }
  if (any(!is.finite(x$lon)) || any(!is.finite(x$lat))) {
    stop("Longitude and latitude values must be finite.", call. = FALSE)
  }

  lon <- sort(unique(x$lon))
  lat <- sort(unique(x$lat))
  mat <- matrix(
    NA_real_,
    nrow = length(lon),
    ncol = length(lat),
    dimnames = list(lon, lat)
  )
  mat[cbind(match(x$lon, lon), match(x$lat, lat))] <- x$depth
  mat
}
