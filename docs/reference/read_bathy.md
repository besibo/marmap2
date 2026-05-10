# Read bathymetric data in XYZ format

Reads a three-column table containing longitude (x), latitude (y) and
depth (z) data.

## Usage

``` r
read_bathy(xyz, header = FALSE, sep = ",", ...)
```

## Arguments

- xyz:

  three-column table with longitude (x), latitude (y) and depth (z) (no
  default)

- header:

  whether this table has a row of column names (default = FALSE)

- sep:

  character separating columns, (default=",")

- ...:

  further arguments to be passed to
  [`read.table()`](https://rdrr.io/r/utils/read.table.html)

## Value

The output of `read_bathy` is a matrix of class `bathy`. Its dimensions
depend on the resolution and extent of the input xyz table.

## See also

[`summary_bathy`](https://besibo.github.io/marmap2/reference/summary_bathy.md),
[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`bathy_to_tbl`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md)

## Author

Eric Pante

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

tmp <- tempfile(fileext = ".csv")
write.table(xyz, tmp, sep = ",", quote = FALSE, row.names = FALSE)
bathy <- read_bathy(tmp, header = TRUE)
class(bathy)
#> [1] "bathy"
```
