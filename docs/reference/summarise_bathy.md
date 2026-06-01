# Summarise bathymetric data

Returns a compact one-row summary of bathymetric data stored as a
tibble/data frame with `lon`, `lat`, and `depth` columns, or as an
historical `bathy` object.

## Usage

``` r
summarise_bathy(x, ...)
```

## Arguments

  - x:
    
    A data frame/tibble with columns `lon`, `lat`, and `depth`, or an
    object inheriting from class `bathy`.

  - ...:
    
    Reserved for future use.

## Value

A one-row tibble with class `bathy_summary`. It contains the input
classes, grid dimensions, geographic bounding box, grid resolution in
arc-minutes, depth/elevation statistics, number of missing values, and
object size in memory. A compact print method is provided for
interactive use.

## See also

`get_gebco`, `get_noaa`, `geom_bathy`

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

summarise_bathy(xyz)
#> Bathymetric data summary
#>   Class:      data.frame
#>   Dimensions: 3 longitude x 3 latitude (9 cells)
#>   Longitude:  5 W to 3 W
#>   Latitude:   48 N to 50 N
#>   Resolution: 60 x 60 arc-minutes
#>   Depth:      -160 to -60 (mean -110, median -110)
#>   Missing:    0
#>   Memory:     1.3 Kb
summarise_bathy(as_bathy(xyz))
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
