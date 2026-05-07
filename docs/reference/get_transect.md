# Compute approximate cross section along a depth transect

Compute the depth along a linear transect which bounds are specified by
the user.

## Usage

``` r
get_transect(mat, x1, y1, x2, y2, locator=FALSE, distance=FALSE, ...)
```

## Arguments

  - mat:
    
    bathymetric data matrix of class `bathy`, imported using
    `read_bathy` (no default)

  - x1:
    
    start longitude of the transect (no default)

  - y1:
    
    start latitude of the transect (no default)

  - x2:
    
    stop longitude of the transect (no default)

  - y2:
    
    stop latitude of the transect (no default)

  - locator:
    
    whether to use locator to choose transect bounds interactively with
    a map (default is `FALSE`)

  - distance:
    
    whether to compute the haversine distance (in km) from the start of
    the transect, along the transect (default is `FALSE`)

  - ...:
    
    other arguments to be passed to `locator()` to specify the
    characteristics of the points and lines to draw on the bathymetric
    map when `locator=TRUE`.

## Value

A table with, at least, longitude, latitude and depth along the
transect, and if specified (distance=`TRUE`), the distance in kilometers
from the start of the transect. The number of elements in the resulting
table depends on the resolution of the `bathy` object.

## Details

`get_transect` allows the user to compute an approximate linear depth
cross section either by inputing start and stop coordinates, or by
clicking on a map created with `plot_bathy`. In its interactive mode,
this function uses the `locator` function (`graphics` package); after
creating a map with `plot_bathy`, the user can click twice to delimit
the bound of the transect of interest (for example, lower left and upper
right corners of a rectangular area of interest), press Escape, and get
a table with the transect information.

## See also

`read_bathy`, `nw.atlantic`, `nw.atlantic.coast`, `get_depth`,
`get_sample`

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
# load datasets
  data(nw.atlantic); as_bathy(nw.atlantic) -> atl
  data(nw.atlantic.coast)

# Example 1. get_transect(), without use of locator()
  get_transect(atl, -65, 43,-59,40) -> test ; plot(test[,3]~test[,2],type="l")
  get_transect(atl, -65, 43,-59,40, distance=TRUE) -> test ; plot(test[,4]~test[,3],type="l")

# Example 2. get_transect(), without use of locator(); pretty plot
  par(mfrow=c(2,1),mai=c(1.2, 1, 0.1, 0.1))
  plot(atl, deep=-6000, shallow=-10, step=1000, lwd=0.5, col="grey50",drawlabels=TRUE)
  lines(nw.atlantic.coast)

  get_transect(atl, -75, 44,-46,32, loc=FALSE, dis=TRUE) -> test
  points(test$lon,test$lat,type="l",col="blue",lwd=2,lty=2)
  plot_profile(test)

# Example 3. get_transect(), with use of locator(); pretty plot
if (FALSE) { # \dontrun{
  par(mfrow=c(2,1),mai=c(1.2, 1, 0.1, 0.1))
  plot(atl, deep=-6000, shallow=-10, step=1000, lwd=0.5, col="grey50",drawlabels=TRUE)
  lines(nw.atlantic.coast)

  get_transect(atl, loc=TRUE, dis=TRUE, col=2, lty=2) -> test
  plot_profile(test)
  } # }
```
