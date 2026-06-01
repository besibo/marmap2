# Convert to xyz format

Converts bathymetric data into a three-column data.frame containing
longitude, latitude and depth data.

## Usage

``` r
as_xyz(x, lon = "lon", lat = "lat", depth = "depth", names = c("V1", "V2", "V3"))
```

## Arguments

- x:

  A matrix of class `bathy`, or a data.frame/tibble containing
  longitude, latitude and depth columns.

- lon, lat, depth:

  Column names used when `x` is a data.frame or tibble.

- names:

  Names to use for the output columns. Defaults to the historical
  `c("V1", "V2", "V3")` xyz format.

## Value

Three-column data.frame with a format similar to xyz files downloaded
from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>). The first column
contains longitude data, the second contains latitude data and the third
contains depth/elevation data.

## Details

The xyz format is a simple three-column export format used by several
historical bathymetry workflows and external software. For objects of
class `bathy`, rows and columns are expanded to longitude, latitude and
depth. For data.frames and tibbles, the selected columns are copied in
their current row order.

For new analyses within R, prefer tibbles with explicit `lon`, `lat` and
`depth` columns. Use `as_xyz()` when an external tool expects a plain
xyz file or table.

## See also

[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`bathy_to_tbl`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md),
[`tbl_to_bathy`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md),
[`summarise_bathy`](https://besibo.github.io/marmap2/reference/summarise_bathy.md)

## Author

Benoit Simon-Bouhet

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

bathy <- as_bathy(xyz)
as_xyz(bathy)
#>   V1 V2   V3
#> 1 -5 50  -60
#> 2 -4 50 -100
#> 3 -3 50 -140
#> 4 -5 49  -70
#> 5 -4 49 -110
#> 6 -3 49 -150
#> 7 -5 48  -80
#> 8 -4 48 -120
#> 9 -3 48 -160
as_xyz(xyz)
#>   V1 V2   V3
#> 1 -5 48  -80
#> 2 -5 49  -70
#> 3 -5 50  -60
#> 4 -4 48 -120
#> 5 -4 49 -110
#> 6 -4 50 -100
#> 7 -3 48 -160
#> 8 -3 49 -150
#> 9 -3 50 -140
```
