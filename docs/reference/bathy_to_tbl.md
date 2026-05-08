# Convert between bathy objects and tibbles

`bathy_to_tbl()` converts the historical matrix-based `bathy` class to a
long tibble with longitude, latitude, and depth/elevation columns.
`tbl_to_bathy()` converts a long table back to a `bathy` object.

## Usage

``` r
bathy_to_tbl(x, names = c("lon", "lat", "depth"))

tbl_to_bathy(x, lon = "lon", lat = "lat", depth = "depth")
```

## Arguments

  - x:
    
    An object of class `bathy` for `bathy_to_tbl()`, or a table for
    `tbl_to_bathy()`.

  - names:
    
    Character vector of length 3 giving the output column names for
    longitude, latitude, and depth/elevation.

  - lon, lat, depth:
    
    Column names used by `tbl_to_bathy()`.

## Value

`bathy_to_tbl()` returns a tibble. `tbl_to_bathy()` returns an object of
class `bathy`.

## See also

`as_bathy`, `as_xyz`, `get_noaa`, `get_gebco`

## Examples

``` r
data(celt)

celt_tbl <- bathy_to_tbl(celt)
celt_tbl

celt_bathy <- tbl_to_bathy(celt_tbl)
class(celt_bathy)
```
