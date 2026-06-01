# Convert bathymetric data to sf

Converts an object of class `bathy`, or a long table containing
longitude and latitude columns, to an `sf` object with point geometries.

## Usage

``` r
as_sf(x, lon = "lon", lat = "lat", crs = 4326, remove = FALSE, ...)
```

## Arguments

  - x:
    
    An object of class `bathy`, or a data frame/tibble containing
    longitude and latitude columns.

  - lon, lat:
    
    Character. Names of the longitude and latitude columns used when `x`
    is a data frame or tibble.

  - crs:
    
    Coordinate reference system assigned to the returned `sf` object.
    Defaults to `4326`, i.e. WGS84 longitude/latitude.

  - remove:
    
    Logical. If `TRUE`, the coordinate columns are removed from the
    returned attribute table. Defaults to `FALSE`.

  - ...:
    
    Additional arguments passed to `sf::st_as_sf`.

## Value

An object of class `sf` with point geometries.

## See also

`bathy_to_tbl`, `tbl_to_bathy`, `as_spatraster`, `project_bathy`

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

xyz_sf <- as_sf(xyz)
class(xyz_sf)
#> [1] "sf"         "data.frame"
```
