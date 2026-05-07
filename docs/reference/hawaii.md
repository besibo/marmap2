# Bathymetric data for Hawaii, USA

Bathymetric object of class `bathy` created from NOAA GEODAS data and
arbitrary locations around the main Hawaiian islands.

## Usage

``` r
data(hawaii)
data(hawaii.sites)
```

## Value

`hawaii`: a bathymetric object of class `bathy` with 539 rows and 659
columns. `hawaii.sites`: data.frame (6 rows, 2 columns)

## Details

`hawaii` contains data imported from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>) and transformed into an
object of class `bathy` by `mar_read_bathy`. `hawaii.sites` is a
2-columns data.frame containing longitude and latitude of 6 locations
spread at sea around Hawaii.

## See also

`mar_plot_bathy`, `mar_summary_bathy`

## Author

see <https://www.ncei.noaa.gov/maps/grid-extract/>

## Examples

``` r
# load hawaii data
  data(hawaii)
  data(hawaii.sites)

# class "bathy"
  class(hawaii)
  summary(hawaii)

if (FALSE) { # \dontrun{
## use of mar_plot_bathy to produce a bathymetric map
# creation of a color palette
  pal <- colorRampPalette(c("black","darkblue","blue","lightblue"))

# Plotting the bathymetry
  plot(hawaii,image=TRUE,draw=TRUE,bpal=pal(100),asp=1,col="grey40",lwd=.7)

# Adding coastline
  require(mapdata)
  map("worldHires",res=0,fill=TRUE,col=rgb(.8,.95,.8,.7),add=TRUE)

# Adding hawaii.sites location on the map
  points(hawaii.sites,pch=21,col="yellow",bg=mar_col2alpha("yellow",.9),cex=1.2)
} # }
```
