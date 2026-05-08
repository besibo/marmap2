#' Convert between bathy objects and tibbles
#'
#' @description
#' `bathy_to_tbl()` converts the historical matrix-based `bathy` class to a
#' long tibble with longitude, latitude, and depth/elevation columns.
#' `tbl_to_bathy()` converts a long table back to a `bathy` object.
#'
#' @param x An object of class `bathy` for `bathy_to_tbl()`, or a table for
#'   `tbl_to_bathy()`.
#' @param names Character vector of length 3 giving the output column names for
#'   longitude, latitude, and depth/elevation.
#' @param lon,lat,depth Column names used by `tbl_to_bathy()`.
#'
#' @return
#' `bathy_to_tbl()` returns a tibble. `tbl_to_bathy()` returns an object of
#' class `bathy`.
#'
#' @seealso
#' \code{\link{as_bathy}}, \code{\link{as_xyz}}, \code{\link{get_noaa}},
#' \code{\link{get_gebco}}
#'
#' @examples
#' data(celt)
#'
#' celt_tbl <- bathy_to_tbl(celt)
#' celt_tbl
#'
#' celt_bathy <- tbl_to_bathy(celt_tbl)
#' class(celt_bathy)
#' @export
bathy_to_tbl <- function(x, names = c("lon", "lat", "depth")) {
  if (!is(x, "bathy")) {
    stop("x must be an object of class 'bathy'.", call. = FALSE)
  }
  if (!is.character(names) || length(names) != 3 || anyNA(names) || any(!nzchar(names))) {
    stop("names must be a character vector of length 3.", call. = FALSE)
  }

  out <- as_xyz(x)
  names(out) <- names
  tibble::as_tibble(out)
}

#' @rdname bathy_to_tbl
#' @export
tbl_to_bathy <- function(x, lon = "lon", lat = "lat", depth = "depth") {
  if (!is.data.frame(x)) {
    stop("x must be a data.frame or tibble.", call. = FALSE)
  }
  cols <- c(lon, lat, depth)
  if (!is.character(cols) || length(cols) != 3 || anyNA(cols) || any(!nzchar(cols))) {
    stop("lon, lat, and depth must be column names.", call. = FALSE)
  }
  if (!all(cols %in% names(x))) {
    stop("x must contain columns named by lon, lat, and depth.", call. = FALSE)
  }

  xyz <- data.frame(
    lon = x[[lon]],
    lat = x[[lat]],
    depth = x[[depth]]
  )
  as_bathy(xyz)
}
