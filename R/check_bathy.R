#' Sort bathymetric data matrix by increasing latitude and longitude
#'
#' @description
#' Reads a bathymetric data matrix and orders its rows and columns by increasing latitude and longitude.
#'
#' @rdname check_bathy
#' @usage
#' check_bathy(x)
#' @param x a matrix
#'
#' @details
#' \code{check_bathy} allows to sort rows and columns by increasing latitude and longitude, which is necessary for ploting with the function \code{image} (package \code{graphics}). \code{check_bathy} is used within the \code{marmap} functions \code{read_bathy} and \code{as_bathy} (it is also used in \code{get_noaa} through \code{as_bathy}).
#'
#' @return
#' The output of \code{check_bathy} is an ordered matrix.
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{read_bathy}}, \code{\link{as_bathy}}, \code{\link{get_noaa}}
#'
#' @examples
#' matrix(1:100, ncol=5, dimnames=list(20:1, c(3,2,4,1,5))) -> a
#' check_bathy(a)
#' @export
check_bathy = function(x){
	order(as.numeric(colnames(x))) -> xc
	order(as.numeric(rownames(x))) -> xr
	x[xr, xc] -> sorted.x
	return(sorted.x)
}

