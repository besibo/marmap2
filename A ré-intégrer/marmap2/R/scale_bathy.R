#' Adds a scale to a map
#'
#' @description
#' Uses geographic information from object of class \code{bathy} to calculate and plot a scale in kilometer.
#'
#' @rdname scale_bathy
#' @usage
#' scale_bathy(mat, deg=1, x="bottomleft", y=NULL, inset=10, angle=90, ...)
#' @param mat bathymetric data matrix of class \code{bathy}, imported using \code{read_bathy}
#' @param deg the number of degrees of longitudes to convert into kilometers (default is 1)
#' @param x longitude coordinate used to plot the scale on the map, or one of the supported position keywords (see Details).
#' @param y latitude coordinate used to plot the scale on the map. Use \code{NULL} when \code{x} is a position keyword.
#' @param inset when \code{x} is a keyword (e.g. \code{"bottomleft"}), \code{inset} is a percentage of the plotting space controlling the relative position of the plotted scale (see Examples)
#' @param angle angle from the shaft of the arrow to the edge of the arrow head
#' @param ... further arguments to be passed to \code{text}
#'
#' @details
#' \code{scale_bathy} is a simple utility to add a scale to the lower left corner of a \code{bathy} plot. The distance in kilometers between two points separated by 1 degree longitude is calculated based on the minimum latitude of the \code{bathy} object used to plot the map. Option \code{deg} allows the user to plot the distance separating more than one degree (default is one).
#'
#' The plotting coordinates \code{x} and \code{y} either correspond to two points on the map (i.e. longitude and latitude of the point where the scale should be plotted), or correspond to a keyword (set with \code{x}, \code{y} being set to \code{NULL}) from the list "bottomright", "bottomleft", "topright", "topleft". When a keyword is used, the option \code{inset} controls how far the scale will be from the edges of the plot.
#'
#' @return
#' a scale added to the active graphical device
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{plot_bathy}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' 	data(nw.atlantic)
#' 	atl <- as_bathy(nw.atlantic)
#'
#' # a simple example
#' 	plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
#' 	scale_bathy(atl, deg=4)
#'
#' # using keywords to place the scale with inset=10%
#' 	par(mfrow=c(2,2))
#' 	plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
#' 	scale_bathy(atl, deg=4, x="bottomleft", y=NULL)
#' 	plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
#' 	scale_bathy(atl, deg=4, x="bottomright", y=NULL)
#'
#' # using keywords to place the scale with inset=20%
#' 	plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
#' 	scale_bathy(atl, deg=4, x="topleft", y=NULL, inset=20)
#' 	plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
#' 	scale_bathy(atl, deg=4, x="topright", y=NULL, inset=20)
#' @export
scale_bathy = function (mat, deg=1, x="bottomleft", y=NULL, inset=10, angle=90, ...) {
			
	usr=par("usr")
	
	if(is.numeric(x) == TRUE & is.null(y)==FALSE) {
		x->X
		y->Y		
		abs(Y) -> lat
	}
	
	if(is.numeric(x) == FALSE & is.null(y)==TRUE) {
		insetx = abs((usr[2]-usr[1])*inset/100)
		insety = abs((usr[4]-usr[3])*inset/100)
	    X <- switch(x,  bottomright = (usr[2]-insetx-deg), 
	    				topright = (usr[2]-insetx-deg), 
	    				bottomleft = (usr[1]+insetx),
	    				topleft = (usr[1]+insetx) )
	    Y <- switch(x,  bottomright = (usr[3]+insety), 
	    				topright = (usr[4]-insety),
	    				bottomleft = (usr[3]+insety),
	    				topleft = (usr[4]-insety) )
	    lat<- switch(x, bottomright = abs(min(as.numeric(colnames(mat)))), 
	    				topright =    abs(max(as.numeric(colnames(mat)))), 
	    				bottomleft =  abs(min(as.numeric(colnames(mat)))),
	    				topleft =     abs(max(as.numeric(colnames(mat)))) )
	}
     
	cos.lat <- cos((2 * pi * lat)/360)
	perdeg <- (2 * pi * (6372.798 + 21.38 * cos.lat) * cos.lat)/360
          	
	arrows(X, Y, X+(deg),Y, code=3, length=0.05, angle=angle)
	text((X + X+(deg))/2, Y, 
			adj=c(0.5,-0.5),
			labels=paste(round(perdeg*deg,0),"km"), ...)	
	
}

