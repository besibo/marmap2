#' Bathymetric data for the Aleutians (Alaska)
#'
#' @description
#' Bathymetric matrix of class \code{bathy} created from NOAA GEODAS data.
#'
#' @name aleutians
#' @docType data
#' @usage
#' data(aleutians)
#'
#' @details
#' Data imported from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}) and transformed into an object of class \code{bathy} by \code{mar_as_bathy}.
#'
#' @return
#' A text file.
#'
#' @author
#' see \url{https://www.ncei.noaa.gov/maps/grid-extract/}
#'
#' @seealso
#' \code{\link{mar_as_bathy}}, \code{\link{mar_read_bathy}}, \code{\link{mar_antimeridian_box}}
#'
#' @examples
#' # load celt data
#' data(aleutians)
#'
#' # class "bathy"
#' class(aleutians)
#' summary(aleutians)
#'
#' # test mar_plot_bathy
#' plot(aleutians,image = TRUE,
#'      bpal = list(c(0,max(aleutians),"grey"),
#'                  c(min(aleutians),0,"darkblue","lightblue")),
#'      land = TRUE, lwd = 0.1, axes = FALSE)
#' mar_antimeridian_box(aleutians, 10)
NULL

#' Bathymetric data for the North Est Atlantic
#'
#' @description
#' Bathymetric matrix of class \code{bathy} created from NOAA GEODAS data.
#'
#' @name celt
#' @docType data
#' @usage
#' data(celt)
#'
#' @details
#' Data imported from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}) and transformed into an object of class \code{bathy} by \code{mar_as_bathy}.
#'
#' @return
#' A text file.
#'
#' @author
#' see \url{https://www.ncei.noaa.gov/maps/grid-extract/}
#'
#' @seealso
#' \code{\link{mar_as_bathy}}, \code{\link{mar_read_bathy}}
#'
#' @examples
#' # load celt data
#' data(celt)
#'
#' # class "bathy"
#' class(celt)
#' summary(celt)
#'
#' # test mar_plot_bathy
#' plot(celt, deep=-300, shallow=-50, step=25)
NULL

#' Bathymetric data around Florida, USA
#'
#' @description
#' Bathymetric object of class \code{bathy} created from NOAA GEODAS data.
#'
#' @name florida
#' @docType data
#' @usage
#' data(florida)
#'
#' @details
#' Data imported from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}) and transformed into an object of class \code{bathy} by \code{mar_read_bathy}.
#'
#' @return
#' A bathymetric object of class \code{bathy} with 539 rows and 659 columns.
#'
#' @author
#' see \url{https://www.ncei.noaa.gov/maps/grid-extract/}
#'
#' @seealso
#' \code{\link{mar_plot_bathy}}, \code{\link{mar_summary_bathy}}
#'
#' @examples
#' # load florida data
#' data(florida)
#'
#' # class "bathy"
#' class(florida)
#' summary(florida)
#'
#' # test mar_plot_bathy
#' plot(florida,asp=1)
#' plot(florida,asp=1,image=TRUE,drawlabels=TRUE,land=TRUE,n=40)
NULL

#' Bathymetric data for Hawaii, USA
#'
#' @description
#' Bathymetric object of class \code{bathy} created from NOAA GEODAS data and arbitrary locations around the main Hawaiian islands.
#'
#' @name hawaii
#' @aliases hawaii.sites
#' @docType data
#' @usage
#' data(hawaii)
#' data(hawaii.sites)
#'
#' @details
#' \code{hawaii} contains data imported from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}) and transformed into an object of class \code{bathy} by \code{mar_read_bathy}.
#' \code{hawaii.sites} is a 2-columns data.frame containing longitude and latitude of 6 locations spread at sea around Hawaii.
#'
#' @return
#' \code{hawaii}: a bathymetric object of class \code{bathy} with 539 rows and 659 columns.
#' \code{hawaii.sites}: data.frame (6 rows, 2 columns)
#'
#' @author
#' see \url{https://www.ncei.noaa.gov/maps/grid-extract/}
#'
#' @seealso
#' \code{\link{mar_plot_bathy}}, \code{\link{mar_summary_bathy}}
#'
#' @examples
#' # load hawaii data
#' 	data(hawaii)
#' 	data(hawaii.sites)
#'
#' # class "bathy"
#' 	class(hawaii)
#' 	summary(hawaii)
#'
#' \dontrun{
#' ## use of mar_plot_bathy to produce a bathymetric map
#' # creation of a color palette
#' 	pal <- colorRampPalette(c("black","darkblue","blue","lightblue"))
#'
#' # Plotting the bathymetry
#' 	plot(hawaii,image=TRUE,draw=TRUE,bpal=pal(100),asp=1,col="grey40",lwd=.7)
#'
#' # Adding coastline
#' 	require(mapdata)
#' 	map("worldHires",res=0,fill=TRUE,col=rgb(.8,.95,.8,.7),add=TRUE)
#'
#' # Adding hawaii.sites location on the map
#' 	points(hawaii.sites,pch=21,col="yellow",bg=mar_col2alpha("yellow",.9),cex=1.2)
#' }
NULL

