# Ploting bathymetric data with ggplot

Plots contour or image map from bathymetric data matrix of class `bathy`
with
ggplot2

## Usage

``` r
autoplot_bathy(object, geom = "contour", mapping = NULL, coast = TRUE, ...)
```

## Arguments

  - object:
    
    bathymetric data matrix of class `bathy`, imported using
    `read_bathy`

  - geom:
    
    geometry to use for the plot, i.e. type of plot; can be ` contour',
     `tile' or ` raster'.  `contour' does a contour plot. ` tile' and
     `raster' produce an image plot. tile allows true geographical
    projection through `coord_map`. raster only allows approximate
    projection but is faster to plot. Names can be abbreviated.
    Geometries can be combined by specifying several in a vector.

  - mapping:
    
    additional mappings between the data obtained from calling
    `fortify_bathy` on x and the aesthetics for all geoms. When not
    NULL, this is a call to aes().

  - coast:
    
    boolean; wether to highlight the coast (isobath 0 m) as a black line

  - ...:
    
    passed to the chosen geom(s)

## Details

`fortify_bathy` is called with argument `x` to produce a data.frame
compatible with ggplot2. Then layers are added to the plot based on the
argument `geom`. Finally, the whole plot is projected geographically
using `coord_map` (for `geom="contour"`) or an approximation thereof.

## See also

`fortify_bathy`, `plot_bathy`, `read_bathy`, `summary_bathy`

## Author

Jean-Olivier Irisson

## Examples

``` r
# load NW Atlantic data and convert to class bathy
  data(nw.atlantic)
  atl <- as_bathy(nw.atlantic)

  # basic plot
if (FALSE) { # \dontrun{
  library("ggplot2")
  autoplot_bathy(atl)

  # plot images
  autoplot_bathy(atl, geom=c("tile"))
  autoplot_bathy(atl, geom=c("raster")) # faster but not resolution independant

  # plot both!
  autoplot_bathy(atl, geom=c("raster", "contour"))

  # geom names can be abbreviated
  autoplot_bathy(atl, geom=c("r", "c"))

  # do not highlight the coastline
  autoplot_bathy(atl, coast=FALSE)

  # better colour scale
    autoplot_bathy(atl, geom=c("r", "c")) +
    scale_fill_gradient2(low="dodgerblue4", mid="gainsboro", high="darkgreen")

  # set aesthetics
  autoplot_bathy(atl, geom=c("r", "c"), colour="white", size=0.1)

  # topographical colour scale, see ?scale_fill_etopo
  autoplot_bathy(atl, geom=c("r", "c"), colour="white", size=0.1) + scale_fill_etopo()

  # add sampling locations
  data(metallo)
  last_plot() + geom_point(aes(x=lon, y=lat), data=metallo, alpha=0.5)

  # an alternative contour map making use of additional mappings
  # see ?stat_contour in ggplot2 to understand the ..level.. argument
  autoplot_bathy(atl, geom="contour", mapping=aes(colour=..level..))
} # }
```
