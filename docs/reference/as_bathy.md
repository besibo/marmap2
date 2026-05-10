# Convert to bathymetric data in an object of class bathy

Converts a three-column data frame containing longitude, latitude and
depth values to a matrix of class `bathy`.

## Usage

``` r
as_bathy(x)
```

## Arguments

  - x:
    
    Three-column data frame with longitude, latitude and depth values.

## Value

The output of `as_bathy` is a matrix of class `bathy`, with longitude
stored in row names and latitude stored in column names.

## Details

The first column is interpreted as longitude, the second as latitude,
and the third as depth or elevation.

## See also

`summary_bathy`, `read_bathy`, `as_xyz`, `bathy_to_tbl`, `tbl_to_bathy`.

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
class(bathy)
#> [1] "bathy"
summary(bathy)
#> Bathymetric data of class 'bathy', with 3 rows and 3 columns
#> Latitudinal range: 48 to 50 (48 N to 50 N)
#> Longitudinal range: -5 to -3 (5 W to 3 W)
#> Cell size: 60 minute(s)
#> 
#> Depth statistics:
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    -160    -140    -110    -110     -80     -60 
#> 
#> First 5 columns and rows of the bathymetric matrix:
#>      48   49   50
#> -5  -80  -70  -60
#> -4 -120 -110 -100
#> -3 -160 -150 -140
```
