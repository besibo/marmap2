# Convert bathymetric data to a terra SpatRaster

Converts bathymetric data stored as a long table or as a historical
`bathy` matrix to a modern
`terra::SpatRaster`.

## Usage

``` r
as_spatraster(x, crs = "EPSG:4326", lon = "lon", lat = "lat", depth = "depth")
```

## Arguments

  - x:
    
    A data frame/tibble with longitude, latitude, and depth columns, or
    an object inheriting from class `bathy`.

  - crs:
    
    Coordinate reference system assigned to the returned raster. Can be
    a CRS string such as `"EPSG:4326"`, or a numeric EPSG code such as
    `4326`. Defaults to `"EPSG:4326"`.

  - lon, lat, depth:
    
    Column names used when `x` is a data frame/tibble.

## Value

A `terra::SpatRaster` object.

## Details

For tabular input, `x` must represent a complete regular grid. The first
two coordinate columns are interpreted as cell centres. For `bathy`
input, row names are interpreted as longitude and column names as
latitude.

## Examples

``` r
if (requireNamespace("terra", quietly = TRUE)) {
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )

  r <- as_spatraster(xyz)
}
```
