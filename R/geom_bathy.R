#' Plot bathymetric grids with ggplot2 and sf coordinates
#'
#' @description
#' Adds a raster-like bathymetry layer from a long table, a point \code{sf}
#' object, or a \code{bathy} object. The data are kept as regular x/y/z data, so
#' other ggplot2 layers such as \code{\link[ggplot2:geom_contour]{ggplot2::geom_contour}}
#' can be added to the same plot. A \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}
#' coordinate system is added automatically, or \code{\link{coord_sf_antimeridian}}
#' when \code{antimeridian = TRUE}. Projected tibbles returned by
#' \code{\link{project_bathy}} are detected automatically and plotted with
#' \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}} using their projected CRS.
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
#'   longitude labels adapted to data crossing the antimeridian.
#' @param coord Character. Coordinate system to add. \code{"auto"} is the
#'   default and uses \code{"sf"} for geographic and projected bathymetry.
#'   Projected tibbles returned by \code{\link{project_bathy}} are detected
#'   automatically and their destination CRS is used. \code{"sf"} uses
#'   \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}} or
#'   \code{\link{coord_sf_antimeridian}}. \code{"fixed"} uses
#'   \code{\link[ggplot2:coord_fixed]{ggplot2::coord_fixed}}.
#' @param asp Numeric. Aspect ratio used when \code{coord = "fixed"}. The
#'   default \code{1} gives longitude and latitude degrees the same graphical
#'   scale.
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
#' \code{\link{coord_sf_antimeridian}}, \code{\link{as_sf}},
#' \code{\link{bathy_to_tbl}}
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' xyz |>
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
    coord = c("auto", "sf", "fixed"),
    asp = 1,
    x_breaks = ggplot2::waiver(),
    expand = TRUE,
    na.rm = FALSE,
    show.legend = NA,
    inherit.aes = TRUE
) {
  geom <- match.arg(geom)
  coord <- match.arg(coord)
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

  structure(
    list(
      layer = layer,
      coord = coord,
      crs = crs,
      antimeridian = antimeridian,
      asp = asp,
      x_breaks = x_breaks,
      expand = expand
    ),
    class = "bathy_ggplot_components"
  )
}

#' @importFrom ggplot2 ggplot_add
#' @method ggplot_add bathy_ggplot_components
#' @export
ggplot_add.bathy_ggplot_components <- function(object, plot, ...) {
  projected_data <- projected_bathy_data(plot$data, object$layer$data)
  coord <- object$coord
  if (identical(coord, "auto")) {
    coord <- "sf"
  }
  crs <- object$crs
  if (!is.null(projected_data) && identical(coord, "sf")) {
    crs <- attr(projected_data, "crs_to", exact = TRUE)
  }

  coordinates <- bathy_coordinates(
    coord = coord,
    crs = crs,
    antimeridian = object$antimeridian,
    asp = object$asp,
    x_breaks = object$x_breaks,
    expand = object$expand
  )
  axis_labels <- ggplot2::labs(x = "Longitude", y = "Latitude")

  plot <- plot + object$layer
  for (component in coordinates) {
    if (!is.null(component)) {
      plot <- plot + component
    }
  }
  plot + axis_labels
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

bathy_fixed_coordinates <- function(antimeridian, asp, x_breaks, expand) {
  if (!is.numeric(asp) || length(asp) != 1 || is.na(asp) || asp <= 0) {
    stop("asp must be a single positive number.", call. = FALSE)
  }

  x_scale <- ggplot2::scale_x_continuous(
    breaks = x_breaks,
    labels = if (isTRUE(antimeridian)) label_longitude_360 else ggplot2::waiver()
  )
  y_scale <- if (isTRUE(antimeridian)) {
    ggplot2::scale_y_continuous(labels = label_latitude)
  } else {
    NULL
  }
  coord <- ggplot2::coord_fixed(ratio = asp, expand = expand, default = TRUE)

  list(x_scale, y_scale, coord)
}

bathy_coordinates <- function(coord, crs, antimeridian, asp, x_breaks, expand) {
  if (identical(coord, "fixed")) {
    return(bathy_fixed_coordinates(
      antimeridian = antimeridian,
      asp = asp,
      x_breaks = x_breaks,
      expand = expand
    ))
  }

  crs <- sf::st_crs(crs)
  if (isTRUE(antimeridian)) {
    return(list(coord_sf_antimeridian(
      crs = crs,
      default_crs = crs,
      x_breaks = x_breaks,
      expand = expand,
      default = TRUE
    )))
  }

  list(ggplot2::coord_sf(crs = crs, default_crs = crs, expand = expand, default = TRUE))
}

projected_bathy_data <- function(...) {
  candidates <- list(...)
  for (data in candidates) {
    if (inherits(data, "projected_bathy") || !is.null(attr(data, "crs_to", exact = TRUE))) {
      return(data)
    }
  }
  NULL
}

label_longitude <- function(x) {
  lon <- ifelse(x > 180, x - 360, x)
  lon <- ifelse(lon < -180, lon + 360, lon)
  out <- ifelse(abs(lon) == 180, "180\u00b0",
    ifelse(lon == 0, "0\u00b0",
      ifelse(lon > 0, paste0(abs(lon), "\u00b0E"), paste0(abs(lon), "\u00b0W"))
    )
  )
  out[is.na(x)] <- NA_character_
  out
}

label_latitude <- function(x) {
  out <- ifelse(x == 0, "0\u00b0",
    ifelse(x > 0, paste0(abs(x), "\u00b0N"), paste0(abs(x), "\u00b0S"))
  )
  out[is.na(x)] <- NA_character_
  out
}
