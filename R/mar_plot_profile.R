#' Ploting bathymetric data along a transect or path
#'
#' @description
#' Plots the depth/altitude along a transect or path
#'
#' @rdname mar_plot_profile
#' @usage
#' mar_plot_profile(profile,shadow=TRUE,xlim,ylim,col.sea,col.bottom,xlab,ylab, \dots)
#' @param profile 4-columns matrix obtained from \code{mar_get_transect} with argument \code{dist=TRUE}, or from \code{mar_path_profile}.
#' @param shadow logical. Should the depth profile cast a shadow over the plot background?
#' @param xlim numeric vector of length 2 giving the x coordinate range. If unspecified, values are based on the length of the transect or path.
#' @param ylim numeric vector of length 2 giving the y coordinate range. If unspecified, values are based on the depth range of the bathymetric matrix \code{bathy}.
#' @param col.sea color for the sea area of the plot. Defaults to \code{rgb(130/255,180/255,212/255)}
#' @param col.bottom color for the bottom area of the plot. Defaults to \code{rgb(198/255,184/255,151/255)}
#' @param xlab title for the x axis. If unspecified, \code{xlab="Distance from start of transect (km)"}.
#' @param ylab title for the y axis. If unspecified, \code{ylab="Depth (m)"}.
#' @param \dots arguments to be passed to methods, such as \link{graphical parameters} (see \code{\link{par}})
#'
#' @return
#' a bivariate plot of depth against the kilometric distance from the starting point of a transect or least cost path.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_path_profile}}, \code{\link{mar_plot_bathy}}
#'
#' @examples
#' # Example 1:
#' 	data(celt)
#' 	layout(matrix(1:2,nc=1),height=c(2,1))
#' 	par(mar=c(4,4,1,1))
#' 	plot(celt,n=40,draw=TRUE)
#' 	points(c(-6.34,-5.52),c(52.14,50.29),type="o",col=2)
#'
#' 	tr <- mar_get_transect(celt, x1 = -6.34, y1 = 52.14, x2 = -5.52, y2 = 50.29, distance = TRUE)
#' 	mar_plot_profile(tr)
#'
#' # Example 2:
#' 	layout(matrix(1:2,nc=1),height=c(2,1))
#' 	par(mar=c(4,4,1,1))
#' 	plot(celt,n=40,draw=TRUE)
#' 	points(c(-5,-6.34),c(49.8,52.14),type="o",col=2)
#'
#' 	tr2 <- mar_get_transect(celt, x1 = -5, y1 = 49.8, x2 = -6.34, y2 = 52.14, distance = TRUE)
#' 	mar_plot_profile(tr2)
#'
#' # Example 3: click several times on the map and press ESC
#' \dontrun{
#' 	layout(matrix(1:2,nc=1),height=c(2,1))
#' 	par(mar=c(4,4,1,1))
#' 	data(florida)
#' 	plot(florida,image=TRUE,dra=TRUE,land=TRUE,n=40)
#'
#' 	out <- mar_path_profile(as.data.frame(locator(type="o",col=2,pch=19,cex=.8)),florida)
#' 	mar_plot_profile(out)
#' }
#' @export
#' @aliases plotProfile
mar_plot_profile <- function(profile,shadow=TRUE,xlim,ylim,col.sea,col.bottom,xlab,ylab,...){
	
	if (ncol(profile)!=4) stop("The profile object should have 4 columns (Longitude, Latitude, Kilomtric distance from start of path and Depth)")
	if (missing(xlim)) xlim <- range(profile[,3])
	if (missing(ylim)) ylim <- range(c(0,profile[,4]))
	if (missing(col.bottom)) col.bottom <- rgb(198,184,151,maxColorValue=255)
	if (missing(col.sea)) col.sea <- rgb(130,180,212,maxColorValue=255)
	if (missing(xlab)) xlab <- "Distance from start of transect (km)"
	if (missing(ylab)) ylab <- "Depth (m)"

	xlim[1] <- max(xlim[1],min(profile[,3]))
	xlim[2] <- min(xlim[2],max(profile[,3]))

	profile <- profile[,-(1:2)]
	end <- which.min(abs(profile[,1]-xlim[2]))
	start <- which.min(abs(profile[,1]-xlim[1]))
	profile[end,1] <- xlim[2]
	profile[start,1] <- xlim[1]
	profile <- profile[start:end,]

	profile.poly <- rbind(c(xlim[1],ylim[1]), profile, c(xlim[2],ylim[1]))
	
	plot(profile, type="n", pch=19, xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab, ...)
	polygon(matrix(c(xlim[1],0,xlim[1],ylim[1],xlim[2],ylim[1],xlim[2],0),byrow=TRUE,ncol=2),col=col.sea)
	abline(h=0,lwd=0.5, lty=1)
	if (shadow) lines(profile, col=rgb(110,110,110,.8,maxColorValue=255),lwd=4)
	polygon(profile.poly, col=col.bottom)
	polygon(matrix(c(xlim[1],ylim[1],xlim[1],ylim[1]-1000,xlim[2]+100,ylim[1]-1000,xlim[2]+100,ylim[1]),byrow=TRUE,ncol=2),col="white",border=NA)

	box()

}

#' @rdname mar_plot_profile
#' @export
plotProfile <- mar_plot_profile
