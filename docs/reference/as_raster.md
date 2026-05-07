# Convert bathymetric data to a raster layer

Transforms an object of class `bathy` to a raster layer.

## Usage

``` r
as_raster(bathy)
```

## Arguments

  - bathy:
    
    an object of class `bathy`

## Value

An object of class `RasterLayer` with the same characteristics as the
`bathy` object (same longitudinal and latitudinal ranges, same
resolution).

## Details

`as_raster` transforms `bathy` objects into objects of class
`RasterLayer` as defined in the `raster` package. All methods from the
`raster` package are thus available for bathymetric data (e.g.
rotations, projections...).

## See also

`as_xyz`, `as_bathy`, `as_spatial_grid_data_frame`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load Hawaii bathymetric data
data(hawaii)

# use as_raster
r.hawaii <- as_raster(hawaii)

# class "RasterLayer"
class(r.hawaii)

# Summaries
summary(hawaii)
summary(r.hawaii)

# structure of the RasterLayer object
str(r.hawaii)

if (FALSE) { # \dontrun{
# Plots
#require(raster)
plot(hawaii,image=TRUE,lwd=.2)
plot(r.hawaii)
} # }
```
