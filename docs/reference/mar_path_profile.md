# Geographic coordinates, kilometric distance and depth along a path

Computes and plots the depth/altitude along a transect or path

## Usage

``` r
mar_path_profile(path,bathy,plot=FALSE, ...)

path.profile(path, bathy, plot = FALSE, ...)
```

## Arguments

  - path:
    
    2-columns matrix of longitude and latitude as obtained from
    `mar_least_cost_distance` with argument `dist=TRUE`.

  - bathy:
    
    bathymetric data matrix of class `bathy`.

  - plot:
    
    logical. Should the depth profile be plotted?

  - ...:
    
    when `plot=TRUE`, other arguments to be passed to
    `mar_plot_profile`, such as [graphical
    parameters](https://rdrr.io/r/graphics/par.html) (see `par` and
    `mar_plot_profile`).

## Value

a four-columns matrix containing longitude, latitude, kilometric
distance from the start of a route and depth for a set of points along a
route. Optionally (i.e. when `plot=TRUE`) a bivariate plot of depth
against the kilometric distance from the starting point of a transect or
least cost path.

## See also

`mar_plot_profile`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# Loading an object of class bathy and a data.frame of locations
  require(mapdata)
  data(hawaii)
  data(hawaii.sites)

# Preparing a color palette for the bathymetric map
  pal <- colorRampPalette(c("black","darkblue","blue","lightblue"))

# Plotting the bathymetric data and the path between locations
# (the path starts on location 1)
  plot(hawaii,image=TRUE,bpal=pal(100),col="grey40",lwd=.7,
       main="Bathymetric map of Hawaii")
  map("worldHires",res=0,fill=TRUE,col=rgb(.8,.95,.8,.7),add=TRUE)
  lines(hawaii.sites,type="o",lty=2,lwd=2,pch=21,
        col="yellow",bg=mar_col2alpha("yellow",.9),cex=1.2)
  text(hawaii.sites[,1], hawaii.sites[,2],
       lab=rownames(hawaii.sites),pos=c(3,3,4,4,1,2),col="yellow")

# Computing and plotting the depth profile for this path
  profile <- mar_path_profile(hawaii.sites,hawaii,plot=TRUE,
                          main="Depth profile along the path\nconnecting the 6 sites")
  summary(profile)
```
