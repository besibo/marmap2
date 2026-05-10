#' Builds a bathymetry- and/or topography-constrained color palette
#'
#' @description
#' Builds a constrained color palette based on depth / altitude bounds and given colors.
#'
#' @rdname palette_bathy
#' @usage
#' palette_bathy(mat, layers, land=FALSE, default.col="white")
#' @param mat a matrix of bathymetric data, class bathy not required.
#' @param layers a list of depth bounds and colors (see below)
#' @param land logical. Wether to consider land or not (\code{default} is \code{FALSE})
#' @param default.col a color for the area of the matrix not bracketed by the list supplied to \code{layers}
#'
#' @details
#' \code{palette_bathy} allows the production of color palettes for specified bathymetric and/or topographic layers. The \code{layers} argument must be a list of vectors. Each vector corresponds to a bathymetry/topography layer (for example, one layer for bathymetry and one layer for topography). The first and second elements of the vector are the minimum and maximum bathymetry/topography, respectively. The other elements of the vector (3, onward) correspond to colors (see example below). \code{palette_bathy} is called internally by \code{plot_bathy} when the \code{image} argument is set to \code{TRUE}.
#'
#' @return
#' A vector of colors which size depends on the depth / altitude range of the \code{bathy} matrix.
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{plot_bathy}}
#'
#' @examples
#' # load NW Atlantic data and convert to class bathy
#' 	data(nw.atlantic)
#' 	atl <- as_bathy(nw.atlantic)
#'
#' # creating depth-constrained palette for the ocean only
#'     newcol <- palette_bathy(mat=atl,
#' 		layers = list(c(min(atl), 0, "purple", "blue", "lightblue")),
#' 		land = FALSE, default.col = "grey" )
#' 	plot(atl, land = FALSE, n = 10, lwd = 0.5, image = TRUE,
#' 		bpal = newcol, default.col = "grey")
#'
#' # same:
#' 	plot(atl, land = FALSE, n = 10, lwd = 0.5, image = TRUE,
#' 		bpal = list(c(min(atl), 0, "purple", "blue", "lightblue")),
#' 		default.col = "gray")
#'
#' # creating depth-constrained palette for 3 ocean "layers"
#' 	newcol <- palette_bathy(mat = atl, layers = list(
#' 		c(min(atl), -3000, "purple", "blue", "grey"),
#' 		c(-3000, -150, "white"),
#' 		c(-150, 0, "yellow", "green", "brown")),
#' 		land = FALSE, default.col = "grey")
#' 	plot(atl, land = FALSE, n = 10, lwd = 0.7, image = TRUE,
#' 		bpal = newcol, default.col = "grey")
#'
#' # same
#' 	plot(atl, land = FALSE, n = 10, lwd = 0.7, image = TRUE,
#' 		bpal = list(c(min(atl), -3000, "purple","blue","grey"),
#' 					c(-3000, -150, "white"),
#' 					c(-150, 0, "yellow", "green", "brown")),
#' 		default.col = "grey")
#'
#' # creating depth-constrained palette for land and ocean
#' 	newcol <- palette_bathy(mat= atl, layers = list(
#' 		c(min(atl),0,"purple","blue","lightblue"),
#' 		c(0, max(atl), "gray90", "gray10")),
#' 		land = TRUE)
#' 	plot(atl, land = TRUE, n = 10, lwd = 0.5, image = TRUE, bpal = newcol)
#'
#' # same
#' 	plot(atl, land = TRUE, n = 10, lwd = 0.7, image = TRUE,
#' 		bpal = list(
#' 			c(min(atl), 0, "purple", "blue", "lightblue"),
#' 			c(0, max(atl), "gray90", "gray10")))
#' @export
palette_bathy <- function(mat, layers, land=FALSE, default.col="white"){

	deep <- sapply(layers, function(x) as.numeric(x[1]))
	shallow <- sapply(layers, function(x) as.numeric(x[2]))
	palcol <- lapply(layers, function(x) x[-c(1,2)])

	if(land == FALSE) {
		MAT.AMP <- abs(min(mat, na.rm=TRUE))  # matrix amplitude
		vec <- rep(default.col, round(MAT.AMP,0) + 2) # +2 to account for depth zero and matrix start
	
		for(i in 1:length(deep)){
			index1 <- 1 + round(1 + MAT.AMP - abs(deep[i]), 0)
			index2 <- 1 + round(1 + MAT.AMP - abs(shallow[i]), 0)
			pcol <- colorRampPalette(palcol[[i]])
			vec[index1:index2] <- pcol(length(index1:index2))
		}
		} else {
		MAT.AMP <- abs(min(mat, na.rm=TRUE)) + abs(max(mat, na.rm=TRUE))  # diff(range(mat)) -> MAT.AMP
		vec <- rep(default.col, MAT.AMP)
		
		for(i in 1:length(deep)){
			if(deep[i] <= 0)    index1 <- round(1 + abs(min(mat, na.rm=TRUE)) - abs(deep[i]), 0)    else index1 <- round(1 + abs(min(mat, na.rm=TRUE)) + abs(deep[i]), 0)
			if(shallow[i] <= 0) index2 <- round(1 + abs(min(mat, na.rm=TRUE)) - abs(shallow[i]), 0) else index2 <- round(1 + abs(min(mat, na.rm=TRUE)) + abs(shallow[i]), 0)
			pcol <- colorRampPalette(palcol[[i]])
			vec[index1:index2] <- pcol(length(index1:index2))
		}
	}	
	return(vec)
}

