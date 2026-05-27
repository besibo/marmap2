#' Convert to xyz format
#'
#' @description
#' Converts bathymetric data into a three-column data.frame containing
#' longitude, latitude and depth data.
#'
#' @rdname as_xyz
#' @usage
#' as_xyz(x, lon = "lon", lat = "lat", depth = "depth", names = c("V1", "V2", "V3"))
#' @param x A matrix of class \code{bathy}, or a data.frame/tibble containing
#' longitude, latitude and depth columns.
#' @param lon,lat,depth Column names used when \code{x} is a data.frame or
#' tibble.
#' @param names Names to use for the output columns. Defaults to the historical
#' \code{c("V1", "V2", "V3")} xyz format.
#'
#' @details
#' The xyz format is a simple three-column export format used by several
#' historical bathymetry workflows and external software. For objects of class
#' \code{bathy}, rows and columns are expanded to longitude, latitude and depth.
#' For data.frames and tibbles, the selected columns are copied in their current
#' row order.
#'
#' For new analyses within R, prefer tibbles with explicit \code{lon},
#' \code{lat} and \code{depth} columns. Use \code{as_xyz()} when an external
#' tool expects a plain xyz file or table.
#'
#' @return
#' Three-column data.frame with a format similar to xyz files downloaded from
#' the NOAA Grid Extract webpage
#' (\url{https://www.ncei.noaa.gov/maps/grid-extract/}). The first column
#' contains longitude data, the second contains latitude data and the third
#' contains depth/elevation data.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{as_bathy}}, \code{\link{bathy_to_tbl}},
#' \code{\link{tbl_to_bathy}}, \code{\link{summarise_bathy}}
#'
#' @examples
#' xyz <- data.frame(
#'   lon = rep(c(-5, -4, -3), each = 3),
#'   lat = rep(c(48, 49, 50), times = 3),
#'   depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
#' )
#'
#' bathy <- as_bathy(xyz)
#' as_xyz(bathy)
#' as_xyz(xyz)
#' @export
as_xyz <- function(x, lon = "lon", lat = "lat", depth = "depth",
                   names = c("V1", "V2", "V3")) {

	if (!is.character(names) || length(names) != 3 || any(is.na(names))) {
		stop("names must be a character vector of length 3")
	}

	if (is(x, "bathy")) {
		lon_values <- as.numeric(rownames(x))
		lat_values <- as.numeric(colnames(x))

		xyz <- data.frame(expand.grid(lon_values, lat_values), as.vector(x))
		xyz <- xyz[order(xyz[, 2], decreasing = TRUE), ]
		names(xyz) <- names
		rownames(xyz) <- seq_len(nrow(xyz))

		return(xyz)
	}

	if (!inherits(x, "data.frame")) {
		stop("x must be an object of class bathy, or a data.frame or tibble")
	}

	columns <- c(lon, lat, depth)
	if (!is.character(columns) || length(columns) != 3 || any(is.na(columns))) {
		stop("lon, lat and depth must be single, non-missing column names")
	}

	missing_columns <- setdiff(columns, colnames(x))
	if (length(missing_columns) > 0) {
		stop(
			"x must contain columns ",
			paste(shQuote(missing_columns), collapse = ", ")
		)
	}

	xyz <- data.frame(
		x[[lon]],
		x[[lat]],
		x[[depth]]
	)
	names(xyz) <- names
	rownames(xyz) <- seq_len(nrow(xyz))

	return(xyz)
}
