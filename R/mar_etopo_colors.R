# define a baseline etopo colour palette
#' @rdname mar_etopo_colors
#' @export
etopo <- read.csv(textConnection(
"altitudes,colours
10000,#FBFBFB
4000,#864747
3900,#7E4B11
2000,#9B8411
1900,#BD8D15
300,#F0CF9F
0,#307424
-1,#AFDCF4
-12000,#090B6A
"
), stringsAsFactors=FALSE)
etopo$altitudes01 <- scales::rescale(etopo$altitudes)


#' Etopo colours
#'
#' @description
#' Various ways to access the colors on the etopo color scale
#'
#' @rdname mar_etopo_colors
#' @aliases etopo.colors etopo.colours scale_color_etopo scale_colour_etopo scale_fill_etopo
#' @usage
#' mar_etopo_colors(n)
#'
#' mar_scale_fill_etopo(\dots)
#' mar_scale_color_etopo(\dots)
#' @param n number of colors to get from the scale. Those are evenly spaced within the scale.
#' @param \dots passed to \code{scale_fill_gradientn} or \code{scale_color_gradientn}
#'
#' @details
#' \code{mar_etopo_colors} is equivalent to other color scales in R (e.g. \code{grDevices::heat.colors}, \code{grDevices::cm.colors}).
#'
#' \code{scale_fill/color_etopo} are meant to be used with ggplot2. They allow consistent plots in various subregions by setting the limits of the scale explicitly.
#'
#' @author
#' Jean-Olivier Irisson
#'
#' @seealso
#' \code{\link{mar_autoplot_bathy}}, \code{\link{mar_palette_bathy}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' data(nw.atlantic)
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' # plot with base graphics
#' plot(atl, image=TRUE)
#'
#' # using the etopo color scale
#' etopo_cols <- rev(mar_etopo_colors(8))
#' plot(atl, image=TRUE, bpal=list(
#'   c(min(atl), 0, etopo_cols[1:2]),
#'   c(0, max(atl), etopo_cols[3:8])
#' ))
#'
#'
#' # plot using ggplot2; in which case the limits of the scale are automatic
#' library("ggplot2")
#' ggplot(atl, aes(x=x, y=y)) + coord_quickmap() +
#'   # background
#'   geom_raster(aes(fill=z)) +
#'   mar_scale_fill_etopo() +
#'   # countours
#'   geom_contour(aes(z=z),
#'     breaks=c(0, -100, -200, -500, -1000, -2000, -4000),
#'     colour="black", size=0.2
#'   ) +
#'   scale_x_continuous(expand=c(0,0)) +
#'   scale_y_continuous(expand=c(0,0))
#' @export
mar_etopo_colors <- function(n) {
  colorRampPalette(etopo$colours)(n)
}

#' @rdname mar_etopo_colors
#' @export
mar_scale_fill_etopo <- function(...) {
  ggplot2::scale_fill_gradientn(colours=etopo$colours, values=etopo$altitudes01, limits=range(etopo$altitudes), ...)
}

#' @rdname mar_etopo_colors
#' @export
mar_scale_color_etopo <- function(...) {
  ggplot2::scale_colour_gradientn(colours=etopo$colours, values=etopo$altitudes01, limits=range(etopo$altitudes), ...)
}

#' @rdname mar_etopo_colors
#' @export
etopo.colors <- mar_etopo_colors

#' @rdname mar_etopo_colors
#' @export
scale_fill_etopo <- mar_scale_fill_etopo

#' @rdname mar_etopo_colors
#' @export
scale_color_etopo <- mar_scale_color_etopo
