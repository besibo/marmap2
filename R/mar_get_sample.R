#' Get sample data by clicking on a map
#'
#' @description
#' Outputs sample information based on points selected by clicking on a map
#'
#' @rdname mar_get_sample
#' @usage
#' mar_get_sample(mat, sample, col.lon, col.lat, \dots)
#' @param mat bathymetric data matrix of class \code{bathy}, imported using \code{mar_read_bathy} (no default)
#' @param sample data.frame containing sampling information (at least longitude and latitude) (no default)
#' @param col.lon column number of data frame \code{sample} containing longitude information (no default)
#' @param col.lat column number of data frame \code{sample} containing latitude information (no default)
#' @param \dots further arguments to be passed to \code{\link{rect}} for drawing a box around the selected area
#'
#' @details
#' \code{mar_get_sample} allows the user to get sample data by clicking on a map created with \code{mar_plot_bathy}. This function uses the \code{locator} function (\code{graphics} package). After creating a map with \code{mar_plot_bathy}, the user can  click twice on the map to delimit an area (for example, lower left and upper right corners of a rectangular area of interest), and get a dataframe corresponding to the \code{sample} points present within the selected area.
#'
#' @return
#' a dataframe of the elements of \code{sample} present within the area selected
#'
#' @author
#' Eric Pante
#'
#' @seealso
#' \code{\link{mar_read_bathy}}, \code{\link{mar_summary_bathy}}, \code{\link{nw.atlantic}}, \code{\link{metallo}}
#'
#' @examples
#' \dontrun{
#' # load metallo sampling data and add a third field containing a specimen ID
#' data(metallo)
#' metallo$id <- factor(paste("Metallo",1:38))
#'
#' # load NW Atlantic data, convert to class bathy, and plot
#' data(nw.atlantic)
#' atl <- mar_as_bathy(nw.atlantic)
#' plot(atl, deep=-8000, shallow=0, step=1000, col="grey")
#'
#' # once the map is plotted, use mar_get_sample to get sampling info!
#' mar_get_sample(atl, metallo, 1, 2)
#' # click twice
#' }
#' @export
#' @aliases get.sample
mar_get_sample=function(mat, sample, col.lon, col.lat, ...){

	locator(n=2,type="n")->coord
	as.numeric(rownames(mat), na.rm=TRUE) -> lon
	as.numeric(colnames(mat), na.rm=TRUE) -> lat

	if(length(coord$x) == 1) {
		warning("Please choose two points from the map")
		}

	if(length(coord$x) == 2) {

		rect(min(coord$x),min(coord$y),max(coord$x),max(coord$y),...)

		which(abs(lon-coord$x[1])==min(abs(lon-coord$x[1]))) -> x1
		which(abs(lat-coord$y[1])==min(abs(lat-coord$y[1]))) -> y1
		which(abs(lon-coord$x[2])==min(abs(lon-coord$x[2]))) -> x2
		which(abs(lat-coord$y[2])==min(abs(lat-coord$y[2]))) -> y2

		new.bathy = mat[x1:x2, y1:y2]
		as.numeric(rownames(new.bathy), na.rm=TRUE) -> lon2
		as.numeric(colnames(new.bathy), na.rm=TRUE) -> lat2

		range(lon2) -> rlon2
		range(lat2) -> rlat2

		subset(sample, sample[,col.lon]>rlon2[1] & sample[,col.lat]>rlat2[1]) -> s1
		subset(s1, s1[,col.lon]<rlon2[2] & s1[,col.lat]<rlat2[2]) -> s2

			if(length(s2[,1]) == 0) message("No sample in the selected region")
			if(length(s2[,1]) != 0) return(droplevels(s2))


		}

}

#' @rdname mar_get_sample
#' @export
get.sample <- mar_get_sample
