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

`bathy_to_tbl`, `tbl_to_bathy`, `bathy_to_spatraster`

## Examples

``` r
data(celt)

celt_sf <- as_sf(celt)
class(celt_sf)

celt_tbl <- bathy_to_tbl(celt)
celt_sf2 <- as_sf(celt_tbl)
class(celt_sf2)
```
