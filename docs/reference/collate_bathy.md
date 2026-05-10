# Collates two bathy matrices with data from either sides of the antimeridian

Collates two bathy matrices, one with longitude 0 to 180 degrees East,
and the other with longitude 0 to 180 degrees West

## Usage

``` r
collate_bathy(east,west)
```

## Arguments

- east:

  matrix of class `bathy` with eastern data (West of antimeridian)

- west:

  matrix of class `bathy` with western data (East of antimeridian)

## Value

A single matrix of class `bathy`. When plotting collated data with
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md),
use `antimeridian = TRUE` to display western longitude labels beyond 180
degrees.

## Details

This function is used internally by import functions when data are
downloaded from both sides of the antimeridian line (180 degrees
longitude). If, for example, data are downloaded for longitudes 170E-180
and 180-170W, `collate_bathy()` creates a single matrix of class `bathy`
with a coordinate system going from 170 to 190 degrees longitude.

[`get_noaa()`](https://besibo.github.io/marmap2/reference/get_noaa.md)
deals with data from both sides of the antimeridian and does not need
further processing with `collate_bathy()`.

## See also

[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md),
[`get_gebco`](https://besibo.github.io/marmap2/reference/get_gebco.md),
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md),
[`summary_bathy`](https://besibo.github.io/marmap2/reference/summary_bathy.md)

## Author

Eric Pante

## Examples

``` r
east <- as_bathy(data.frame(
  lon = rep(c(178, 179), each = 2),
  lat = rep(c(10, 11), times = 2),
  depth = c(-10, -20, -30, -40)
))
west <- as_bathy(data.frame(
  lon = rep(c(-180, -179), each = 2),
  lat = rep(c(10, 11), times = 2),
  depth = c(-50, -60, -70, -80)
))

collate_bathy(east, west)
#>      10  11
#> 178 -10 -20
#> 179 -30 -40
#> 180 -50 -60
#> 181 -70 -80
#> attr(,"class")
#> [1] "bathy"
```
