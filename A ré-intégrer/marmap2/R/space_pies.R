#' Automatic placement of piecharts on maps
#'
#' @description
#' Attemps to automatically place piecharts on maps, avoiding overlap. Work in progress...
#'
#' @rdname space_pies
#' @usage
#' space_pies(x, y, pie.slices, pie.colors=NULL, pie.radius=1, pie.space=5,
#'               link=TRUE, seg.lwd=1, seg.col=1, seg.lty=1, coord=NULL)
#' @param x the longitude of the anchor point for the piechart
#' @param y the latitude of the anchor point for the piechart
#' @param pie.slices a table with the counts to draw pies (col: pie categories, or slices; rows: sites on the map)
#' @param pie.colors a table with the colors to draw pies (col: pie categories, or slices; rows: sites on the map)
#' @param pie.radius size of the piechart
#' @param pie.space factor of spacing between the anchor and the pie (the larger, the farther the pie from the anchor)
#' @param link logical; whether to add a segment to link pie and anchor
#' @param seg.lwd the line width of the link
#' @param seg.col the line color of the link
#' @param seg.lty the line type of the link
#' @param coord when coord = \code{NULL} (default), placement is automatic. Otherwise, a 2-col table of lon/lat for pies.
#'
#' @details
#' \code{space_pies} tries to position piecharts on a map while avoiding overlap between them. The function heavily relies on two other functions. \code{floating.pie} from package plotrix is used to draw individual piecharts. \code{floating.pie} treats one pie at a time; \code{space_pies} can handle one or multiple pies by looping \code{floating.pie}. \code{pointLabels} from package maptools was modified to find the best placement for the pies, given their size and distance from their anchor point. \code{pointLabels} was originally meant to automatically place text labels, not objects; the modified version contained in \code{space_pies} uses the coordinates chosen by \code{pointLabels} for text. The algorithm used is simulating annealing (SANN). You can get a different result each time you run \code{space_pies}, because \code{pointLabel} finds one good solution out of many. If you are not satisfied by the solution, you can try running the function again.
#'
#' The argument \code{coord} allows to choose between the automatic placement outlined above, and a user-defined list of longitudes and latitudes (in a two-column table format) for plotting the piecharts.
#'
#' Anchor point: spatial location of the data corresponding to the piechart (e.g. a sampling point).
#'
#' @return
#' Piechart(s) added to a plot.
#'
#' @references
#' Bivand, R. and Lewin-Koh, N. (2013) maptools: Tools for reading and handling spatial objects. R package version 0.8-25. http://CRAN.R-project.org/package=maptools
#'
#' Lemon, J. (2006) Plotrix: a package in the red light district of R. R-News, 6(4): 8-12.
#'
#' SANN code implemented in \code{pointLabel} based on: Jon Christensen, Joe Marks, and Stuart Shieber. Placing text labels on maps and diagrams. In Paul Heckbert, editor, Graphics Gems IV, pages 497-504. Academic Press, Boston, MA, 1994.
#'
#' @author
#' Eric Pante, using functions \code{plotrix::floating.pie} and \code{maptools::pointLabel}.
#'
#' @seealso
#' \code{\link{plot_bathy}}, \code{plotrix::floating.pie}, \code{maptools::pointLabel}
#'
#' @examples
#' # fake frequencies to feed to space_pies()
#' 	sample(seq(10,90,5), 11)-> freq.a
#' 	100-freq.a -> freq.b
#' 	rep("lightblue",11) -> col.a
#' 	rep("white",11) -> col.b
#'
#' # some coordinates on the NW Atlantic coast, and on seamounts
#' 	x = c(-74.28487,-73.92323,-73.80753,-72.51728,-71.12418,
#' 		  -69.81176,-69.90715,-70.43201,-70.17135,-69.43912,-65.49608)
#' 	y = c(39.36714,39.98515,40.40316,40.79654,41.49872,41.62076,
#' 		  41.99805,42.68061,43.40714,43.81499,43.36471)
#' 	pts.coast = data.frame(x,y, freq.a, freq.b, col.a, col.b)
#'
#' 	x = c(-66.01404,-65.47260,-63.75456,-63.26082,-62.12838,
#' 	      -60.46885,-59.96952,-56.90925,-52.20397,-51.32288,-50.72461)
#' 	y = c(39.70769,39.39064,38.83020,38.56479,38.01881,38.95405,
#' 	      37.55675,34.62617,36.15592,36.38992,35.91779)
#' 	pts.smt = data.frame(x,y, freq.a, freq.b, col.a, col.b)
#'
#' # prepare the plot
#' 	data(nw.atlantic) ; atl <- as_bathy(nw.atlantic)
#' 	plot(atl, deep=-8000, shallow=0, step=1000,col="grey")
#' 	points(pts.coast,pch=19,col="blue", cex=0.5)
#' 	points(pts.smt,pch=19,col="blue", cex=0.5)
#'
#' # automatic placement of piecharts with space_pies
#' 	space_pies(pts.coast[,1], pts.coast[,2],
#' 	           pie.slices=pts.coast[,3:4], pie.colors=pts.coast[,5:6], pie.radius=0.5)
#' 	space_pies(pts.smt[,1], pts.smt[,2],
#' 	           pie.slices=pts.smt[,3:4], pie.colors=pts.coast[,5:6], pie.radius=0.5)
#' @export
space_pies <-
  function(x,
           y,
           pie.slices,
           pie.colors = NULL,
           pie.radius = 1,
           pie.space = 5,
           link = TRUE,
           seg.lwd = 1,
           seg.col = 1,
           seg.lty = 1,
           coord = NULL) {
    if (is.null(coord)) {
      ## mm.pointLabels is the marmap version of pointLabels function from package maptools
      mm.pointLabels = function (x,
                                 y = NULL,
                                 labels = seq(along = x),
                                 cex = 1,
                                 method = c("SANN",
                                            "GA"),
                                 allowSmallOverlap = FALSE,
                                 trace = FALSE,
                                 doPlot = TRUE,
                                 ...)
      {
        if (!missing(y) && (is.character(y) || is.expression(y))) {
          labels <- y
          y <- NULL
        }
        labels <- as.graphicsAnnot(labels)
        boundary <- par()$usr
        xyAspect <- par()$pin[1] / par()$pin[2]
        toUnityCoords <- function(xy) {
          list(
            x = (xy$x - boundary[1]) / (boundary[2] - boundary[1]) *
              xyAspect,
            y = (xy$y - boundary[3]) / (boundary[4] -
                                          boundary[3]) / xyAspect
          )
        }
        toUserCoords <- function(xy) {
          list(
            x = boundary[1] + xy$x / xyAspect * (boundary[2] -
                                                   boundary[1]),
            y = boundary[3] + xy$y * xyAspect *
              (boundary[4] - boundary[3])
          )
        }
        z <- xy.coords(x, y, recycle = TRUE)
        z <- toUnityCoords(z)
        x <- z$x
        y <- z$y
        if (length(labels) < length(x))
          labels <- rep(labels, length(x))
        method <- match.arg(method)
        if (allowSmallOverlap)
          nudgeFactor <- 0.02 ###original 0.02###########
        n_labels <- length(x)
        width <- (strwidth(labels, units = "figure", cex = cex) +
                    0.015) * xyAspect
        height <- (strheight(labels, units = "figure", cex = cex) +
                     0.015) / xyAspect
        gen_offset <-
          function(code)
            c(-1,-1,-1, 0, 0, 1, 1, 1)[code] *
          (width / 2) + (0 + 1i) * c(-1, 0, 1,-1, 1,-1, 0, 1)[code] *
          (height / 2)
        rect_intersect <- function(xy1, offset1, xy2, offset2) {
          w <- pmin(Re(xy1 + offset1 / 2), Re(xy2 + offset2 / 2)) -
            pmax(Re(xy1 - offset1 / 2), Re(xy2 - offset2 / 2))
          h <- pmin(Im(xy1 + offset1 / 2), Im(xy2 + offset2 / 2)) -
            pmax(Im(xy1 - offset1 / 2), Im(xy2 - offset2 / 2))
          w[w <= 0] <- 0
          h[h <= 0] <- 0
          w * h
        }
        nudge <- function(offset) {
          doesIntersect <- rect_intersect(xy[rectidx1] + offset[rectidx1],
                                          rectv[rectidx1], xy[rectidx2] + offset[rectidx2],
                                          rectv[rectidx2]) > 0
          pyth <-
            abs(xy[rectidx1] + offset[rectidx1] - xy[rectidx2] -
                  offset[rectidx2]) / nudgeFactor
          eps <- 1e-10
          for (i in which(doesIntersect & pyth > eps)) {
            idx1 <- rectidx1[i]
            idx2 <- rectidx2[i]
            vect <-
              (xy[idx1] + offset[idx1] - xy[idx2] - offset[idx2]) / pyth[idx1]
            offset[idx1] <- offset[idx1] + vect
            offset[idx2] <- offset[idx2] - vect
          }
          offset
        }
        objective <- function(gene) {
          offset <- gen_offset(gene)
          if (allowSmallOverlap)
            offset <- nudge(offset)
          if (!is.null(rectidx1))
            area <-
              sum(rect_intersect(xy[rectidx1] + offset[rectidx1],
                                 rectv[rectidx1], xy[rectidx2] + offset[rectidx2],
                                 rectv[rectidx2]))
          else
            area <- 0
          n_outside <- sum(
            Re(xy + offset - rectv / 2) < 0 | Re(xy +
                                                   offset + rectv / 2) > xyAspect |
              Im(xy + offset - rectv / 2) <
              0 | Im(xy + offset + rectv / 2) > 1 / xyAspect
          )
          res <- 1000 * area + n_outside
          res
        }
        xy <- x + (0 + 1i) * y
        rectv <- width + (0 + 1i) * height
        rectidx1 <- rectidx2 <- array(0, (length(x) ^ 2 - length(x)) / 2)
        k <- 0
        for (i in 1:length(x))
          for (j in seq(len = (i - 1))) {
            k <- k + 1
            rectidx1[k] <- i
            rectidx2[k] <- j
          }
        canIntersect <-
          rect_intersect(xy[rectidx1], 2 * rectv[rectidx1],
                         xy[rectidx2], 2 * rectv[rectidx2]) > 0
        rectidx1 <- rectidx1[canIntersect]
        rectidx2 <- rectidx2[canIntersect]
        if (trace)
          message("possible intersects =", length(rectidx1))
        if (trace)
          message("portion covered =", sum(rect_intersect(xy, rectv,
                                                          xy, rectv)))
        GA <- function() {
          n_startgenes <- 1000
          n_bestgenes <- 30
          prob <- 0.2
          mutate <- function(gene) {
            offset <- gen_offset(gene)
            doesIntersect <-
              rect_intersect(xy[rectidx1] + offset[rectidx1],
                             rectv[rectidx1], xy[rectidx2] + offset[rectidx2],
                             rectv[rectidx2]) > 0
            for (i in which(doesIntersect)) {
              gene[rectidx1[i]] <- sample(1:8, 1)
            }
            for (i in seq(along = gene))
              if (runif(1) <= prob)
                gene[i] <- sample(1:8, 1)
            gene
          }
          crossbreed <- function(g1, g2)
            ifelse(sample(c(0, 1),
                          length(g1), replace = TRUE) > 0.5, g1, g2)
          genes <- matrix(sample(1:8, n_labels * n_startgenes,
                                 replace = TRUE),
                          n_startgenes,
                          n_labels)
          for (i in 1:10) {
            scores <- array(0, NROW(genes))
            for (j in 1:NROW(genes))
              scores[j] <- objective(genes[j,])
            rankings <- order(scores)
            genes <- genes[rankings,]
            bestgenes <- genes[1:n_bestgenes,]
            bestscore <- scores[rankings][1]
            if (bestscore == 0) {
              if (trace)
                message("overlap area =", bestscore)
              break
            }
            genes <- matrix(0, n_bestgenes ^ 2, n_labels)
            for (j in 1:n_bestgenes)
              for (k in 1:n_bestgenes)
                genes[n_bestgenes *
                        (j - 1) + k,] <- mutate(crossbreed(bestgenes[j,], bestgenes[k,]))
            genes <- rbind(bestgenes, genes)
            if (trace)
              message("overlap area =", bestscore)
          }
          nx <- Re(xy + gen_offset(bestgenes[1,]))
          ny <- Im(xy + gen_offset(bestgenes[1,]))
          list(x = nx, y = ny)
        }
        SANN <- function() {
          gene <- rep(8, n_labels)
          score <- objective(gene)
          bestgene <- gene
          bestscore <- score
          T <- 2.5
          for (i in 1:50) {
            k <- 1
            for (j in 1:50) {
              newgene <- gene
              newgene[sample(1:n_labels, 1)] <- sample(1:8,
                                                       1)
              newscore <- objective(newgene)
              if (newscore <= score || runif(1) < exp((score -
                                                       newscore) / T)) {
                k <- k + 1
                score <- newscore
                gene <- newgene
              }
              if (score <= bestscore) {
                bestscore <- score
                bestgene <- gene
              }
              if (bestscore == 0 || k == 10)
                break
            }
            if (bestscore == 0)
              break
            if (trace)
              message("overlap area =", bestscore)
            T <- 0.9 * T
          }
          if (trace)
            message("overlap area =", bestscore)
          nx <- Re(xy + gen_offset(bestgene))
          ny <- Im(xy + gen_offset(bestgene))
          list(x = nx, y = ny)
        }
        if (method == "SANN")
          xy <- SANN()
        else
          xy <- GA()
        xy <- toUserCoords(xy)
        if (doPlot)
          return(xy)
        # invisible(xy)
      }

      #########################################################################################

      mm.pointLabels(x, y, cex = pie.radius * pie.space) -> xy

      if (link == TRUE) {
        segments(x,
                 y,
                 xy$x,
                 xy$y,
                 lwd = seg.lwd,
                 col = seg.col,
                 lty = seg.lty)
      }


      for (i in 1:length(xy$x)) {
        plotrix::floating.pie(
          xy$x[i],
          xy$y[i],
          x = as.numeric(pie.slices[i, ][pie.slices[i, ] != 0]),
          col = as.vector(pie.colors[i, ][pie.slices[i, ] != 0]),
          radius = pie.radius,
          shadow = FALSE
        )
      }
    } # end of if statement

    if (!is.null(coord)) {

      if (link == TRUE) {
        segments(x,
                 y,
                 coord[, 1],
                 coord[, 2],
                 lwd = seg.lwd,
                 col = seg.col,
                 lty = seg.lty)
      }

      for (i in 1:nrow(coord)) {
        plotrix::floating.pie(
          coord[i,1],
          coord[i,2],
          x = as.numeric(pie.slices[i, ][pie.slices[i, ] != 0]),
          col = as.vector(pie.colors[i, ][pie.slices[i, ] != 0]),
          radius = pie.radius,
          shadow = FALSE
        )
      }
    } # end of if statement

  }

