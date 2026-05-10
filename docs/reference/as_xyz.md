# Convert to xyz format

Converts a matrix of class `bathy` into a three-column data.frame
containing longitude, latitude and depth data.

## Usage

``` r
as_xyz(bathy)
```

## Arguments

  - bathy:
    
    matrix of class `bathy`.

## Value

Three-column data.frame with a format similar to xyz files downloaded
from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>). The first column
contains longitude data, the second contains latitude data and the third
contains depth/elevation data.

## Details

The use of `as_bathy` and `as_xyz` allows switching back and forth
between the long xyz format and the historical matrix format of class
`bathy`.

## See also

`as_bathy`, `bathy_to_tbl`, `tbl_to_bathy`, `summary_bathy`

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
```
