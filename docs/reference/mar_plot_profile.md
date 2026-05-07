# Ploting bathymetric data along a transect or path

Plots the depth/altitude along a transect or
path

## Usage

``` r
mar_plot_profile(profile,shadow=TRUE,xlim,ylim,col.sea,col.bottom,xlab,ylab, ...)

plotProfile(
  profile,
  shadow = TRUE,
  xlim,
  ylim,
  col.sea,
  col.bottom,
  xlab,
  ylab,
  ...
)
```

## Arguments

  - profile:
    
    4-columns matrix obtained from `mar_get_transect` with argument
    `dist=TRUE`, or from `mar_path_profile`.

  - shadow:
    
    logical. Should the depth profile cast a shadow over the plot
    background?

  - xlim:
    
    numeric vector of length 2 giving the x coordinate range. If
    unspecified, values are based on the length of the transect or path.

  - ylim:
    
    numeric vector of length 2 giving the y coordinate range. If
    unspecified, values are based on the depth range of the bathymetric
    matrix `bathy`.

  - col.sea:
    
    color for the sea area of the plot. Defaults to
    `rgb(130/255,180/255,212/255)`

  - col.bottom:
    
    color for the bottom area of the plot. Defaults to
    `rgb(198/255,184/255,151/255)`

  - xlab:
    
    title for the x axis. If unspecified, `xlab="Distance from start of
    transect (km)"`.

  - ylab:
    
    title for the y axis. If unspecified, `ylab="Depth (m)"`.

  - ...:
    
    arguments to be passed to methods, such as [graphical
    parameters](https://rdrr.io/r/graphics/par.html) (see `par`)

## Value

a bivariate plot of depth against the kilometric distance from the
starting point of a transect or least cost path.

## See also

`mar_path_profile`, `mar_plot_bathy`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# Example 1:
  data(celt)
  layout(matrix(1:2,nc=1),height=c(2,1))
  par(mar=c(4,4,1,1))
  plot(celt,n=40,draw=TRUE)
  points(c(-6.34,-5.52),c(52.14,50.29),type="o",col=2)

  tr <- mar_get_transect(celt, x1 = -6.34, y1 = 52.14, x2 = -5.52, y2 = 50.29, distance = TRUE)
  mar_plot_profile(tr)

# Example 2:
  layout(matrix(1:2,nc=1),height=c(2,1))
  par(mar=c(4,4,1,1))
  plot(celt,n=40,draw=TRUE)
  points(c(-5,-6.34),c(49.8,52.14),type="o",col=2)

  tr2 <- mar_get_transect(celt, x1 = -5, y1 = 49.8, x2 = -6.34, y2 = 52.14, distance = TRUE)
  mar_plot_profile(tr2)

# Example 3: click several times on the map and press ESC
if (FALSE) { # \dontrun{
  layout(matrix(1:2,nc=1),height=c(2,1))
  par(mar=c(4,4,1,1))
  data(florida)
  plot(florida,image=TRUE,dra=TRUE,land=TRUE,n=40)

  out <- mar_path_profile(as.data.frame(locator(type="o",col=2,pch=19,cex=.8)),florida)
  mar_plot_profile(out)
} # }
```
