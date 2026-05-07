#' Adds a box to maps including antimeridian
#'
#' @description
#' Adds a box on maps including the antimeridian (180)
#'
#' @rdname mar_antimeridian_box
#' @usage
#' mar_antimeridian_box(object, tick.spacing)
#' @param object matrix of class bathy
#' @param tick.spacing spacing between tick marks (in degrees, default=20)
#'
#' @return
#' The function adds a box and tick marks to an existing plot which contains the antimeridian line (180 degrees).
#'
#' @author
#' Eric Pante & Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_plot_bathy}}
#'
#' @examples
#' data(aleutians)
#'
#' # default plot:
#' plot(aleutians,n=1)
#'
#' # plot with corrected box and labels:
#' plot(aleutians,n=1,axes=FALSE)
#' mar_antimeridian_box(aleutians, 10)
#' @export
#' @aliases antimeridian.box
mar_antimeridian_box <- function(object, tick.spacing=20){
	
	round(min(as.numeric(rownames(object))),2) -> lon.min
	round(max(as.numeric(rownames(object))),2) -> lon.max

	(lon.max-360) -> last.west

	lab.left <- rev(seq(180,lon.min,by=-tick.spacing))
	lab.right <- seq(-180, last.west, by=tick.spacing)[-1]
	lab <- c(lab.left,lab.right)
	n <- length(lab)
	
	lab2 <- lab
	lab2[lab2<0] <- lab2[lab2<0] + 360
	
	box()
	axis(2)
	axis(1, at=lab2, labels=lab)
}

#' @rdname mar_antimeridian_box
#' @export
antimeridian.box <- mar_antimeridian_box
