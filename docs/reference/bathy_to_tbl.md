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

[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`as_xyz`](https://besibo.github.io/marmap2/reference/as_xyz.md),
[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md),
[`get_gebco`](https://besibo.github.io/marmap2/reference/get_gebco.md)

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

bathy <- tbl_to_bathy(xyz)
bathy_tbl <- bathy_to_tbl(bathy)
bathy_tbl
#> # A tibble: 9 × 3
#>     lon   lat depth
#>   <dbl> <dbl> <dbl>
#> 1    -5    50   -60
#> 2    -4    50  -100
#> 3    -3    50  -140
#> 4    -5    49   -70
#> 5    -4    49  -110
#> 6    -3    49  -150
#> 7    -5    48   -80
#> 8    -4    48  -120
#> 9    -3    48  -160
```
