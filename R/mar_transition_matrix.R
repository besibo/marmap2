#' Transition matrix
#'
#' @description
#' Creates a transition object to be used by \code{mar_least_cost_distance} to compute least cost distances between locations.
#'
#' @rdname mar_transition_matrix
#' @usage
#' mar_transition_matrix(bathy,min.depth=0,max.depth=NULL)
#' @param bathy A matrix of class \code{bathy}.
#' @param min.depth numeric. Minimum depth for possible paths. The default \code{min.depth = 0} indicates that paths can start at sea level.
#' @param max.depth numeric or \code{NULL}. Maximum depth for possible paths. The default \code{max.depth = NULL} indicates that paths can extend to the maximum depth of \code{bathy}. See Details.
#'
#' @details
#' \code{mar_transition_matrix} creates a transition object usable by \code{mar_least_cost_distance} to computes least cost distances between a set of locations. \code{mar_transition_matrix} rely on the function \code{raster} from package \code{raster} (Hijmans & van Etten, 2012. \url{https://CRAN.R-project.org/package=raster}) and on \code{transition} from package \code{gdistance} (van Etten, 2011. \url{https://CRAN.R-project.org/package=gdistance}).
#'
#' The transition object contains the probability of transition from one cell of a bathymetric grid to adjacent cells and depends on user defined parameters. \code{mar_transition_matrix} is especially usefull when least cost distances need to be calculated between several locations at sea. The default values for \code{min.depth} and \code{max.depth} ensure that the path computed by \code{mar_least_cost_distance} will be the shortest path possible at sea avoiding land masses. The path can be constrained to a given depth range by setting manually \code{min.depth} and \code{max.depth}. For instance, it is possible to limit the possible paths to the continental shelf by setting \code{max.depth=-200}. Inaccuracies of the bathymetric data can occasionally result in paths crossing land masses. Setting \code{min.depth} to low negative values (e.g. -10 meters) can limit this problem.
#'
#' \code{mar_transition_matrix} takes also advantage of the function \code{geoCorrection} from package \code{gdistance} (van Etten, 2012. \url{https://CRAN.R-project.org/package=gdistance}) to take into account map distortions over large areas.
#'
#' @return
#' A transition object.
#'
#' @references
#' Jacob van Etten (2011). gdistance: distances and routes on geographical grids. R package version 1.1-2.  \url{https://CRAN.R-project.org/package=gdistance}
#' Robert J. Hijmans & Jacob van Etten (2012). raster: Geographic analysis and modeling with raster data. R package version 1.9-92. \url{https://CRAN.R-project.org/package=raster}
#'
#' @author
#' Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_least_cost_distance}}, \code{\link{hawaii}}
#'
#' @examples
#' # Load and plot bathymetry
#' data(hawaii)
#' summary(hawaii)
#' plot(hawaii)
#'
#' \dontrun{
#' # Compute transition object with no depth constraint
#' trans1 <- mar_transition_matrix(hawaii)
#'
#' # Compute transition object with minimum depth constraint:
#' # path impossible in waters shallower than -200 meters depth
#' trans2 <- mar_transition_matrix(hawaii,min.depth=-200)
#'
#' # Visualizing results
#' par(mfrow=c(1,2))
#' plot(raster(trans1), main="No depth constraint")
#' plot(raster(trans2), main="Constraint in shallow waters")
#' }
#' @export
#' @aliases trans.mat
mar_transition_matrix <- function(bathy,min.depth=0,max.depth=NULL) {
	
	# require(gdistance)
	
	ras <- bathy
	ras[bathy > min.depth] <- 0.00000001
	ras[bathy <= min.depth] <- 1
	if (!is.null(max.depth)) ras[bathy <= max.depth] <- 0.00000001
	if (is.null(max.depth)) max.depth <- min(bathy, na.rm=TRUE)
	
	lat <- as.numeric(colnames(bathy))
	lon <- as.numeric(rownames(bathy))
	
	r <- raster::raster(ncol=nrow(bathy),nrow=ncol(bathy),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat))
	raster::values(r) <- as.vector(ras[,rev(1:ncol(ras))])
	
	trans <- gdistance::transition(r, transitionFunction = mean, directions = 16)
	transC <- gdistance::geoCorrection(trans,type="c",multpl=FALSE)

	transC@history <- list(min.depth, max.depth, bathy)
	return(transC)
}

#' @rdname mar_transition_matrix
#' @export
trans.mat <- mar_transition_matrix
