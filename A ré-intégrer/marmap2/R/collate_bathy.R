#' Collates two bathy matrices with data from either sides of the antimeridian
#'
#' @description
#' Collates two bathy matrices, one with longitude 0 to 180 degrees East, and the other with longitude 0 to 180 degrees West
#'
#' @rdname collate_bathy
#' @usage
#' collate_bathy(east,west)
#' @param east matrix of class \code{bathy} with eastern data (West of antimeridian)
#' @param west matrix of class \code{bathy} with western data (East of antimeridian)
#'
#' @details
#' This function is used internally by import functions when data are
#' downloaded from both sides of the antimeridian line (180 degrees longitude).
#' If, for example, data are downloaded for longitudes 170E-180 and 180-170W,
#' \code{collate_bathy()} creates a single matrix of class \code{bathy} with a
#' coordinate system going from 170 to 190 degrees longitude.
#'
#' \code{get_noaa()} deals with data from both sides of the antimeridian and does not need further processing with \code{collate_bathy()}.
#'
#' @return
#' A single matrix of class \code{bathy}. When plotting collated data with
#' \code{\link{geom_bathy}}, use \code{antimeridian = TRUE} to display western
#' longitude labels beyond 180 degrees.
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{get_noaa}}, \code{\link{get_gebco}}, \code{\link{geom_bathy}},
#' \code{\link{summary_bathy}}
#'
#' @examples
#' east <- as_bathy(data.frame(
#'   lon = rep(c(178, 179), each = 2),
#'   lat = rep(c(10, 11), times = 2),
#'   depth = c(-10, -20, -30, -40)
#' ))
#' west <- as_bathy(data.frame(
#'   lon = rep(c(-180, -179), each = 2),
#'   lat = rep(c(10, 11), times = 2),
#'   depth = c(-50, -60, -70, -80)
#' ))
#'
#' collate_bathy(east, west)
#' @export
collate_bathy <- function(east,west){
	as.numeric(rownames(west))+360 -> rownames(west)  # new coordinate system
	rbind(east, west) -> collated                     # collate the two matrices into one
	collated[unique(rownames(collated)), ]-> collated # remove the extra antimeridian line
	class(collated)<-"bathy"                          # assign the class bathy to new matrix c
	return(collated)
}
