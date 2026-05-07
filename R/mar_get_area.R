#' Get projected surface area
#'
#' @description
#' Get projected surface area for specific depth layers
#'
#' @rdname mar_get_area
#' @usage
#' mar_get_area(mat, level.inf, level.sup=0, xlim=NULL, ylim=NULL)
#' @param mat bathymetric data matrix of class \code{bathy}, imported using \code{mar_read_bathy} (no default)
#' @param level.inf lower depth limit for calculation of projected surface area (no default)
#' @param level.sup upper depth limit for calculation of projected surface area (default is zero)
#' @param xlim longitudinal range of the area of interest (default is \code{NULL})
#' @param ylim latitudinal range of the area of interest (default is \code{NULL})
#'
#' @details
#' \code{mar_get_area} calculates the projected surface area of specific depth layers (e.g. upper bathyal, lower bathyal), the projected plane being the ocean surface. The resolution of \code{mar_get_area} depends on the resolution of the input bathymetric data. \code{xlim} and \code{ylim} can be used to restrict the area of interest. Area calculation is based on \code{areaPolygon} of package \code{geosphere} (using an average Earth radius of 6,371 km).
#'
#' @return
#' A list of four objects: the projeced surface area in squared kilometers, a matrix with the cells used for calculating the projected surface area, the longitude and latitude of the matrix used for the calculations.
#'
#' @author
#' Benoit Simon-Bouhet and Eric Pante
#'
#' @seealso
#' \code{\link{mar_plot_area}}, \code{\link{mar_plot_bathy}}, \code{\link{contour}}, \code{\link[geosphere]{areaPolygon}}
#'
#' @examples
#' ## get area for the entire hawaii dataset:
#' 	data(hawaii)
#' 	plot(hawaii, lwd=0.2)
#'
#' 	mesopelagic <- mar_get_area(hawaii, level.inf=-1000, level.sup=-200)
#' 	bathyal <- mar_get_area(hawaii, level.inf=-4000, level.sup=-1000)
#' 	abyssal <- mar_get_area(hawaii, level.inf=min(hawaii), level.sup=-4000)
#'
#' 	col.meso <- rgb(0.3, 0, 0.7, 0.3)
#' 	col.bath <- rgb(0.7, 0, 0, 0.3)
#' 	col.abys <- rgb(0.7, 0.7, 0.3, 0.3)
#'
#' 	mar_plot_area(mesopelagic, col = col.meso)
#' 	mar_plot_area(bathyal, col = col.bath)
#' 	mar_plot_area(abyssal, col = col.abys)
#'
#' 	me <- round(mesopelagic$Square.Km, 0)
#' 	ba <- round(bathyal$Square.Km, 0)
#' 	ab <- round(abyssal$Square.Km, 0)
#'
#' 	legend(x="bottomleft",
#' 		legend=c(paste("mesopelagic:",me,"km2"),
#' 		         paste("bathyal:",ba,"km2"),
#' 		         paste("abyssal:",ab,"km2")),
#' 		col="black", pch=21,
#' 		pt.bg=c(col.meso,col.bath,col.abys))
#'
#' # Use of xlim and ylim
#' 	data(hawaii)
#' 	plot(hawaii, lwd=0.2)
#'
#' 	mesopelagic <- mar_get_area(hawaii, xlim=c(-161.4,-159), ylim=c(21,23),
#' 	                        level.inf=-1000, level.sup=-200)
#' 	bathyal <- mar_get_area(hawaii, xlim=c(-161.4,-159), ylim=c(21,23),
#' 	                        level.inf=-4000, level.sup=-1000)
#' 	abyssal <- mar_get_area(hawaii, xlim=c(-161.4,-159), ylim=c(21,23),
#' 	                        level.inf=min(hawaii), level.sup=-4000)
#'
#' 	col.meso <- rgb(0.3, 0, 0.7, 0.3)
#' 	col.bath <- rgb(0.7, 0, 0, 0.3)
#' 	col.abys <- rgb(0.7, 0.7, 0.3, 0.3)
#'
#' 	mar_plot_area(mesopelagic, col = col.meso)
#' 	mar_plot_area(bathyal, col = col.bath)
#' 	mar_plot_area(abyssal, col = col.abys)
#'
#' 	me <- round(mesopelagic$Square.Km, 0)
#' 	ba <- round(bathyal$Square.Km, 0)
#' 	ab <- round(abyssal$Square.Km, 0)
#'
#' 	legend(x="bottomleft",
#' 		legend=c(paste("mesopelagic:",me,"km2"),
#' 		         paste("bathyal:",ba,"km2"),
#' 		         paste("abyssal:",ab,"km2")),
#' 		col="black", pch=21,
#' 		pt.bg=c(col.meso,col.bath,col.abys))
#' @export
#' @aliases get.area
mar_get_area <- function(mat, level.inf, level.sup=0, xlim=NULL, ylim=NULL) {

	# require(geosphere)

	if (!is(mat,"bathy") & !is(mat,"buffer")) stop("mat must be of class 'bathy' or 'buffer'")

	if (is(mat,"buffer")) mat <- mat[[1]]

	lon <- as.numeric(rownames(mat))
	lat <- as.numeric(colnames(mat))

	if (is.null(xlim)) xlim <- range(lon)
	if (is.null(ylim)) ylim <- range(lat)
	if (any(is.na(mat))) mat[is.na(mat)] <- 100000*max(mat,na.rm=TRUE)

	x1b <- which.min(abs(lon - xlim[1]))
	y1b <- which.min(abs(lat - ylim[1]))
	x2b <- which.min(abs(lon - xlim[2]))
	y2b <- which.min(abs(lat - ylim[2]))

	mat <- mat[x1b:x2b, y1b:y2b]
	lon <- as.numeric(rownames(mat))
	lat <- as.numeric(colnames(mat))

	cell.width <- (lon[2] - lon[1])
	cell.height <- (lat[2] - lat[1])

	bathy2 <- ifelse(mat >= level.inf & mat <= level.sup, 1, 0)
	cells <- apply(bathy2,2,sum)
	cells <- cells[cells!=0]
	c.lat <- as.numeric(names(cells))

	poly <- list()
	for (i in 1:length(cells))
		poly[[i]] <- rbind(	c(0,c.lat[i]),
							c(0,c.lat[i]+cell.height),
							c(cells[i]*cell.width,c.lat[i]+cell.height),
							c(cells[i]*cell.width,c.lat[i])
							)

	surf <- sum(sapply(poly,geosphere::areaPolygon))
	return <- list(Square.Km=surf/1000000, Area=bathy2, Lon=lon, Lat=lat)

}

#' @rdname mar_get_area
#' @export
get.area <- mar_get_area
