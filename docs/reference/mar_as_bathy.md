# Convert to bathymetric data in an object of class bathy

Reads either an object of class `RasterLayer`, `SpatialGridDataFrame` or
a three-column data.frame containing longitude (x), latitude (y) and
depth (z) data and converts it to a matrix of class bathy.

## Usage

``` r
mar_as_bathy(x)

as.bathy(x)
```

## Arguments

  - x:
    
    Object of `RasterLayer` or `SpatialGridDataFrame`, or a three-column
    data.frame with longitude (x), latitude (y) and depth (z) (no
    default)

## Value

The output of `mar_as_bathy` is a matrix of class `bathy`, which
dimensions and resolution are identical to the original object. The
class `bathy` has its own methods for summarizing and ploting the data.

## Details

`x` can contain data downloaded from the NOAA GEODAS Grid Translator
webpage (http://www.ngdc.noaa.gov/mgg/gdas/gd\_designagrid.html) in the
form of an xyz table. The function `mar_as_bathy` can also be used to
transform objects of class `raster` (see package `raster`) and
`SpatialGridDataFrame` (see package `sp`).

## See also

`mar_summary_bathy`, `mar_plot_bathy`, `mar_read_bathy`, `mar_as_xyz`,
`mar_as_raster`, `mar_as_spatial_grid_data_frame`.

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load NW Atlantic data
data(nw.atlantic)

# use mar_as_bathy
atl <- mar_as_bathy(nw.atlantic)

# class "bathy"
class(atl)

# summarize data of class "bathy"
summary(atl)
```
