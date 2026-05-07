# Convert bathymetric data to a spatial grid

Transforms an object of class `bathy` to a `SpatialGridDataFrame`
object.

## Usage

``` r
mar_as_spatial_grid_data_frame(bathy)

as.SpatialGridDataFrame(bathy)
```

## Arguments

  - bathy:
    
    an object of class `bathy`

## Value

An object of class `SpatialGridDataFrame` with the same characteristics
as the `bathy` object (same longitudinal and latitudinal ranges, same
resolution).

## Details

`mar_as_spatial_grid_data_frame` transforms `bathy` objects into objects
of class `SpatialGridDataFrame` as defined in the `sp` package. All
methods from the `sp` package are thus available for bathymetric data
(e.g. rotations, projections...).

## See also

`mar_as_xyz`, `mar_as_bathy`, `mar_as_raster`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load Hawaii bathymetric data
data(hawaii)

# use mar_as_spatial_grid_data_frame
sp.hawaii <- mar_as_spatial_grid_data_frame(hawaii)

# Summaries
summary(hawaii)
summary(sp.hawaii)

# structure of the SpatialGridDataFrame object
str(sp.hawaii)

# Plots
plot(hawaii,image=TRUE,lwd=.2)
image(sp.hawaii)
```
