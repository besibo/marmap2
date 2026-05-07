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
#' The output of \code{read_bathy} is a matrix of class \code{bathy}, which dimensions depends on the resolution of the grid uploaded from the NOAA GEODAS server (Grid Cell Size). The class \code{bathy} has its own methods for summarizing and ploting the data.
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{summary_bathy}}, \code{\link{plot_bathy}}, \code{\link{read_gebco_bathy}}
#'
#' @examples
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # write example file to disk
#' write.table(nw.atlantic, "NW_Atlantic.csv", sep=",", quote=FALSE, row.names=FALSE)
#'
#' # use read_bathy
#' read_bathy("NW_Atlantic.csv", header=TRUE) -> atl
#'
#' # remove temporary file
#' system("rm NW_Atlantic.csv") # remove file, for unix-like systems
#'
#' # class "bathy"
#' class(atl)
#'
#' # summarize data of class "bathy"
#' summary(atl)
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

