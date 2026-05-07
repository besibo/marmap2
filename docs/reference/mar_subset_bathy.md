# Creates bathy objects from larger bathy objects

Generates rectangular or non rectangular `bathy` objects by extracting
bathymetric data from larger `bathy` objects.

## Usage

``` r
mar_subset_bathy(mat, x, y=NULL, locator=TRUE, ...)

subsetBathy(mat, x, y = NULL, locator = TRUE, ...)
```

## Arguments

  - mat:
    
    Bathymetric data matrix of class `bathy`, as imported with
    `mar_read_bathy`.

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

  - ...:
    
    Further arguments to be passed to `locator` when the interactive
    mode is used (`locator=TRUE`).

## Value

A matrix of class `bathy`.

## Details

`mar_subset_bathy` allows the user to generate new `bathy` objects by
extracting data from larger `bathy` objects. The extraction of
bathymetric data can be done interactively by clicking on a bathymetric
map, or by providing longitudes and latitudes for the boundaries for the
new `bathy` object. If two data points are provided, a rectangular area
is selected. If more than two points are provided, a polygon is defined
by linking the points and the bathymetic data is extracted within the
polygon only. `mar_subset_bathy` relies on the `point.in.polygon`
function from package `sp` to identify which points of the initial bathy
matrix lie witin the boundaries of the user-defined polygon.

## References

Pebesma, EJ, RS Bivand, (2005). Classes and methods for spatial data in
R. R News 5 (2), <https://cran.r-project.org/doc/Rnews/>

Bivand RS, Pebesma EJ, Gomez-Rubio V (2013). Applied spatial data
analysis with R, Second edition. Springer, NY. <https://asdar-book.org>

## See also

`mar_plot_bathy`, `mar_get_depth`, `mar_summary_bathy`, `aleutians`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load aleutians dataset
data(aleutians)

# create vectors of latitude and longitude to define the boundary of a polygon
lon <- c(188.56, 189.71, 191, 193.18, 196.18, 196.32, 196.32, 194.34, 188.83)
lat <- c(54.33, 55.88, 56.06, 55.85, 55.23, 54.19, 52.01, 50.52, 51.71)


# plot the initial bathy and overlay the polygon
plot(aleutians, image=TRUE, land=TRUE, lwd=.2)
polygon(lon,lat)

# Use of mar_subset_bathy to extract the new bathy object
zoomed <- mar_subset_bathy(aleutians, x=lon, y=lat, locator=FALSE)

# plot the new bathy object
dev.new() ; plot(zoomed, land=TRUE, image=TRUE, lwd=.2)

# alternativeley once the map is plotted, use the interactive mode:
if (FALSE) { # \dontrun{
plot(aleutians, image=TRUE, land=TRUE, lwd=.2)
zoomed2 <- mar_subset_bathy(aleutians, pch=19, col=3)
dev.new() ; plot(zoomed2, land=TRUE, image=TRUE, lwd=.2)
} # }
# click several times and press Escape
```
