# Convert a bathy object to a terra SpatRaster

Converts the historical `bathy` matrix representation to a modern
`terra::SpatRaster` while preserving grid extent and orientation.

## Usage

``` r
mar_bathy_to_spatraster(x, crs = "EPSG:4326")

mar_as_terra_bathy(x, crs = "EPSG:4326")

as_terra_bathy(x, crs = "EPSG:4326")

bathy_to_spatraster(x, crs = "EPSG:4326")
```

## Arguments

  - x:
    
    An object inheriting from class `bathy`.

  - crs:
    
    Coordinate reference system assigned to the returned raster.

## Value

A `terra::SpatRaster` object.

## Examples

``` r
if (requireNamespace("terra", quietly = TRUE)) {
  data(hawaii)
  r <- mar_bathy_to_spatraster(hawaii)
}
```
