#' Finds matrix diagonal for non-square matrices
#'
#' @description
#' Finds either the values of the coordinates of the non-linear diagonal of non-square matrices.
#'
#' @rdname mar_diag_bathy
#' @usage
#' mar_diag_bathy(mat,coord=FALSE)
#' @param mat a data matrix
#' @param coord whether of not to output the coordinates of the diagonal (default is \code{FALSE})
#'
#' @details
#' mar_diag_bathy gets the values or coordinates from the first element of a matrix to its last elements. If the matrix is non-square, that is, its number of rows and columns differ, mar_diag_bathy computes an approximate diagonal.
#'
#' @return
#' A vector of diagonal values is \code{coord} is \code{FALSE}, or a table of diagonal coordinates if\code{coord} is \code{FALSE}
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{mar_get_transect}}, \code{\link{diag}}
#'
#' @examples
#' # a square matrix: mar_diag_bathy behaves as diag
#' 	matrix(1:25, 5, 5) -> a ; a
#' 	diag(a)
#' 	mar_diag_bathy(a)
#'
#' # a non-square matrix: mar_diag_bathy does not behaves as diag
#' 	matrix(1:15, 3, 5) -> b ; b
#' 	diag(b)
#' 	mar_diag_bathy(b)
#'
#' # output the diagonal or its coordinates:
#' 	rownames(b) <- seq(32,35, length.out=3)
#' 	colnames(b) <- seq(-100,-95, length.out=5)
#' 	mar_diag_bathy(b, coord=FALSE)
#' 	mar_diag_bathy(b, coord=TRUE)
#' @export
#' @aliases diag.bathy
mar_diag_bathy=function(mat,coord=FALSE){ ## internal function for approximate diagonal calculation

	as.numeric(rownames(mat)) -> lon
	as.numeric(colnames(mat)) -> lat

	m=nrow(mat) # lon
	n=ncol(mat) # lat
	
	coord.m = round(seq(1,m,length.out=max(m,n)), 0)
	coord.n = round(seq(1,n,length.out=max(m,n)), 0)
	
	data.frame(lon[coord.m], lat[coord.n]) -> coord.tab
	names(coord.tab) <- c("lon","lat")
	
	dia=NULL
	for(i in 1:max(m,n)){
		dia = c(dia, mat[coord.m[i], coord.n[i]])
	}
	
	if(coord == FALSE) return(dia) else return(coord.tab)

}

#' @rdname mar_diag_bathy
#' @export
diag.bathy <- mar_diag_bathy
