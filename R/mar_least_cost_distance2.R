#' Computes least cost distances between two or more locations
#'
#' @description
#' Computes least cost distances between two or more locations
#'
#' @rdname mar_least_cost_distance2
#' @usage
#' mar_least_cost_distance2(trans, loc, res = c("dist", "path"), unit = "meter", speed = 8, round = 0)
#' @param trans transition object as computed by \code{mar_transition_matrix}
#' @param loc A two-columns matrix or data.frame containing latitude and longitude for 2 or more locations.
#' @param res either \code{"dist"} or \code{"path"}. See details.
#' @param unit Character. The unit in which the results should be provided. Possible values are: `"meter"` (default), `"km"` (kilometers), `"miles"`, `"nmiles"` (nautic miles), `"hours"` or `"hours.min"` (hours and minutes).
#' @param speed Speed in knots (nautic miles per hour). Used only to compute distances when `unit = "hours"` or `unit = "hours.min"`
#' @param round integer indicating the number of decimal places to be used for printing results when \code{res = "dist"}.
#'
#' @details
#' \code{mar_least_cost_distance2} computes least cost distances between 2 or more locations. This function relies on the package \code{gdistance} (van Etten, 2011. \url{https://CRAN.R-project.org/package=gdistance}) and on the \code{mar_transition_matrix} function to define a range of depths where the paths are possible.
#'
#' @return
#' Results can be presented either as a kilometric distance matrix between all possible pairs of locations (argument \code{res="dist"}) or as a list of paths (i.e. 2-columns matrices of routes) between pairs of locations (\code{res="path"}).
#'
#' @references
#' Jacob van Etten (2011). gdistance: distances and routes on geographical grids. R package version 1.1-2.  \url{https://CRAN.R-project.org/package=gdistance}
#'
#' @author
#' Benoit Simon-Bouhet and Eric Pante
#'
#' @seealso
#' \code{\link{mar_transition_matrix}}, \code{\link{mar_least_cost_distance}}
#'
#' @examples
#' # Load and plot bathymetry
#' 	data(hawaii)
#' 	pal <- colorRampPalette(c("black","darkblue","blue","lightblue"))
#' 	plot(hawaii,image=TRUE,bpal=pal(100),asp=1,col="grey40",lwd=.7,
#' 	     main="Bathymetric map of Hawaii")
#'
#' # Load and plot several locations
#' 	data(hawaii.sites)
#' 	sites <- hawaii.sites[-c(1,4),]
#' 	rownames(sites) <- 1:4
#' 	points(sites,pch=21,col="yellow",bg=mar_col2alpha("yellow",.9),cex=1.2)
#' 	text(sites[,1],sites[,2],lab=rownames(sites),pos=c(3,4,1,2),col="yellow")
#'
#' \dontrun{
#' # Compute transition object with no depth constraint
#' 	trans1 <- mar_transition_matrix(hawaii)
#'
#' # Compute transition object with minimum depth constraint:
#' # path impossible in waters shallower than -200 meters depth
#' 	trans2 <- mar_transition_matrix(hawaii,min.depth=-200)
#'
#' # Computes least cost distances for both transition matrix and plots the results on the map
#' 	out1 <- mar_least_cost_distance2(trans1,sites,res="path")
#' 	out2 <- mar_least_cost_distance2(trans2,sites,res="path")
#' 	lapply(out1,lines,col="yellow",lwd=4,lty=1) # No depth constraint (yellow paths)
#' 	lapply(out2,lines,col="red",lwd=1,lty=1) # Min depth set to -200 meters (red paths)
#'
#' # Computes and display distance matrices for both situations
#' 	dist1 <- mar_least_cost_distance2(trans1,sites,res="dist")
#' 	dist2 <- mar_least_cost_distance2(trans2,sites,res="dist")
#' 	dist1
#' 	dist2
#'
#' # plots the depth profile between location 1 and 3 in the two situations
#' 	dev.new()
#' 	par(mfrow=c(2,1))
#' 	mar_path_profile(out1[[2]],hawaii,pl=TRUE,
#'                  main="Path between locations 1 & 3\nProfile with no depth constraint")
#' 	mar_path_profile(out2[[2]],hawaii,pl=TRUE,
#'                  main="Path between locations 1 & 3\nProfile with min depth set to -200m")
#' }
#' @export
#' @aliases lc.dist2
mar_least_cost_distance2 <- function(trans, loc, res = c("dist", "path"), unit = "meter", speed = 8, round = 0) {

	# require(gdistance)
	# require(sp)

	min.depth <- trans@history[[1]]
	max.depth <- trans@history[[2]]
	bathymetry <- trans@history[[3]]
	trans@history <- list()

	loc.depth <- mar_get_depth(bathymetry, x = loc, locator = FALSE)

	if (any(loc.depth[,3] > min.depth) | any(loc.depth[,3] < max.depth)) print(loc.depth)
	if (any(loc.depth[,3] > min.depth) | any(loc.depth[,3] < max.depth)) warning(paste("One or more points are located outside of the [",min.depth, ";", max.depth,"] depth range. You will get unrealistically huge distances unless you either increase the range of possible depths in mar_transition_matrix() or you move the problematic points in a spot where their depths fall within the [",min.depth, ";", max.depth,"] depth range.\nYou can use mar_get_depth() to determine the depth of any point on a bathymetric map", sep=""))

	if (res=="dist") {
		x <- gdistance::costDistance(trans,as.matrix(loc))
		const1 <- 0.000621371
		const2 <- 0.0005399566364038877
		cost = switch(unit,
			meter = round(x, round),
			km =  round(x/1000, round),
			miles = round(x*const1, round) ,
			nmiles = round(x*const2, round),
			hours = round(x*const2 / speed, round),
			hours.min = paste(floor(x*const2 / speed), round(((x*const2 / speed)-floor(x*const2/speed))*60), sep=":")
			)
		print(cost)
	}

	if (res=="path") {
		nb.loc <- nrow(loc)
		path <- list()
		comb <- combn(1:nb.loc,2)
		pb <- txtProgressBar(min = 0, max = ncol(comb), style = 3)

		for (i in 1:ncol(comb)) {
			origin <- sp::SpatialPoints(loc[comb[1,i],])
			goal <- sp::SpatialPoints(loc[comb[2,i],])

			temp <- gdistance::shortestPath(trans,origin,goal,output="SpatialLines")
			path[[i]] <- temp@lines[[1]]@Lines[[1]]@coords

			setTxtProgressBar(pb, i)
		}

	close(pb)
	return(path)
	}

}

#' @rdname mar_least_cost_distance2
#' @export
lc.dist2 <- mar_least_cost_distance2
