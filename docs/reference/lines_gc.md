# Add Great Circle lines on a map

`lines_gc` draws Great Circle lines between a set of start and end
points on an existing map.

## Usage

``` r
lines_gc(start.points, end.points, n = 10, antimeridian = FALSE, ...)
```

## Arguments

  - start.points:
    
    Two-column data.frame or matrix of longitudes and latitudes for
    start points.

  - end.points:
    
    Two-column data.frame or matrix of longitudes and latitudes for end
    points. The dimensions of `start.points` and `end.points` must be
    compatible (*i.e.* they must have the same number of rows).

  - n:
    
    Numeric. The number of intermediate points to add along the great
    circle line between the start end end points.

  - antimeridian:
    
    Logical indicating if the map on which the great circle lines will
    be plotted covers the antimeridian region. The antimeridian (or
    antemeridian) is the 180th meridian and is located in the middle of
    the Pacific Ocean, east of New Zealand and Fidji, west of Hawaii and
    Tonga.

  - ...:
    
    Further arguments to be passed to `lines` to control the aspect of
    the lines to draw.

## Details

`lines_gcD` takes advantage of the `gcIntermediate` function from
package `geosphere` to plot lines following a great circle. When working
with `marmap` maps encompassing the antimeridian, longitudes are
numbered from 0 to 360 (as opposed to the classical numbering from -180
to +180). It is thus critical to set `antimeridian=TRUE` to avoid
plotting incoherent great circle lines.

## See also

`distance_to_isobath`, `least_cost_distance`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# Load NW Atlantic data and convert to class bathy
data(nw.atlantic)
atl <- as_bathy(nw.atlantic)

# Create vectors of latitude and longitude
lon <- c(-70, -65, -63, -55, -48)
lat <- c(33, 35, 40, 37, 33)

# Compute distances between each point and the -200m isobath
d <- distance_to_isobath(atl, lon, lat, isobath = -200)
d

# Create a nice palette of bleus for the bathymetry
blues <- c("lightsteelblue4","lightsteelblue3","lightsteelblue2","lightsteelblue1")

# Visualize the great circle distances
plot(atl, image=TRUE, lwd=0.1, land=TRUE,
   bpal = list(c(0,max(atl),"grey"), c(min(atl),0,blues)))
points(lon,lat, pch=21, col="orange4", bg="orange2", cex=.8)
lines_gc(d[2:3],d[4:5])

# Load aleutians data and plot the map
data(aleutians)
plot(aleutians, image=TRUE, lwd=0.1, land=TRUE,
   bpal = list(c(0,max(aleutians),"grey"), c(min(aleutians),0,blues)))

# define start and end points
start <- matrix(c(170,55, 190, 60), ncol=2, byrow=TRUE, dimnames=list(1:2, c("lon","lat")))
end <- matrix(c(200, 56, 201, 57), ncol=2, byrow=TRUE, dimnames=list(1:2, c("lon","lat")))
start
end

# Add points and great circle distances on the map
points(start, pch=21, col="orange4", bg="orange2", cex=.8)
points(end, pch=21, col="orange4", bg="orange2", cex=.8)
lines_gc(start, end, antimeridian=TRUE)
```