#' Irregularly spaced bathymetric data.
#'
#' @description
#' Three-column data.frame of irregularly-spaced longitudes, latitudes and depths.
#'
#' @name irregular
#' @docType data
#' @usage
#' data(irregular)
#'
#' @return
#' A three-columns data.frame containing longitude, latitude and depth/elevation data.
#'
#' @author
#' Data modified form a dataset kindly provided by Noah Lottig from the university of Wisconsin \url{https://limnology.wisc.edu/staff/lottig-noah/} in the framework of the North Temperate Lakes Long Term Ecological Research program \url{https://lter.limnology.wisc.edu}
#'
#' @seealso
#' \code{\link{mar_griddify}}
#'
#' @examples
#' # load data
#' data(irregular)
#'
#' # use mar_griddify
#' reg <- mar_griddify(irregular, nlon = 40, nlat = 60)
#'
#' # switch to class "bathy"
#' class(reg)
#' bat <- mar_as_bathy(reg)
#' summary(bat)
#'
#' # Plot the new bathy object along with the original data
#' plot(bat, image = TRUE, lwd = 0.1)
#' points(irregular$lon, irregular$lat, pch = 19, cex = 0.3, col = mar_col2alpha(3))
NULL

#' Coral sampling information from the North West Atlantic
#'
#' @description
#' Coral sampling data from Thoma et al 2009 (MEPS)
#'
#' @name metallo
#' @docType data
#' @usage
#' data(nw.atlantic)
#'
#' @details
#' Sampling locations (longitude, latitude, depth in meters) for the deep-sea octocoral species Metallogorgia melanotrichos (see Thoma et al 2009 for details, including cruise information)
#'
#' @return
#' A 3-column data frame
#'
#' @references
#' Thoma, J. N., E. Pante, M. R. Brugler, and S. C. France. 2009. Deep-sea octocorals and antipatharians show no evidence of seamount-scale endemism in the NW Atlantic. Marine Ecology Progress Series 397:25-35. \doi{https://doi.org/10.3354/meps08318}
#'
#' @seealso
#' \code{\link{nw.atlantic}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' data(nw.atlantic,metallo)
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' ## the function plot below plots:
#' ## - the coastline in blue,
#' ## - isobaths between 8000-4000 in light grey,
#' ## - isobaths between 4000-500 in dark grey (to emphasize seamounts)
#'
#' # 1st example: function points uses first two columns ; 3rd column contains depth info
#' plot(atl, deep=c(-8000,-4000,0), shallow=c(-4000,-500,0), step=c(500,500,0),
#'  	 lwd=c(0.5,0.5,1.5),lty=c(1,1,1),
#'  	 col=c("grey80", "grey20", "blue"),
#'  	 drawlabels=c(FALSE,FALSE,FALSE) )
#' points(metallo, cex=1.5, pch=19,col=rgb(0,0,1,0.5))
#'
#' # 2nd example: plot points according to coordinates
#' plot(atl, deep=c(-8000,-4000,0), shallow=c(-4000,-500,0), step=c(500,500,0),
#'  	 lwd=c(0.5,0.5,1.5),lty=c(1,1,1),
#'  	 col=c("grey80", "grey20", "blue"),
#'  	 drawlabels=c(FALSE,FALSE,FALSE) )
#' subset(metallo, metallo$lon>-55) -> s # isolate points from the Corner Rise seamounts:
#' points(s, cex=1.5, pch=19,col=rgb(0,0,1,0.5)) # only plot those points
#'
#' # 3rd example: point colors corresponding to a depth gradient:
#' par(mai=c(1,1,1,1.5))
#' plot(atl, deep=c(-6500,0), shallow=c(-50,0), step=c(500,0),
#'      lwd=c(0.3,1), lty=c(1,1),
#'      col=c("black","black"),
#'      drawlabels=c(FALSE,FALSE,FALSE))
#'
#' max(metallo$depth, na.rm=TRUE) -> mx
#' colorRamp(c("white","lightyellow","lightgreen","blue","lightblue1","purple")) -> ramp
#' rgb( ramp(seq(0, 1, length = mx)), max = 255) -> blues
#'
#' points(metallo, col="black", bg=blues[metallo$depth], pch=21,cex=1.5)
#' require(shape); colorlegend(zlim=c(-mx,0), col=rev(blues), main="depth (m)",posx=c(0.85,0.88))
NULL

