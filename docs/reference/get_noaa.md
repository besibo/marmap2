# Download bathymetry from NOAA ETOPO 2022

Prototype replacement for `get_noaa()` using the NOAA ArcGIS ETOPO 2022
image service.

## Usage

``` r
get_noaa(
  lon1 = NULL,
  lon2 = NULL,
  lat1 = NULL,
  lat2 = NULL,
  resolution = 4,
  class = c("tbl", "bathy"),
  keep = FALSE,
  antimeridian = FALSE,
  path = NULL,
  lon = NULL,
  lat = NULL
)
```

## Arguments

  - lon1:
    
    Western or first longitude bound in decimal degrees.

  - lon2:
    
    Eastern or second longitude bound in decimal degrees.

  - lat1:
    
    Southern or first latitude bound in decimal degrees.

  - lat2:
    
    Northern or second latitude bound in decimal degrees.

  - resolution:
    
    Requested grid resolution in arc-minutes.

  - class:
    
    Character. Class of the returned object. Use `"tbl"` (default) to
    return a tibble with columns `lon`, `lat`, and `depth`; use
    `"bathy"` to return a historical matrix of class `bathy`.

  - keep:
    
    Whether to write the downloaded xyz table to disk.

  - antimeridian:
    
    Whether the requested region crosses the antimeridian.

  - path:
    
    Directory used for cached csv files when `keep = TRUE`.

  - lon:
    
    Numeric vector of length 2 giving the longitude bounds. This is an
    alternative to `lon1` and `lon2`.

  - lat:
    
    Numeric vector of length 2 giving the latitude bounds. This is an
    alternative to `lat1` and `lat2`.

## Value

A tibble by default, or an object of class `bathy` when `class =
"bathy"`.
