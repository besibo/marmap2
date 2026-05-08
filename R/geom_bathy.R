#' Plot bathymetric grids with ggplot2 and sf coordinates
#'
#' @description
#' Adds a raster-like bathymetry layer from a long table, a point \code{sf}
#' object, or a \code{bathy} object. The data are kept as regular x/y/z data, so
#' other ggplot2 layers such as \code{\link[ggplot2:geom_contour]{ggplot2::geom_contour}}
#' can be added to the same plot. A \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}
#' coordinate system is added automatically, or \code{\link{coord_sf_antimeridian}}
#' when \code{antimeridian = TRUE}.
#'
#' @param mapping Set of aesthetic mappings created by
#'   \code{\link[ggplot2:aes]{ggplot2::aes}}. If \code{x}, \code{y}, or
#'   \code{fill} are missing, they default to \code{lon}, \code{lat}, and
#'   \code{depth}.
#' @param data A long data frame/tibble, a point \code{sf} object, or a
#'   \code{bathy} object. If \code{NULL}, data are inherited from
#'   \code{\link[ggplot2:ggplot]{ggplot2::ggplot}}.
#' @param ... Additional arguments passed to
#'   \code{\link[ggplot2:geom_tile]{ggplot2::geom_tile}} or
#'   \code{\link[ggplot2:geom_raster]{ggplot2::geom_raster}}. For
#'   \code{geom = "tile"}, cell borders are coloured like the fill by default
#'   to mask anti-aliasing seams between adjacent tiles.
#' @param lon,lat,depth Character. Names of the longitude, latitude, and depth
#'   columns.
#' @param geom Character. Rendering geom, either \code{"tile"} or
#'   \code{"raster"}. \code{"tile"} is the default because it works quietly
#'   with \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}. With
#'   \code{coord_sf()}, ggplot2 draws \code{geom_raster()} through a rectangle
#'   fallback and may emit an informational message.
#' @param crs Coordinate reference system used by
#'   \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}} for non-\code{sf}
#'   layers. Defaults to \code{4326}, i.e. WGS84 longitude/latitude.
#' @param antimeridian Logical. If \code{TRUE}, uses
#'   \code{\link{coord_sf_antimeridian}} so longitude labels beyond 180 degrees
#'   are displayed as western longitudes.
#' @param x_breaks Breaks used for the x axis when \code{antimeridian = TRUE}.
#'   The default lets ggplot2 choose breaks automatically.
#' @param expand Logical or character vector passed to
#'   \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}. Use
#'   \code{expand = FALSE} to remove padding around the bathymetric grid while
#'   keeping geographic axis labels.
#' @param na.rm,show.legend,inherit.aes Arguments passed to the selected geom.
#'
#' @return
#' A list of ggplot2 components that can be added to a plot with \code{+}.
#'
#' @seealso
#' \code{\link{coord_sf_antimeridian}}, \code{\link{geom_sf_antimeridian}},
#' \code{\link{as_sf}}, \code{\link{bathy_to_tbl}}
#'
#' @examples
#' data(celt)
#' celt_tbl <- bathy_to_tbl(celt)
#'
#' \dontrun{
#' library(ggplot2)
#'
#' celt_tbl |>
#'   ggplot() +
#'   geom_bathy() +
#'   geom_contour(aes(lon, lat, z = depth), color = "white")
#' }
#' @export
geom_bathy <- function(
    mapping = NULL,
    data = NULL,
    ...,
    lon = "lon",
    lat = "lat",
    depth = "depth",
    geom = c("tile", "raster"),
    crs = 4326,
    antimeridian = FALSE,
    x_breaks = ggplot2::waiver(),
    expand = TRUE,
    na.rm = FALSE,
    show.legend = NA,
    inherit.aes = TRUE
) {
  geom <- match.arg(geom)
  mapping <- bathy_mapping(mapping, lon, lat, depth)

  layer_data <- if (is.null(data)) {
    function(plot_data) prepare_bathy_layer_data(plot_data, lon, lat, depth)
  } else {
    prepare_bathy_layer_data(data, lon, lat, depth)
  }

  geom_args <- list(...)
  if (identical(geom, "tile")) {
    mapped_aes <- names(mapping)
    if (!any(c("colour", "color") %in% c(names(geom_args), mapped_aes))) {
      mapping$colour <- rlang::quo(ggplot2::after_scale(fill))
    }
    if (!any(c("linewidth", "size") %in% c(names(geom_args), mapped_aes))) {
      geom_args$linewidth <- 0.2
    }
  }

  layer <- switch(
    geom,
    tile = do.call(
      ggplot2::geom_tile,
      c(
        list(
          mapping = mapping,
          data = layer_data,
          na.rm = na.rm,
          show.legend = show.legend,
          inherit.aes = inherit.aes
        ),
        geom_args
      )
    ),
    raster = do.call(
      ggplot2::geom_raster,
      c(
        list(
          mapping = mapping,
          data = layer_data,
          na.rm = na.rm,
          show.legend = show.legend,
          inherit.aes = inherit.aes
        ),
        geom_args
      )
    )
  )

  crs <- sf::st_crs(crs)
  coord <- if (isTRUE(antimeridian)) {
    coord_sf_antimeridian(
      crs = crs,
      default_crs = crs,
      x_breaks = x_breaks,
      expand = expand,
      default = TRUE
    )
  } else {
    ggplot2::coord_sf(crs = crs, default_crs = crs, expand = expand, default = TRUE)
  }

  list(layer, coord)
}

bathy_mapping <- function(mapping, lon, lat, depth) {
  default_mapping <- ggplot2::aes(
    x = !!rlang::sym(lon),
    y = !!rlang::sym(lat),
    fill = !!rlang::sym(depth)
  )

  if (is.null(mapping)) {
    return(default_mapping)
  }

  missing_aes <- setdiff(names(default_mapping), names(mapping))
  mapping <- c(mapping, default_mapping[missing_aes])
  class(mapping) <- "uneval"
  mapping
}

prepare_bathy_layer_data <- function(data, lon, lat, depth) {
  if (is.null(data)) {
    return(data)
  }

  if (is(data, "bathy")) {
    data <- bathy_to_tbl(data, names = c(lon, lat, depth))
  } else if (inherits(data, "sf")) {
    if (!requireNamespace("sf", quietly = TRUE)) {
      stop("Package 'sf' is required.", call. = FALSE)
    }
    geometry_type <- unique(as.character(sf::st_geometry_type(data)))
    if (!all(geometry_type %in% "POINT")) {
      stop("sf data passed to geom_bathy must use POINT geometries.", call. = FALSE)
    }
    coords <- sf::st_coordinates(data)
    data <- sf::st_drop_geometry(data)
    data[[lon]] <- coords[, "X"]
    data[[lat]] <- coords[, "Y"]
  } else if (!is.data.frame(data)) {
    stop("data must be a data.frame/tibble, a point sf object, or a bathy object.", call. = FALSE)
  }

  cols <- c(lon, lat, depth)
  if (!is.character(cols) || length(cols) != 3 || anyNA(cols) || any(!nzchar(cols))) {
    stop("lon, lat, and depth must be column names.", call. = FALSE)
  }
  if (!all(cols %in% names(data))) {
    stop("data must contain columns named by lon, lat, and depth.", call. = FALSE)
  }
  if (!is.numeric(data[[lon]]) || !is.numeric(data[[lat]]) || !is.numeric(data[[depth]])) {
    stop("Longitude, latitude, and depth columns must be numeric.", call. = FALSE)
  }

  data
}
