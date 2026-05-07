#' Test whether an object is of class bathy
#'
#' @description
#' Test whether an object is of class bathy
#'
#' @rdname mar_is_bathy
#' @usage
#' mar_is_bathy(xyz)
#' @param xyz three-column data.frame with longitude (x), latitude (y) and depth (z) (no default)
#'
#' @return
#' The function returns \code{TRUE} or \code{FALSE}
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{mar_as_bathy}}, \code{\link{mar_summary_bathy}}, \code{\link{mar_read_bathy}}
#'
#' @examples
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # test class "bathy"
#' mar_is_bathy(nw.atlantic)
#'
#' # use mar_as_bathy
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' # class "bathy"
#' class(atl)
#' mar_is_bathy(atl)
#'
#' # summarize data of class "bathy"
#' summary(atl)
#' @export
#' @aliases is.bathy
mar_is_bathy = function(xyz){
	print(class(xyz) == "bathy")
}

#' @rdname mar_is_bathy
#' @export
is.bathy <- mar_is_bathy
