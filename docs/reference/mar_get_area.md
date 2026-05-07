# Get projected surface area

Get projected surface area for specific depth layers

## Usage

``` r
mar_get_area(mat, level.inf, level.sup=0, xlim=NULL, ylim=NULL)

get.area(mat, level.inf, level.sup = 0, xlim = NULL, ylim = NULL)
```

## Arguments

  - mat:
    
    bathymetric data matrix of class `bathy`, imported using
    `mar_read_bathy` (no default)

  - level.inf:
    
    lower depth limit for calculation of projected surface area (no
    default)

  - level.sup:
    
    upper depth limit for calculation of projected surface area (default
    is zero)

  - xlim:
    
    longitudinal range of the area of interest (default is `NULL`)

  - ylim:
    
    latitudinal range of the area of interest (default is `NULL`)

## Value

A list of four objects: the projeced surface area in squared kilometers,
a matrix with the cells used for calculating the projected surface area,
the longitude and latitude of the matrix used for the calculations.

## Details

`mar_get_area` calculates the projected surface area of specific depth
layers (e.g. upper bathyal, lower bathyal), the projected plane being
the ocean surface. The resolution of `mar_get_area` depends on the
resolution of the input bathymetric data. `xlim` and `ylim` can be used
to restrict the area of interest. Area calculation is based on
`areaPolygon` of package `geosphere` (using an average Earth radius of
6,371 km).

## See also

`mar_plot_area`, `mar_plot_bathy`, `contour`, `areaPolygon`

## Author

Benoit Simon-Bouhet and Eric Pante

## Examples

``` r
## get area for the entire hawaii dataset:
  data(hawaii)
  plot(hawaii, lwd=0.2)

  mesopelagic <- mar_get_area(hawaii, level.inf=-1000, level.sup=-200)
  bathyal <- mar_get_area(hawaii, level.inf=-4000, level.sup=-1000)
  abyssal <- mar_get_area(hawaii, level.inf=min(hawaii), level.sup=-4000)

  col.meso <- rgb(0.3, 0, 0.7, 0.3)
  col.bath <- rgb(0.7, 0, 0, 0.3)
  col.abys <- rgb(0.7, 0.7, 0.3, 0.3)

  mar_plot_area(mesopelagic, col = col.meso)
  mar_plot_area(bathyal, col = col.bath)
  mar_plot_area(abyssal, col = col.abys)

  me <- round(mesopelagic$Square.Km, 0)
  ba <- round(bathyal$Square.Km, 0)
  ab <- round(abyssal$Square.Km, 0)

  legend(x="bottomleft",
    legend=c(paste("mesopelagic:",me,"km2"),
             paste("bathyal:",ba,"km2"),
             paste("abyssal:",ab,"km2")),
    col="black", pch=21,
    pt.bg=c(col.meso,col.bath,col.abys))

# Use of xlim and ylim
  data(hawaii)
  plot(hawaii, lwd=0.2)

  mesopelagic <- mar_get_area(hawaii, xlim=c(-161.4,-159), ylim=c(21,23),
                          level.inf=-1000, level.sup=-200)
  bathyal <- mar_get_area(hawaii, xlim=c(-161.4,-159), ylim=c(21,23),
                          level.inf=-4000, level.sup=-1000)
  abyssal <- mar_get_area(hawaii, xlim=c(-161.4,-159), ylim=c(21,23),
                          level.inf=min(hawaii), level.sup=-4000)

  col.meso <- rgb(0.3, 0, 0.7, 0.3)
  col.bath <- rgb(0.7, 0, 0, 0.3)
  col.abys <- rgb(0.7, 0.7, 0.3, 0.3)

  mar_plot_area(mesopelagic, col = col.meso)
  mar_plot_area(bathyal, col = col.bath)
  mar_plot_area(abyssal, col = col.abys)

  me <- round(mesopelagic$Square.Km, 0)
  ba <- round(bathyal$Square.Km, 0)
  ab <- round(abyssal$Square.Km, 0)

  legend(x="bottomleft",
    legend=c(paste("mesopelagic:",me,"km2"),
             paste("bathyal:",ba,"km2"),
             paste("abyssal:",ab,"km2")),
    col="black", pch=21,
    pt.bg=c(col.meso,col.bath,col.abys))
```
