#' Draw the coastline from bathymetric data
#'
#' @description
#' `geom_coastline()` draws the `0 m` contour line from a regular bathymetric
#' grid. It is a small convenience wrapper around
#' \code{\link[ggplot2:geom_contour]{ggplot2::geom_contour}} with
#' `breaks = 0`.
#'
#' @param mapping Set of aesthetic mappings created by
#'   \code{\link[ggplot2:aes]{ggplot2::aes}}. If `x`, `y`, or `z` are missing,
#'   they default to `lon`, `lat`, and `depth`.
#' @param data Data to display in this layer. Defaults to the data inherited
#'   from \code{\link[ggplot2:ggplot]{ggplot2::ggplot}}.
#' @param ... Additional arguments passed to
#'   \code{\link[ggplot2:geom_contour]{ggplot2::geom_contour}}.
#' @param lon,lat,depth Character. Names of the longitude, latitude, and depth
#'   columns used when the corresponding aesthetics are not supplied in
#'   `mapping`.
#' @param colour,linewidth,linetype Default line style. These can be changed to
#'   customize the coastline.
#' @param na.rm,show.legend,inherit.aes Arguments passed to
#'   \code{\link[ggplot2:geom_contour]{ggplot2::geom_contour}}.
#'
#' @return A ggplot2 layer.
#'
#' @seealso
#' \code{\link{geom_bathy}},
#' \code{\link[ggplot2:geom_contour]{ggplot2::geom_contour}}
#'
#' @examples
#' \dontrun{
#' dat |>
#'   ggplot2::ggplot() +
#'   geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
#'   geom_coastline()
#'
#' dat |>
#'   ggplot2::ggplot() +
#'   geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
#'   geom_coastline(colour = "grey25", linewidth = 0.6, linetype = "dashed")
#' }
#' @export
geom_coastline <- function(
    mapping = NULL,
    data = NULL,
    ...,
    lon = "lon",
    lat = "lat",
    depth = "depth",
    colour = "black",
    linewidth = 0.6,
    linetype = "solid",
    na.rm = FALSE,
    show.legend = NA,
    inherit.aes = TRUE
) {
  mapping <- coastline_mapping(mapping, lon, lat, depth)

  ggplot2::geom_contour(
    mapping = mapping,
    data = data,
    ...,
    breaks = 0,
    colour = colour,
    linewidth = linewidth,
    linetype = linetype,
    na.rm = na.rm,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
}

coastline_mapping <- function(mapping, lon, lat, depth) {
  default_mapping <- ggplot2::aes(
    x = !!rlang::sym(lon),
    y = !!rlang::sym(lat),
    z = !!rlang::sym(depth)
  )

  if (is.null(mapping)) {
    return(default_mapping)
  }

  missing_aes <- setdiff(names(default_mapping), names(mapping))
  mapping <- c(mapping, default_mapping[missing_aes])
  class(mapping) <- "uneval"
  mapping
}
