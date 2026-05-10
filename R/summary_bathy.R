#' Summary of bathymetric data of class \code{bathy}
#'
#' @description
#' Summary of bathymetric data of class \code{bathy}. Provides geographic bounds and resolution (in minutes) of the dataset, statistics on depth data, and a preview of the bathymetric matrix.
#'
#' @rdname summary_bathy
#' @param object object of class \code{bathy}
#' @param \dots additional arguments affecting the summary produced (see \code{base} function \code{summary}).
#'
#' @return
#' Information on the geographic bounds of the dataset (minimum and maximum latitude and longitude), resolution of the matrix in minutes, statistics on the depth data (e.g. min, max, median...), and a preview of the data.
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{read_bathy}}, \code{\link{as_bathy}},
#' \code{\link{bathy_to_tbl}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' bathy <- as_bathy(xyz)
#' summary(bathy)
#' @name summary_bathy
NULL

#' @export
#' @noRd
summary.bathy = function(object, ...){

	round(min(as.numeric(colnames(object))),2) -> lat.min
	round(max(as.numeric(colnames(object))),2) -> lat.max
	round(min(as.numeric(rownames(object))),2) -> lon.min
	round(max(as.numeric(rownames(object))),2) -> lon.max

	lon.max2 <- ifelse(lon.max > 180, lon.max-360, lon.max)
	flag.l1 <- ifelse(lon.min < 0, "W", "E")
	flag.l2 <- ifelse(lon.max2 < 0, "W", "E")

	flag.l3 <- ifelse(lat.min < 0, "S", "N")
	flag.l4 <- ifelse(lat.max < 0, "S", "N")

	one.minute = 0.016667
	as.numeric(rownames(object))[2] - as.numeric(rownames(object))[1] -> cell.size.centroid
	round(cell.size.centroid / one.minute, 2) -> cell.size.minute

	message(paste("Bathymetric data of class 'bathy', with",dim(object)[1],"rows and",dim(object)[2],"columns"))
	message(paste("Latitudinal range: ", lat.min," to ", lat.max, " (",abs(lat.min)," ",flag.l3," to ",abs(lat.max)," ",flag.l4,")",sep=""))
	message(paste("Longitudinal range: ", lon.min," to ", lon.max, " (",abs(lon.min)," ",flag.l1," to ",abs(lon.max2)," ",flag.l2,")",sep=""))
	message(paste("Cell size:",cell.size.minute,"minute(s)"))
	message("")
	message("Depth statistics:")
	print(summary(as.vector(object), ...))
	message("")
	message("First 5 columns and rows of the bathymetric matrix:")
	object[seq_len(min(5, nrow(object))), seq_len(min(5, ncol(object))), drop = FALSE]
}

#' @rdname summary_bathy
#' @export
summary_bathy <- summary.bathy
