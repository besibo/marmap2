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
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # test class "bathy"
#' is_bathy(nw.atlantic)
#'
#' # use as_bathy
#' atl <- as_bathy(nw.atlantic)
#'
#' # class "bathy"
#' class(atl)
#' is_bathy(atl)
#'
#' # summarize data of class "bathy"
#' summary(atl)
#' @export
is_bathy = function(xyz){
	print(class(xyz) == "bathy")
}

