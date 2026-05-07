# Transition matrix

Creates a transition object to be used by `least_cost_distance` to
compute least cost distances between locations.

## Usage

``` r
transition_matrix(bathy,min.depth=0,max.depth=NULL)
```

## Arguments

  - bathy:
    
    A matrix of class `bathy`.

  - min.depth:
    
    numeric. Minimum depth for possible paths. The default `min.depth
    = 0` indicates that paths can start at sea level.

  - max.depth:
    
    numeric or `NULL`. Maximum depth for possible paths. The default
    `max.depth = NULL` indicates that paths can extend to the maximum
    depth of `bathy`. See Details.

## Value

A transition object.

## Details

`transition_matrix` creates a transition object usable by
`least_cost_distance` to computes least cost distances between a set of
locations. `transition_matrix` rely on the function `raster` from
package `raster` (Hijmans & van Etten, 2012.
<https://CRAN.R-project.org/package=raster>) and on `transition` from
package `gdistance` (van Etten, 2011.
<https://CRAN.R-project.org/package=gdistance>).

The transition object contains the probability of transition from one
cell of a bathymetric grid to adjacent cells and depends on user defined
parameters. `transition_matrix` is especially usefull when least cost
distances need to be calculated between several locations at sea. The
default values for `min.depth` and `max.depth` ensure that the path
computed by `least_cost_distance` will be the shortest path possible at
sea avoiding land masses. The path can be constrained to a given depth
range by setting manually `min.depth` and `max.depth`. For instance, it
is possible to limit the possible paths to the continental shelf by
setting `max.depth=-200`. Inaccuracies of the bathymetric data can
occasionally result in paths crossing land masses. Setting `min.depth`
to low negative values (e.g. -10 meters) can limit this problem.

`transition_matrix` takes also advantage of the function `geoCorrection`
from package `gdistance` (van Etten, 2012.
<https://CRAN.R-project.org/package=gdistance>) to take into account map
distortions over large areas.

## References

Jacob van Etten (2011). gdistance: distances and routes on geographical
grids. R package version 1.1-2.
<https://CRAN.R-project.org/package=gdistance> Robert J. Hijmans & Jacob
van Etten (2012). raster: Geographic analysis and modeling with raster
data. R package version 1.9-92.
<https://CRAN.R-project.org/package=raster>

## See also

`least_cost_distance`, `hawaii`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# Load and plot bathymetry
data(hawaii)
summary(hawaii)
plot(hawaii)

if (FALSE) { # \dontrun{
# Compute transition object with no depth constraint
trans1 <- transition_matrix(hawaii)

# Compute transition object with minimum depth constraint:
# path impossible in waters shallower than -200 meters depth
trans2 <- transition_matrix(hawaii,min.depth=-200)

# Visualizing results
par(mfrow=c(1,2))
plot(raster(trans1), main="No depth constraint")
plot(raster(trans2), main="Constraint in shallow waters")
} # }
```
