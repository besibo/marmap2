#' Read bathymetric data from a GEBCO file
#'
#' @description
#' Imports 30-sec and 1-min bathymetric data from a .nc file downloaded on the GEBCO website.
#'
#' @rdname mar_read_gebco_bathy
#' @usage
#' mar_read_gebco_bathy(file, resolution = 1, sid = FALSE)
#' @param file name of the \code{.nc} file
#' @param resolution resolution of the grid, in units of the selected database (default is 1; see details)
#' @param sid logical. Is the data file containing SID information?
#'
#' @details
#' \code{mar_read_gebco_bathy} reads a 30 arcseconds or 1 arcminute bathymetry file downloaded from the GEBCO (General Bathymetric Chart of the Oceans) website (British Oceanographic Data Center). The website allows the download of bathymetric data in the netCDF format. \code{mar_read_gebco_bathy} uses the \code{ncdf4} package to load the data into R, and parses it into an object of class \code{bathy}.
#'
#' Data can be downloaded from the 30 arcseconds database (GEBCO_08) or the 1 arcminute database (GEBCO_1min, the default). A third database type, GEBCO_08 SID, is available from the website. This database includes a source identifier specifying which grid cells have depth information based on soundings ; it does not include bathymetry or topography data. \code{mar_read_gebco_bathy} can read this type of database when \code{sid} is set to \code{TRUE}. Then only the SID information will be included in the object of class \code{bathy}. Therefore, to display a map with both the bathymetry and the SID information, you will have to download both datasets from GEBCO, and import and plot both independently.
#'
#' The argument \code{resolution} specifies the resolution of the object of class \code{bathy}. Because the resolution of GEBCO data is rather fine, we offer the possibility of downsizing the dataset with \code{resolution}. \code{resolution} is in units of the selected database: in "GEBCO_1min", \code{resolution} is in minutes; in "GEBCO_08", \code{resolution} is in 30 arcseconds (that is, \code{resolution = 3} corresponds to 3x30sec, or 1.5 arcminute).
#'
#' @return
#' The output of \code{mar_read_gebco_bathy} is a matrix of class \code{bathy}, which dimensions depends on the resolution specified (one-minute, the original GEBCO resolution, is the default). The class \code{bathy} has its own methods for summarizing and ploting the data.
#'
#' @references
#' British Oceanographic Data Center: General Bathymetric Chart of the Oceans gridded bathymetric data sets (accessed July 10, 2020) \url{https://www.bodc.ac.uk/data/hosted_data_systems/gebco_gridded_bathymetry_data/}
#'
#'
#' General Bathymetric Chart of the Oceans website (accessed Oct 5, 2013) \url{https://www.gebco.net}
#'
#' David Pierce (2019). ncdf4: Interface to Unidata netCDF (Version 4 or Earlier) Format Data Files. R package version 1.17. https://cran.r-project.org/package=ncdf4
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_get_noaa_bathy}}, \code{\link{mar_read_bathy}}, \code{\link{mar_plot_bathy}}
#'
#' @examples
#' \dontrun{
#' # This example will not run, and we do not provide the dummy "gebco_file.nc" file,
#' # because a copyright license must be signed on the GEBCO website before the data can be
#' # downloaded and used. We just provide this line as an example for synthax.
#'   mar_read_gebco_bathy(file="gebco_file.nc", resolution=1) -> nw.atl
#'
#' # Second not-run example, with GEBCO_08 and SID:
#'   mar_read_gebco_bathy("gebco_08_7_38_10_43_corsica.nc") -> med
#'   summary(med) # the bathymetry data
#'
#'   mar_read_gebco_bathy("gebco_SID_7_38_10_43_corsica.nc")-> sid
#'   summary(sid) # the SID data
#'
#'   colorRampPalette(c("lightblue","cadetblue1","white")) -> blues # custom col palette
#'   plot(med, n=1, im=T, bpal=blues(100)) # bathymetry
#'
#'   as.numeric(rownames(sid)) -> x.sid
#'   as.numeric(colnames(sid)) -> y.sid
#'   contour(x.sid, y.sid, sid, drawlabels=FALSE, lwd=.1, add=TRUE) # SID
#' }
#' @export
#' @aliases readGEBCO.bathy
mar_read_gebco_bathy <- function(file, resolution=1, sid=FALSE){

	# require(ncdf)

	# check resolution value ## is.wholenumber function from is.integer {base}
	"Argument 'resolution' must be a positive integer\n" -> message
	is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol	
	# if resolution is <1 OR not a whole number:
	if(resolution<1 | !is.wholenumber(resolution)) stop(message) else {

		# get data from netCDF file
		nc <- ncdf4::nc_open(file)
		# ncells <- length(ncdf::get.var.ncdf(nc, "xysize"))
		if (sid) {
			z <- ncdf4::ncvar_get(nc,"sid")
		} else {
			z <- ncdf4::ncvar_get(nc,"elevation")
		}
		lat <- ncdf4::ncvar_get(nc, "lat")
		lon <- ncdf4::ncvar_get(nc, "lon")
	
		# dimensions of the matrix, depending on type of database
		# if(db == "GEBCO_1min") db.scale <- 1/60
		# if(db == "GEBCO_08")   db.scale <- 1/120
		# xdim <- seq(xrg[1],xrg[2], by=db.scale)
		# ydim <- seq(yrg[1],yrg[2], by=db.scale)
		
		# # for some reason sometimes the z vector is shorter than the product of the
		# # length of the latitude and longitude vectors
		# # so we check that z and xy are compatible, otherwise we crop the matrix dimentions.
		# if(length(xdim) * length(ydim) != ncells) {
		# 	warning("The number of cells in the .nc file (", ncells , ") do not correspond exactly to the range of latitude x longitude values (", length(xdim) * length(ydim), ")...\n  Cropping the matrix dimentions (see ?mar_read_gebco_bathy for details)...")
		# 	xdim<-xdim[-length(xdim)];ydim<-ydim[-length(ydim)] # removing last x and y values
		# }

		# build matrix 
		mat <- matrix(data=rev(z), nrow=length(lon),ncol=length(lat), byrow=F, dimnames=list(rev(lon),rev(lat)))
		# mat <- mat[,ncol(mat):1] # (merci benoit!)
		# rownames(mat) <- xdim
		# colnames(mat) <- ydim
		mat <- mar_check_bathy(mat[,ncol(mat):1])
	
		# adapt the resolution
		xindex <- seq(1,length(lon),by=resolution)
		yindex <- seq(1,length(lat),by=resolution)
		mat[xindex,yindex] -> final
		
		class(final) <- "bathy"
		return(final)
	}
}

#' @rdname mar_read_gebco_bathy
#' @export
readGEBCO.bathy <- mar_read_gebco_bathy
