#' Adds alpha transparency to a (vector of) color(s)
#'
#' @description
#' Adds transparency to a color or a vector of colors by specifying one or several alpha values.
#'
#' @rdname mar_col2alpha
#' @usage
#' mar_col2alpha(color,alpha = 0.5)
#' @param color a (vector of) color codes or names
#' @param alpha a value (or vector of values) between 0 (full transparency) and 1 (no transparency).
#'
#' @details
#' When the size of \code{color} and \code{alpha} vectors are different, \code{alpha} values are recycled.
#'
#' @return
#' A (vector) of color code(s).
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @examples
#' # Generate random data
#' dat <- rnorm(4000)
#'
#' # plot with plain color for points
#' plot(dat,pch=19,col="red")
#'
#' # Add some transparency to get a better idea of density
#' plot(dat,pch=19,col=mar_col2alpha("red",.3))
#'
#' # Same color for all points but with increasing alpha (decreasing transparency)
#' plot(dat,pch=19,col=mar_col2alpha(rep("red",4000),seq(0,1,len=4000)))
#'
#' # Two colors, same alpha
#' plot(dat,pch=19,col=mar_col2alpha(rep(c("red","purple"),each=2000),.2))
#'
#' # Four colors, gradient of transparency for each color
#' plot(dat,pch=19,col=mar_col2alpha(rep(c("blue","purple","red","orange"),each=1000),seq(.1,.6,len=1000)))
#'
#' # Alpha transparency applied to a gradient of colors
#' plot(dat,pch=19,col=mar_col2alpha(rainbow(4000),.5))
#' @export
#' @aliases col2alpha
mar_col2alpha <- function(color, alpha = 0.5) {
	
	# Makes sure there is one alpha for each color
	if (length(alpha)!=length(color)) alpha <- rep(alpha,length(color))
	
	out <- numeric(length(color))
	for (i in 1:length(color)) {
		x <- col2rgb(color[i])[, 1]
		out[i] <- rgb(x[1], x[2], x[3], 255 * alpha[i], maxColorValue = 255)
	}
	out
}

#' @rdname mar_col2alpha
#' @export
col2alpha <- mar_col2alpha
