#' Sort bathymetric data matrix by increasing latitude and longitude
#'
#' @description
#' Reads a bathymetric data matrix and orders its rows and columns by increasing latitude and longitude.
#'
#' @rdname mar_check_bathy
#' @usage
#' mar_check_bathy(x)
#' @param x a matrix
#'
#' @details
#' \code{mar_check_bathy} allows to sort rows and columns by increasing latitude and longitude, which is necessary for ploting with the function \code{image} (package \code{graphics}). \code{mar_check_bathy} is used within the \code{marmap} functions \code{mar_read_bathy} and \code{mar_as_bathy} (it is also used in \code{mar_get_noaa_bathy} through \code{mar_as_bathy}).
#'
#' @return
#' The output of \code{mar_check_bathy} is an ordered matrix.
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{mar_read_bathy}}, \code{\link{mar_as_bathy}}, \code{\link{mar_get_noaa_bathy}}
#'
#' @examples
#' matrix(1:100, ncol=5, dimnames=list(20:1, c(3,2,4,1,5))) -> a
#' mar_check_bathy(a)
#' @export
#' @aliases check.bathy
mar_check_bathy = function(x){
	order(as.numeric(colnames(x))) -> xc
	order(as.numeric(rownames(x))) -> xr
	x[xr, xc] -> sorted.x
	return(sorted.x)
}

#' @rdname mar_check_bathy
#' @export
check.bathy <- mar_check_bathy
