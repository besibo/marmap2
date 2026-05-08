#' Plot sf bathymetry around the antimeridian
#'
#' @description
#' Adds an \code{sf} layer with longitude axis labels adapted for data stored
#' in the 0-360 longitude convention around the antimeridian.
#'
#' @param mapping Set of aesthetic mappings created by \code{\link[ggplot2:aes]{ggplot2::aes}}.
#' @param data Data to display in this layer. Defaults to the data inherited
#'   from \code{\link[ggplot2:ggplot]{ggplot2::ggplot}}.
#' @param stat Statistical transformation used by
#'   \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf}}. Defaults to \code{"sf"}.
#' @param position Position adjustment. Defaults to \code{"identity"}.
#' @param ... Additional arguments passed to
#'   \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf}}.
#' @param x_breaks Breaks used for the x axis. The default lets ggplot2 choose
#'   breaks automatically. This only affects the longitude axis labels added
#'   by \code{\link{coord_sf_antimeridian}}.
#' @param na.rm,show.legend,inherit.aes Arguments passed to
#'   \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf}}.
#'
#' @return
#' A list of ggplot2 components that can be added to a plot with \code{+}.
#'
#' @seealso
#' \code{\link{as_sf}},
#' \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf}},
#' \code{\link{coord_sf_antimeridian}}
#'
#' @examples
#' \dontrun{
#' anti |>
#'   as_sf() |>
#'   ggplot2::ggplot() +
#'   geom_sf_antimeridian(ggplot2::aes(color = depth))
#' }
#' @export
geom_sf_antimeridian <- function(
    mapping = NULL,
    data = NULL,
    stat = "sf",
    position = "identity",
    ...,
    x_breaks = ggplot2::waiver(),
    na.rm = FALSE,
    show.legend = NA,
    inherit.aes = TRUE
) {
  list(
    ggplot2::geom_sf(
      mapping = mapping,
      data = data,
      stat = stat,
      position = position,
      ...,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    coord_sf_antimeridian(x_breaks = x_breaks, default = TRUE)
  )
}

#' Coordinate system for sf data around the antimeridian
#'
#' @description
#' A small wrapper around \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}
#' that keeps the standard \code{coord_sf()} behaviour but allows longitude
#' axis labels beyond 180 degrees to be displayed as western longitudes.
#'
#' @inheritParams ggplot2::coord_sf
#' @param x_breaks Breaks used for the x axis. The default lets ggplot2 choose
#'   breaks automatically.
#'
#' @return
#' A ggplot2 coordinate system.
#'
#' @seealso
#' \code{\link{geom_sf_antimeridian}},
#' \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}
#'
#' @export
coord_sf_antimeridian <- function(
    xlim = NULL,
    ylim = NULL,
    expand = TRUE,
    crs = NULL,
    default_crs = NULL,
    datum = sf::st_crs(4326),
    label_graticule = ggplot2::waiver(),
    label_axes = ggplot2::waiver(),
    lims_method = "cross",
    ndiscr = 100,
    default = FALSE,
    clip = "on",
    reverse = "none",
    x_breaks = ggplot2::waiver()
) {
  coord <- ggplot2::coord_sf(
    xlim = xlim,
    ylim = ylim,
    expand = expand,
    crs = crs,
    default_crs = default_crs,
    datum = datum,
    label_graticule = label_graticule,
    label_axes = label_axes,
    lims_method = lims_method,
    ndiscr = ndiscr,
    default = default,
    clip = clip,
    reverse = reverse
  )
  setup_panel_params <- coord$setup_panel_params

  coord$setup_panel_params <- function(self, scale_x, scale_y, params = list()) {
    scale_x_labels <- scale_x$labels
    scale_x$labels <- ggplot2::waiver()
    on.exit(scale_x$labels <- scale_x_labels, add = TRUE)
    panel_params <- setup_panel_params(scale_x, scale_y, params)
    scale_x$labels <- scale_x_labels

    breaks <- get_antimeridian_x_breaks(scale_x, panel_params$x_range, x_breaks)
    labels <- get_antimeridian_x_labels(scale_x, breaks)

    panel_params$x <- update_antimeridian_x_axis(panel_params$x, breaks, labels)
    panel_params$x.sec <- update_antimeridian_x_axis(panel_params$x.sec, breaks, labels)
    panel_params
  }

  coord
}

label_longitude_360 <- function(x) {
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

get_antimeridian_x_breaks <- function(scale_x, x_range, breaks) {
  if (inherits(breaks, "waiver")) {
    breaks <- scale_x$get_breaks(limits = x_range)
  } else if (is.function(breaks)) {
    breaks <- breaks(x_range)
  }

  if (is.null(breaks)) {
    return(numeric())
  }

  breaks[is.finite(breaks)]
}

get_antimeridian_x_labels <- function(scale_x, breaks) {
  if (is.null(scale_x$labels)) {
    return(rep(NA_character_, length(breaks)))
  }
  if (inherits(scale_x$labels, "waiver")) {
    return(label_longitude_360(breaks))
  }

  scale_x$get_labels(breaks)
}

update_antimeridian_x_axis <- function(axis, breaks, labels) {
  axis$breaks <- breaks
  axis$labels <- as.list(labels)
  axis$get_labels <- function(self, breaks = self$get_breaks()) self$labels
  axis
}
