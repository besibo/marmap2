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
#' \code{\link{summary_bathy}}, \code{\link{as_bathy}},
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
	bath <- bath[order(bath[, 2], bath[, 1], decreasing = FALSE), ]

    lat <- unique(bath[, 2]) ; bcol <- length(lat)
    lon <- unique(bath[, 1]) ; brow <- length(lon)

	if ((bcol*brow) == nrow(bath)) {
		mat <- matrix(bath[, 3], nrow = brow, ncol = bcol, byrow = FALSE, dimnames = list(lon, lat))
		} else {
			colnames(bath) <- paste("V",1:3,sep="")
			mat <- reshape2::acast(bath, V1~V2, value.var="V3")
		}
		
    ordered.mat <- check_bathy(mat)
    class(ordered.mat) <- "bathy"
    return(ordered.mat)
	
}
