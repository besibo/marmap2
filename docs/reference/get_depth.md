# Get depth data by clicking on a map

Outputs depth information based on points selected by clicking on a map

## Usage

``` r
get_depth(mat, x, y=NULL, locator=TRUE, distance=FALSE, ...)
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

  - locator:
    
    Logical. Whether to choose data points interactively with a map or
    not. If `TRUE` (default), a bathymetric map must have been plotted
    and both `x` and `y` are both ignored.

  - distance:
    
    whether to compute the haversine distance (in km) from the first
    data point on (default is `FALSE`). Only available when at least two
    points are provided.

  - ...:
    
    Further arguments to be passed to `locator` when the interactive
    mode is used (`locator=TRUE`).

## Value

A data.frame with at least, longitude, latitude and depth with one line
for each point of interest. If `distance=TRUE`, a fourth column
containing the kilometric distance from the first point is added.

## Details

`get_depth` allows the user to get depth data by clicking on a map
created with `plot_bathy` or by providing coordinates of points of
interest. This function uses the `locator` function (`graphics`
package); after creating a map with `plot_bathy`, the user can click on
the map once or several times (if `locator=TRUE`), press the Escape
button, and get the depth of those locations in a three-coumn data.frame
(longitude, latitude and depth). Alternatively, when `locator=FALSE`,
the user can submit a list of longitudes and latitudes, a two-column
matrix or data.frame of longitudes and latitudes (as input for `x`), or
one vector of longitudes (`x`) and one vector of latitudes (`y`). The
non-interactive mode is well suited to get depth information for each
point provided by GPS tracking devices. While `get_transect` gets every
single depth value available in the bathymetric matrix between two
points along a user-defined transect, `get_depth` only provides depth
data for the specific points provided as input by the user.

## See also

`path_profile`, `get_transect`, `read_bathy`, `summary_bathy`,
`subset_bathy`, `nw.atlantic`

## Author

Benoit Simon-Bouhet and Eric Pante

## Examples

``` r
# load NW Atlantic data and convert to class bathy
data(nw.atlantic)
atl <- as_bathy(nw.atlantic)

# create vectors of latitude and longitude
lon <- c(-70, -65, -63, -55)
lat <- c(33, 35, 40, 37)

# a simple example
plot(atl, lwd=.5)
points(lon,lat,pch=19,col=2)

# Use get_depth to get the depth for each point
get_depth(atl, x=lon, y=lat, locator=FALSE)

# alternativeley once the map is plotted, use the iteractive mode:
if (FALSE) { # \dontrun{
get_depth(atl, locator=TRUE, pch=19, col=3)
} # }
# click several times and press Escape
```
