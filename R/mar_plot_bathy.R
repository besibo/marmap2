#' Ploting bathymetric data
#'
#' @description
#' Plots contour map from bathymetric data matrix of class \code{bathy}
#'
#' @rdname mar_plot_bathy
#' @usage
#' \method{plot}{bathy}(x, image=FALSE, bpal=NULL, land=FALSE,
#'            deepest.isobath, shallowest.isobath, step, n=20,
#'            lwd=1, lty=1, col="black", default.col="white", drawlabels = FALSE,
#'            xlab="Longitude", ylab="Latitude", asp=1, \dots)
#' @param x bathymetric data matrix of class \code{bathy}, imported using \code{mar_read_bathy}
#' @param image whether or not to color depth layers (default is \code{FALSE})
#' @param bpal if image is \code{TRUE}, either \code{NULL} (default: a simple blue color palette is used), a vector of colors, or a list of depth bounds and colors (see below)
#' @param land whether or not to use topographic data that may be available in the \code{bathy} dataset (default is \code{FALSE})
#' @param deepest.isobath deepest isobath(s) to plot
#' @param shallowest.isobath shallowest isobath(s) to plot
#' @param step distance(s) between two isobaths
#' @param n if the user does not specify the range within which isobaths should be plotted, about \code{n} isobaths are automatically plotted within the depth range of the \code{bathy} matrix (default is 20).
#' @param lwd isobath line(s) width (default is 1)
#' @param lty isobath line type(s) (default is 1)
#' @param col isobath line color(s) (default is black)
#' @param default.col if image is \code{TRUE}, a color for the area of the matrix not bracketed by the list supplied to bpal (see below; default is \code{white})
#' @param drawlabels whether or not to plot isobath depth as a label (default is \code{FALSE}); may contain several elements
#' @param xlab label for the x axis of the plot
#' @param ylab label for the y axis of the plot
#' @param asp numeric, giving the aspect ratio y/x of the plot. See \code{\link{plot.window}}
#' @param \dots Other arguments to be passed either to \code{countour} (default) or to \code{image} when argument \code{image=TRUE}.
#'
#' @details
#' \code{mar_plot_bathy} uses the base \code{contour} and \code{image} functions. If a vector of isobath characteristics is provided, different types of isobaths can be added to the same plot using a single call of \code{mar_plot_bathy} (see examples)
#'
#' If \code{image=TRUE}, the user has three choices for colors: (1) bpal can be set to \code{NULL}, in which case a default blue color palette is generated; (2) colors can be user-defined as in example 4, in which case the palette can be generated with function \code{colorRampPalette} (colors are then supplied as a vector to \code{mar_plot_bathy}) ; (3) colors can be constrained to bathymetry- and/or topography. In this last case, a list of vectors is supplied to \code{mar_plot_bathy} (example 7): each vector corresponds to a bathymetry/topography layer (for example, one layer for bathymetry and one layer for topography). The first and second elements of the vector are the minimum and maximum bathymetry/topography, respectively. The other elements of the vector (3, onward) correspond to colors (see example 7).
#'
#' @return
#' a bathymetric map with isobaths
#'
#' @references
#' Eric Pante, Benoit Simon-Bouhet (2013) marmap: A Package for Importing, Plotting and Analyzing Bathymetric and Topographic Data in R. PLoS ONE 8(9): e73051. doi:10.1371/journal.pone.0073051. \url{https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0073051}
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_read_bathy}}, \code{\link{mar_summary_bathy}}, \code{\link{nw.atlantic}}, \code{\link{metallo}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' 	data(nw.atlantic)
#' 	atl <- mar_as_bathy(nw.atlantic)
#'
#' ## Example 1: a simple marine chart
#' 	plot(atl) # without specifying any isobath parameters
#' 	plot(atl, n=5, drawlabels=TRUE) # with about 5 isobaths
#' 	plot(atl, deep=-8000, shallow=0, step=1000) # with isobath parameters
#'
#' ## Example 2: taking advantage of multiple types of isobaths
#' 	plot(atl, deep=c(-8000,-2000,0), shallow=c(-2000,-100,0), step=c(1000,100,0),
#' 		 lwd=c(0.5,0.5,1),lty=c(1,1,1),col=c("grey80","red", "blue"),
#' 		 drawlabels=c(FALSE,FALSE,FALSE) )
#'
#' ## Example 3: plotting a colored map with the default color palette
#' 	plot(atl, image=TRUE, deep=c(-8000,0), shallow=c(-1000,0), step=c(1000,0),
#' 	     lwd=c(0.5,1), lty=c(1,1), col=c("grey","black"), drawlabels=c(FALSE,FALSE))
#'
#' ## Example 4: make a pretty custom color ramp
#' 	colorRampPalette(c("purple","lightblue","cadetblue2","cadetblue1","white")) -> blues
#'
#' 	plot(atl, image=TRUE, bpal=blues(100), deep=c(-6500,0), shallow=c(-50,0), step=c(500,0),
#' 	     lwd=c(0.3,1), lty=c(1,1), col=c("black","black"), drawlabels=c(FALSE,FALSE))
#'
#' 	mar_scale_bathy(atl, deg=3, x="bottomleft", inset=5)
#'
#' ## Example 5: add points corresponding to sampling locations
#' ##            point colors correspond to the sampling depth
#' 	par(mai=c(1,1,1,1.5))
#' 	plot(atl, deep=c(-4500,0), shallow=c(-50,0), step=c(500,0),
#' 	     lwd=c(0.3,1), lty=c(1,1), col=c("black","black"), drawlabels=c(FALSE,FALSE))
#'
#' 	# add a title to the plot
#' 	title(main="Distribution of coral samples\non the New England and Corner Rise seamounts")
#' 	# add a scale
#' 	mar_scale_bathy(atl, deg=3, x="bottomleft", inset=5)
#'
#' 	# add a geographical reference on the coast:
#' 	points(-71.064,42.358, pch=19)
#' 	text(-71.064,42.358,"Boston", adj=c(1.2,0))
#'
#' 	# prepare colors for the sampling locations:
#' 	data(metallo) ## see dataset metallo
#' 	max(metallo$depth, na.rm=TRUE) -> mx
#' 	colorRampPalette(c("white","lightyellow","lightgreen","blue","lightblue1","purple")) -> ramp
#' 	blues <- ramp(max(metallo$depth))
#'
#' 	# plot sampling locations:
#' 	points(metallo, col="black", bg=blues[metallo$depth], pch=21,cex=1.5)
#' 	library(shape)
#' 	colorlegend(zlim=c(-mx,0), col=rev(blues), main="depth (m)",posx=c(0.85,0.88))
#'
#' ## Example 6: use packages maps and mapdata in combination with marmap
#' 	# use maps and mapdata to plot the coast
#' 	library(maps)
#' 	library(mapdata)
#' 	map('worldHires',xlim=c(-75,-46),ylim=c(32,44), fill=TRUE, col="grey")
#' 	box();axis(1);axis(2)
#'
#' 	# add bathymetric data from 'bathy' data
#'     plot(atl, add=TRUE, lwd=.3, deep=-4500, shallow=-10, step=500,
#' 		drawlabel=FALSE, col="grey50")
#'
#' ## Example 7: provide a list of depths and colors to argument bpal to finely tune palette
#' 	# check out ?mar_palette_bathy to see details on how the palette is handled
#'
#' 	# creating depth-constrained palette for the ocean only
#' 	plot(atl, land = FALSE, n = 10, lwd = 0.5, image = TRUE,
#' 	     bpal = list(c(min(atl), 0, "purple", "blue", "lightblue")),
#' 	     default.col = "gray")
#'
#' 	# creating depth-constrained palette for 3 ocean "layers"
#' 	plot(atl, land = FALSE, n = 10, lwd = 0.7, image = TRUE,
#' 	     bpal = list(c(min(atl), -3000, "purple","blue","grey"),
#' 	                 c(-3000, -150, "white"),
#' 	                 c(-150, 0, "yellow", "green", "brown")),
#' 	     default.col = "grey")
#'
#' 	# creating depth-constrained palette for land and ocean
#' 	plot(atl, land = TRUE, n = 10, lwd = 0.7, image = TRUE,
#' 	     bpal = list(c(min(atl), 0, "purple", "blue", "lightblue"),
#' 	                 c(0, max(atl), "gray90", "gray10")))
#' @method plot bathy
#' @export
#' @aliases plot.bathy
plot.bathy <- function(x, image=FALSE, bpal=NULL, land=FALSE, deepest.isobath, shallowest.isobath, step, n=20, lwd=1, lty=1, col="black", default.col="white", drawlabels = FALSE, xlab="Longitude", ylab="Latitude", asp=1, ...){
	
	x->mat # S3 compatibility
	
	if (!missing("deepest.isobath")) {
		length(deepest.isobath) -> n.levels
	} else {
		n.levels <- 1
	}
	
	unique(as.numeric(rownames(mat))) -> lon
	unique(as.numeric(colnames(mat))) -> lat
	  
	if (land == FALSE) mat[mat >0] <- 0

	if (image == FALSE){

		if(n.levels == 1){
			if (!missing("deepest.isobath") | !missing("shallowest.isobath") | !missing("step")) {
				seq(deepest.isobath, shallowest.isobath, by=step) -> level.param
			} else {
				level.param <- pretty(range(mat,na.rm=TRUE),n=n)
			}
			contour(lon,lat,mat, levels=level.param, 
					lwd=lwd, lty=lty, col=col, drawlabels = drawlabels, 
					xlab=xlab, ylab=ylab, asp=asp,...)
			}
		
		if(n.levels > 1){
			seq(deepest.isobath[1], shallowest.isobath[1], by=step[1]) -> level.param
			contour(lon,lat,mat,levels=level.param,
					lwd=lwd[1], lty=lty[1], col=col[1], drawlabels = drawlabels[1], 
					xlab=xlab, ylab=ylab, asp=asp, ...)
			for(i in 2:n.levels){
				seq(deepest.isobath[i], shallowest.isobath[i], by=step[i]) -> level.param
				contour(lon,lat,mat,levels=level.param,
						lwd=lwd[i], lty=lty[i], col=col[i], drawlabels = drawlabels[i], add=TRUE)
				}	
			# box(); axis(1); axis(2)
			}
		}

	if (image == TRUE) {

		if (is.null(bpal)) {
			colorRampPalette(c("#245372","#4871D9","#7D86A1","white")) -> ramp
			bpal <- ramp(100)
			}
			
		if (is.list(bpal))	bpal <- mar_palette_bathy(mat, layers = bpal, land=land, default.col=default.col)

		if (n.levels == 1){
			if (!missing("deepest.isobath") | !missing("shallowest.isobath") | !missing("step")) {
				seq(deepest.isobath, shallowest.isobath, by=step) -> level.param
			} else {
				level.param <- pretty(range(mat,na.rm=TRUE),n=n)
			}
			image(lon,lat,mat, col=bpal, xlab=xlab, ylab=ylab, asp=asp, ...)
			contour(lon,lat,mat, levels=level.param, 
					lwd=lwd, lty=lty, col=col, drawlabels = drawlabels, add=TRUE)
			}
		
		if (n.levels > 1){
			image(lon,lat,mat, col=bpal, xlab=xlab, ylab=ylab, asp=asp, ...)
			seq(deepest.isobath[1], shallowest.isobath[1], by=step[1]) -> level.param
			contour(lon,lat,mat,levels=level.param,
					lwd=lwd[1], lty=lty[1], col=col[1], drawlabels = drawlabels[1], add=TRUE)
			for(i in 2:n.levels){
				seq(deepest.isobath[i], shallowest.isobath[i], by=step[i]) -> level.param
				contour(lon,lat,mat,levels=level.param,
						lwd=lwd[i], lty=lty[i], col=col[i], drawlabels = drawlabels[i], add=TRUE)
				}	
			}
		}
}

#' @rdname mar_plot_bathy
#' @export
mar_plot_bathy <- plot.bathy
