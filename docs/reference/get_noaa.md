# Download bathymetry from NOAA ETOPO 2022

Prototype replacement for `get_noaa()` using the NOAA ArcGIS ETOPO 2022
image service.

## Usage

``` r
get_noaa(lon1, lon2, lat1, lat2, resolution = 4, keep = FALSE,
  antimeridian = FALSE, path = NULL)
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

  - keep:
    
    Whether to write the downloaded xyz table to disk.

  - antimeridian:
    
    Whether the requested region crosses the antimeridian.

  - path:
    
    Directory used for cached csv files when `keep = TRUE`.

## Value

An object of class `bathy`.
