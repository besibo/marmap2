#' Geographic coordinates, kilometric distance and depth along a path
#'
#' @description
#' Computes and plots the depth/altitude along a transect or path
#'
#' @rdname path_profile
#' @usage
#' path_profile(path,bathy,plot=FALSE, \dots)
#' @param path 2-columns matrix of longitude and latitude as obtained from \code{least_cost_distance} with argument \code{dist=TRUE}.
#' @param bathy bathymetric data matrix of class \code{bathy}.
#' @param plot logical. Should the depth profile be plotted?
#' @param \dots when \code{plot=TRUE}, other arguments to be passed to \code{plot_profile}, such as \link{graphical parameters} (see \code{\link{par}} and \code{\link{plot_profile}}).
#'
#' @return
#' a four-columns matrix containing longitude, latitude, kilometric distance from the start of a route and depth for a set of points along a route. Optionally (i.e. when \code{plot=TRUE}) a bivariate plot of depth against the kilometric distance from the starting point of a transect or least cost path.
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{plot_profile}}
#'
#' @examples
#' # Loading an object of class bathy and a data.frame of locations
#' 	require(mapdata)
#' 	data(hawaii)
#' 	data(hawaii.sites)
#'
#' # Preparing a color palette for the bathymetric map
#' 	pal <- colorRampPalette(c("black","darkblue","blue","lightblue"))
#'
#' # Plotting the bathymetric data and the path between locations
#' # (the path starts on location 1)
#' 	plot(hawaii,image=TRUE,bpal=pal(100),col="grey40",lwd=.7,
#' 	     main="Bathymetric map of Hawaii")
#' 	map("worldHires",res=0,fill=TRUE,col=rgb(.8,.95,.8,.7),add=TRUE)
#' 	lines(hawaii.sites,type="o",lty=2,lwd=2,pch=21,
#' 	      col="yellow",bg=color_to_alpha("yellow",.9),cex=1.2)
#' 	text(hawaii.sites[,1], hawaii.sites[,2],
#' 	     lab=rownames(hawaii.sites),pos=c(3,3,4,4,1,2),col="yellow")
#'
#' # Computing and plotting the depth profile for this path
#' 	profile <- path_profile(hawaii.sites,hawaii,plot=TRUE,
#' 	                        main="Depth profile along the path\nconnecting the 6 sites")
#' 	summary(profile)
#' @export
path_profile <- function(path,bathy,plot=FALSE,...) {

  if (!is(bathy, "bathy")) stop("Object bathy is not of class bathy")
	if (ncol(path)!=2) stop("Object path should have 2 columns: Longitude and Latitude")

	out <- matrix(0,ncol=4)
	colnames(out) <- c("lon","lat","dist.km","depth")

	for (i in 1:(nrow(path)-1)) {
		df <- get_transect(mat=bathy, x1=path[i,1], y1=path[i,2],x2=path[i+1,1],y2=path[i+1,2],distance=TRUE)
		# df <- df[-1,]
		df[,3] <- df[,3] + out[nrow(out),3]
		out <- rbind(out,df)
	}

	out <- unique(out[-1,])

	if (plot){
		dev.new()
		plot_profile(out,...)
	}
	return(out)
}

