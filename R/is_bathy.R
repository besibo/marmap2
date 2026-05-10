#' Test whether an object is of class bathy
#'
#' @description
#' Test whether an object is of class bathy
#'
#' @rdname is_bathy
#' @usage
#' is_bathy(xyz)
#' @param xyz three-column data.frame with longitude (x), latitude (y) and depth (z) (no default)
#'
#' @return
#' The function returns \code{TRUE} or \code{FALSE}
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{as_bathy}}, \code{\link{summary_bathy}}, \code{\link{read_bathy}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' is_bathy(xyz)
#' is_bathy(as_bathy(xyz))
#' @export
is_bathy = function(xyz){
	print(class(xyz) == "bathy")
}
