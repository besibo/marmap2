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
#' This function is meant to be used with \code{read_bathy()} or \code{read_gebco_bathy()}, when data is downloaded from either sides of the antimeridian line (180 degrees longitude). If, for example, data is downloaded from GEBCO for longitudes of 170E-180 and 180-170W, \code{collate_bathy()} will create a single matrix of class \code{bathy} with a coordinate system going from 170 to 190 degrees longitude.
#'
#' \code{get_noaa()} deals with data from both sides of the antimeridian and does not need further processing with \code{collate_bathy()}.
#'
#' @return
#' A single matrix of class \code{bathy} that can be interpreted by \code{plot_bathy}. When plotting collated data (with longitudes 0 to 180 and 180 to 360 degrees), plots can be modified to display the conventional coordinate system (with longitudes 0 to 180 and -180 to 0 degrees) using function \code{antimeridian_box()}.
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{get_noaa}}, \code{\link{summary_bathy}}, \code{\link{plot_bathy}}, \code{\link{antimeridian_box}}
#'
#' @examples
#' ## faking two datasets using aleutians, for this example
#' ## "a" and "b" simulate two datasets downloaded from GEBCO, for ex.
#' 	data(aleutians)
#' 	aleutians[1:181,] -> a ; "bathy" -> class(a)
#' 	aleutians[182:601,] -> b ; "bathy" -> class(b)
#' 	-(360-as.numeric(rownames(b))) -> rownames(b)
#'
#' ## check these objects with summary(): pay attention of the Longitudinal range
#' 	summary(aleutians)
#' 	summary(a)
#' 	summary(b)
#'
#' ## merge datasets:
#' 	collate_bathy(a,b) -> collated
#' 	summary(collated) # should be identical to summary(aleutians)
#' @export
collate_bathy <- function(east,west){
	as.numeric(rownames(west))+360 -> rownames(west)  # new coordinate system
	rbind(east, west) -> collated                     # collate the two matrices into one
	collated[unique(rownames(collated)), ]-> collated # remove the extra antimeridian line
	class(collated)<-"bathy"                          # assign the class bathy to new matrix c
	return(collated)
}

