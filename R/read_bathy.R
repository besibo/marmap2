#' Read bathymetric data in XYZ format
#'
#' @description
#' Reads a three-column table containing longitude (x), latitude (y) and depth (z) data.
#'
#' @rdname read_bathy
#' @usage
#' read_bathy(xyz, header = FALSE, sep = ",", ...)
#' @param xyz three-column table with longitude (x), latitude (y) and depth (z) (no default)
#' @param header whether this table has a row of column names (default = FALSE)
#' @param sep character separating columns, (default=",")
#' @param ... further arguments to be passed to \code{read.table()}
#'
#' @return
#' The output of \code{read_bathy} is a matrix of class \code{bathy}. Its
#' dimensions depend on the resolution and extent of the input xyz table.
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{summarise_bathy}}, \code{\link{as_bathy}},
#' \code{\link{bathy_to_tbl}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' tmp <- tempfile(fileext = ".csv")
#' write.table(xyz, tmp, sep = ",", quote = FALSE, row.names = FALSE)
#' bathy <- read_bathy(tmp, header = TRUE)
#' class(bathy)
#' @export
read_bathy <- function(xyz, header=FALSE, sep=",", ...){

### xyz: three-column table with longitude (x), latitude (y) and depth (z) (no default)
### header: whether this table has a row of column names (default = FALSE)
### sep: character separating columns, (default=",")

	bath <- read.table(xyz, header = header, sep = sep, ...)
	mat <- xyz_to_bathy_matrix(bath)
		
    ordered.mat <- check_bathy(mat)
    class(ordered.mat) <- "bathy"
    return(ordered.mat)
	
}