#' Bathymetric data for the North West Atlantic
#'
#' @description
#' Data imported from the NOAA GEODAS server
#'
#' @name nw.atlantic
#' @docType data
#' @usage
#' data(nw.atlantic)
#'
#' @details
#' Data imported from the NOAA Grid Extract webpage (\url{https://www.ncei.noaa.gov/maps/grid-extract/}). To prepare data from NOAA, fill the custom grid form, and choose "XYZ (lon,lat,depth)" as the "Output Grid Format", "No Header" as the "Output Grid Header", and either of the space, tab or comma as the column delimiter (either can be used, but "comma" is the default import format of \code{mar_read_bathy}). Choose "omit empty grid cells" to reduce memory usage.
#'
#' @return
#' A three-columns data.frame containing longitude, latitude and depth/elevation data.
#'
#' @author
#' see \url{https://www.ncei.noaa.gov/maps/grid-extract/}
#'
#' @seealso
#' \code{\link{mar_plot_bathy}}, \code{\link{mar_summary_bathy}}
#'
#' @examples
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # use mar_as_bathy
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' # class "bathy"
#' class(atl)
#' summary(atl)
#'
#' # test mar_plot_bathy
#' plot(atl, deep=-8000, shallow=-1000, step=1000)
NULL

#' Coastline data for the North West Atlantic
#'
#' @description
#' Coastline data for the North West Atlantic, as downloaded using the NOAA Coastline Extractor tool.
#'
#' @name nw.atlantic.coast
#' @docType data
#' @usage
#' data(nw.atlantic.coast)
#'
#' @details
#' Coastline data for the NW Atlantic was obtained using the NOAA Coastline Extractor tool. To get more coastline data, go to \url{https://shoreline.noaa.gov/ccoast.html}.
#'
#' @return
#' A 2-column data frame
#'
#' @references
#' see \url{https://shoreline.noaa.gov/ccoast.html}
#'
#' @seealso
#' \code{\link{nw.atlantic}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' data(nw.atlantic,nw.atlantic.coast)
#' atl <- mar_as_bathy(nw.atlantic)
#'
#' ## the function plot below plots only isobaths:
#' ## - isobaths between 8000-4000 in light grey,
#' ## - isobaths between 4000-500 in dark grey (to emphasize seamounts)
#'
#' plot(atl, deep=c(-8000,-4000), shallow=c(-4000,-500), step=c(500,500),
#'  	 lwd=c(0.5,0.5,1.5),lty=c(1,1,1),
#'  	 col=c("grey80", "grey20", "blue"),
#'  	 drawlabels=c(FALSE,FALSE,FALSE) )
#'
#' ## the coastline can be added from a different source,
#' ## and can therefore have a different resolution:
#' lines(nw.atlantic.coast)
#'
#' ## add a geographical reference on the coast:
#' points(-71.064,42.358, pch=19); text(-71.064,42.358,"Boston", adj=c(1.2,0))
NULL
