# Computes the shortest great circle distance between any point and a given isobath

Computes the shortest (great circle) distance between a set of points
and an isoline of depth or altitude. Points can be selected
interactively by clicking on a map.

## Usage

``` r
distance_to_isobath(mat, x, y=NULL, isobath=0, locator=FALSE, ...)
```

## Arguments

  - mat:
    
    Bathymetric data matrix of class `bathy`, as imported with
    `read_bathy`.

  - x:
    
    Either a list of two elements (numeric vectors of longitude and
    latitude), a 2-column matrix or data.frame of longitudes and
    latitudes, or a numeric vector of longitudes.

  - y:
    
    Either `NULL` (default) or a numerical vector of latitudes. Ignored
    if `x` is not a numeric vector.

  - isobath:
    
    A single numerical value indicating the isobath to which the
    shortest distance is to be computed (default is set to 0, *i.e.* the
    coastline).

  - locator:
    
    Logical. Whether to choose data points interactively with a map or
    not. If `TRUE`, a bathymetric map must have been plotted and both
    `x` and `y` are both ignored.

  - ...:
    
    Further arguments to be passed to `locator` when the interactive
    mode is used (`locator=TRUE`).

## Value

A 5-column data.frame. The first column contains the distance in meters
between each point and the nearest point located on the given `isobath`.
Columns 2 and 3 indicate the longitude and latitude of starting points
(*i.e.* either coordinates provided as `x` and `y` or coordinates of
points selected interactively on a map when `locator=TRUE`) and columns
4 and 5 contains coordinates (longitudes and latitudes) arrival points
*i.e.* the nearest points on the `isobath`.

## Details

`distance_to_isobath` allows the user to compute the shortest great
circle distance between a set of points (selected interactively on a map
or not) and a user-defined isobath. `distance_to_isobath` takes
advantage of functions from packages `sp` (`Lines()` and
`SpatialLines()`) and `geosphere` (`dist2Line`) to compute the
coordinates of the nearest location along a given isobath for each point
provided by the user.

## See also

`lines_gc`, `least_cost_distance`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# Load NW Atlantic data and convert to class bathy
data(nw.atlantic)
atl <- as_bathy(nw.atlantic)

# Create vectors of latitude and longitude
lon <- c(-70, -65, -63, -55, -48)
lat <- c(33, 35, 40, 37, 33)

# Compute distances between each point and the -200m isobath
d <- distance_to_isobath(atl, lon, lat, isobath = -200)
d

# Visualize the great circle distances
blues <- c("lightsteelblue4","lightsteelblue3","lightsteelblue2","lightsteelblue1")
plot(atl, image=TRUE, lwd=0.1, land=TRUE, bpal = list(c(0,max(atl),"grey"), c(min(atl),0,blues)))
plot(atl, deep=-200, shallow=-200, step=0, lwd=0.6, add=TRUE)
points(lon,lat, pch=21, col="orange4", bg="orange2", cex=.8)
lines_gc(d[2:3],d[4:5])
```
