# Fill a grid with irregularly spaced data

Transforms irregularly spaced xyz data into a raster object suitable to
create a bathy object with regularly spaced longitudes and latitudes.

## Usage

``` r
mar_griddify(xyz, nlon, nlat)

griddify(xyz, nlon, nlat)
```

## Arguments

  - xyz:
    
    3-column matrix or data.frame containing (in this order) arbitrary
    longitude, latitude and altitude/depth values.

  - nlon:
    
    integer. The number of unique regularly-spaced longitude values that
    will be used to create the grid.

  - nlat:
    
    integer. The number of unique regularly-spaced latitude values that
    will be used to create the grid.

## Value

The output of `mar_griddify` is an object of class `raster`, with `nlon`
unique longitude values and `nlat` unique latitude values.

## Details

`mar_griddify` takes anys dataset with irregularly spaced xyz data and
transforms it into a raster object (i.e. a grid) with user specified
dimensions. `mar_griddify` relies on several functions from the `raster`
package, especially `rasterize` and `resample`. If a cell of the
user-defined grig does not contain any depth/altitude value in the
original xyz matrix/data.frame, a `NA` is added in that cell. A bilinear
interpolation is then applied in order to fill in most of the missing
cells. For cells of the user-defined grig containing more than one
depth/altitude value in the original xyz matrix/data.frame, the mean
depth/altitude value is computed.

## References

Robert J. Hijmans (2015). raster: Geographic Data Analysis and Modeling.
R package version 2.4-20. <https://CRAN.R-project.org/package=raster>

## See also

`mar_read_bathy`, `mar_read_gebco_bathy`, `mar_plot_bathy`

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
# load irregularly spaced xyz data
data(irregular)
head(irregular)

# use mar_griddify to create a 40x60 grid
reg <- mar_griddify(irregular, nlon = 40, nlat = 60)

# switch to class "bathy"
class(reg)
bat <- mar_as_bathy(reg)
summary(bat)

# Plot the new bathy object and overlay the original data points
plot(bat, image = TRUE, lwd = 0.1)
points(irregular$lon, irregular$lat, pch = 19, cex = 0.3, col = mar_col2alpha(3))
```
