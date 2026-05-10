# Test whether an object is of class bathy

Test whether an object is of class bathy

## Usage

``` r
is_bathy(xyz)
```

## Arguments

  - xyz:
    
    three-column data.frame with longitude (x), latitude (y) and depth
    (z) (no default)

## Value

The function returns `TRUE` or `FALSE`

## See also

`as_bathy`, `summary_bathy`, `read_bathy`

## Author

Eric Pante

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

is_bathy(xyz)
#> [1] FALSE
is_bathy(as_bathy(xyz))
#> [1] TRUE
```
