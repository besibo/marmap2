# Convert to bathymetric data in an object of class bathy

Converts a three-column data frame containing longitude, latitude and
depth values, or a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
to a matrix of class `bathy`.

## Usage

``` r
as_bathy(x)
```

## Arguments

- x:

  Three-column data frame with longitude, latitude and depth values, or
  a
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html).

## Value

The output of `as_bathy` is a matrix of class `bathy`, with longitude
stored in row names and latitude stored in column names.

## Details

For tabular input, the first column is interpreted as longitude, the
second as latitude, and the third as depth or elevation. Missing grid
cells are represented as `NA`. For
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
input, the first layer is converted to xyz cell centres before creating
the `bathy` matrix.

## See also

[`summarise_bathy`](https://besibo.github.io/marmap2/reference/summarise_bathy.md),
[`read_bathy`](https://besibo.github.io/marmap2/reference/read_bathy.md),
[`as_xyz`](https://besibo.github.io/marmap2/reference/as_xyz.md),
[`bathy_to_tbl`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md),
[`tbl_to_bathy`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md).

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
summarise_bathy(bathy)
#> Bathymetric data summary
#>   Class:      bathy
#>   Dimensions: 3 longitude x 3 latitude (9 cells)
#>   Longitude:  5 W to 3 W
#>   Latitude:   48 N to 50 N
#>   Resolution: 60 x 60 arc-minutes
#>   Depth:      -160 to -60 (mean -110, median -110)
#>   Missing:    0
#>   Memory:     1.2 Kb
```
