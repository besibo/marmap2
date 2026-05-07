# Irregularly spaced bathymetric data.

Three-column data.frame of irregularly-spaced longitudes, latitudes and
depths.

## Usage

``` r
data(irregular)
```

## Value

A three-columns data.frame containing longitude, latitude and
depth/elevation data.

## See also

`mar_griddify`

## Author

Data modified form a dataset kindly provided by Noah Lottig from the
university of Wisconsin <https://limnology.wisc.edu/staff/lottig-noah/>
in the framework of the North Temperate Lakes Long Term Ecological
Research program <https://lter.limnology.wisc.edu>

## Examples

``` r
# load data
data(irregular)

# use mar_griddify
reg <- mar_griddify(irregular, nlon = 40, nlat = 60)

# switch to class "bathy"
class(reg)
bat <- mar_as_bathy(reg)
summary(bat)

# Plot the new bathy object along with the original data
plot(bat, image = TRUE, lwd = 0.1)
points(irregular$lon, irregular$lat, pch = 19, cex = 0.3, col = mar_col2alpha(3))
```
