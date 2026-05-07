#' Ploting bathymetric data with ggplot
#'
#' @description
#' Plots contour or image map from bathymetric data matrix of class \code{bathy} with ggplot2
#'
#' @rdname autoplot_bathy
#' @param object bathymetric data matrix of class \code{bathy}, imported using \code{\link{read_bathy}}
#' @param geom geometry to use for the plot, i.e. type of plot; can be `contour', `tile' or `raster'. `contour' does a contour plot. `tile' and `raster' produce an image plot. tile allows true geographical projection through \code{\link[ggplot2]{coord_map}}. raster only allows approximate projection but is faster to plot.
#' Names can be abbreviated. Geometries can be combined by specifying several in a vector.
#' @param mapping additional mappings between the data obtained from calling \code{\link{fortify_bathy}} on x and the aesthetics for all geoms. When not NULL, this is a call to aes().
#' @param coast boolean; wether to highlight the coast (isobath 0 m) as a black line
#' @param \dots passed to the chosen geom(s)
#'
#' @details
#' \code{\link{fortify_bathy}} is called with argument \code{x} to produce a data.frame compatible with ggplot2. Then layers are added to the plot based on the argument \code{geom}. Finally, the whole plot is projected geographically using \code{\link[ggplot2]{coord_map}} (for \code{geom="contour"}) or an approximation thereof.
#'
#' @author
#' Jean-Olivier Irisson
#'
#' @seealso
#' \code{\link{fortify_bathy}}, \code{\link{plot_bathy}}, \code{\link{read_bathy}}, \code{\link{summary_bathy}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' 	data(nw.atlantic)
#' 	atl <- as_bathy(nw.atlantic)
#'
#'   # basic plot
#' \dontrun{
#'   library("ggplot2")
#' 	autoplot_bathy(atl)
#'
#'   # plot images
#' 	autoplot_bathy(atl, geom=c("tile"))
#' 	autoplot_bathy(atl, geom=c("raster")) # faster but not resolution independant
#'
#'   # plot both!
#' 	autoplot_bathy(atl, geom=c("raster", "contour"))
#'
#'   # geom names can be abbreviated
#' 	autoplot_bathy(atl, geom=c("r", "c"))
#'
#'   # do not highlight the coastline
#' 	autoplot_bathy(atl, coast=FALSE)
#'
#'   # better colour scale
#'   	autoplot_bathy(atl, geom=c("r", "c")) +
#'     scale_fill_gradient2(low="dodgerblue4", mid="gainsboro", high="darkgreen")
#'
#'   # set aesthetics
#' 	autoplot_bathy(atl, geom=c("r", "c"), colour="white", size=0.1)
#'
#'   # topographical colour scale, see ?scale_fill_etopo
#' 	autoplot_bathy(atl, geom=c("r", "c"), colour="white", size=0.1) + scale_fill_etopo()
#'
#' 	# add sampling locations
#' 	data(metallo)
#'   last_plot() + geom_point(aes(x=lon, y=lat), data=metallo, alpha=0.5)
#'
#'   # an alternative contour map making use of additional mappings
#'   # see ?stat_contour in ggplot2 to understand the ..level.. argument
#' 	autoplot_bathy(atl, geom="contour", mapping=aes(colour=..level..))
#' }
#' @name autoplot_bathy
NULL

#' @export
#' @noRd
autoplot.bathy <- function(object, geom="contour", mapping=NULL, coast=TRUE, ...) {
  # plot an object of class bathy

  # expand geom argument
  geom <- match.arg(geom, choices=c("contour", "raster", "tile"), several.ok=TRUE)
  if ( all(c("tile", "raster") %in% geom) ) {
    warning("'raster' and 'tile' are two alternative ways to plot an image map. Specifying both does not seem wise since one will cover the other. Keeping only 'raster'")
    geom <- geom[-which(geom == "tile")]
  }

  # get a data.frame
  xdf <- fortify_bathy(object)

  # set default mapping and add user-specified mappings
  if ( is.null(mapping) ) {
    mapping <- ggplot2::aes()
  }
  mapping <- c(ggplot2::aes_string(x='x', y='y'), mapping)
  class(mapping) <- "uneval"

  # prepare the base plot
  p <- ggplot2::ggplot(xdf, mapping=mapping) +
    # remove extra space around the plot
    ggplot2::scale_x_continuous(expand=c(0,0)) +
    ggplot2::scale_y_continuous(expand=c(0,0))

  # add layers
  if ("tile" %in% geom) {
    # "image" plot
    p <- p + ggplot2::geom_tile(ggplot2::aes_string(fill='z'), ...)

  }

  if ("raster" %in% geom) {
    # "image" plot using geom_raster
    # NB: faster than geom_tile, gives smaller PDFs but:
    #     . is not resolution independent
    #     . does not work with non-square aspect ratios (i.e. coord_map())
    p <- p + ggplot2::geom_raster(ggplot2::aes_string(fill='z'), ...)
  }

  if ("contour" %in% geom) {
    # bathy contours
    # (do not set colour if it is already specified in the mapping)
    if ("colour" %in% names(mapping) | "colour" %in% names(list(...))) {
      contours <- ggplot2::geom_contour(ggplot2::aes_string(z='z'), ...)
    } else {
      contours <- ggplot2::geom_contour(ggplot2::aes_string(z='z'), colour="grey30", ...)
    }
    p <- p + contours
  }

  if ( coast ) {
    # "coastline" contour = 0 isobath
    p <- p + ggplot2::geom_contour(ggplot2::aes_string(z='z'), colour="black", linetype="solid", size=0.5, breaks=0, alpha=1)
    # NB: set all the aesthetics so that they are not affected by what is specified in the function call
  }

  # set mapping projection
  if ( any(c("tile", "raster") %in% geom) ) {
	  coord <- ggplot2::coord_quickmap()
  } else {
    # true map projection
    coord <- ggplot2::coord_map()
  }
  p <- p + coord

  return(p)
}

#' @rdname autoplot_bathy
#' @export
autoplot_bathy <- autoplot.bathy
