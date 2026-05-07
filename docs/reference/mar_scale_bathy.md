# Adds a scale to a map

Uses geographic information from object of class `bathy` to calculate
and plot a scale in
kilometer.

## Usage

``` r
mar_scale_bathy(mat, deg=1, x="bottomleft", y=NULL, inset=10, angle=90, ...)

scaleBathy(
  mat,
  deg = 1,
  x = "bottomleft",
  y = NULL,
  inset = 10,
  angle = 90,
  ...
)
```

## Arguments

  - mat:
    
    bathymetric data matrix of class `bathy`, imported using
    `mar_read_bathy`

  - deg:
    
    the number of degrees of longitudes to convert into kilometers
    (default is 1)

  - x:
    
    longitude coordinate used to plot the scale on the map, or one of
    the supported position keywords (see Details).

  - y:
    
    latitude coordinate used to plot the scale on the map. Use `NULL`
    when `x` is a position keyword.

  - inset:
    
    when `x` is a keyword (e.g. `"bottomleft"`), `inset` is a percentage
    of the plotting space controlling the relative position of the
    plotted scale (see Examples)

  - angle:
    
    angle from the shaft of the arrow to the edge of the arrow head

  - ...:
    
    further arguments to be passed to `text`

## Value

a scale added to the active graphical device

## Details

`mar_scale_bathy` is a simple utility to add a scale to the lower left
corner of a `bathy` plot. The distance in kilometers between two points
separated by 1 degree longitude is calculated based on the minimum
latitude of the `bathy` object used to plot the map. Option `deg` allows
the user to plot the distance separating more than one degree (default
is one).

The plotting coordinates `x` and `y` either correspond to two points on
the map (i.e. longitude and latitude of the point where the scale should
be plotted), or correspond to a keyword (set with `x`, `y` being set to
`NULL`) from the list "bottomright", "bottomleft", "topright",
"topleft". When a keyword is used, the option `inset` controls how far
the scale will be from the edges of the plot.

## See also

`mar_plot_bathy`

## Author

Eric Pante

## Examples

``` r
# load NW Atlantic data and convert to class bathy
  data(nw.atlantic)
  atl <- mar_as_bathy(nw.atlantic)

# a simple example
  plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
  mar_scale_bathy(atl, deg=4)

# using keywords to place the scale with inset=10%
  par(mfrow=c(2,2))
  plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
  mar_scale_bathy(atl, deg=4, x="bottomleft", y=NULL)
  plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
  mar_scale_bathy(atl, deg=4, x="bottomright", y=NULL)

# using keywords to place the scale with inset=20%
  plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
  mar_scale_bathy(atl, deg=4, x="topleft", y=NULL, inset=20)
  plot(atl, deep=-8000, shallow=-1000, step=1000, lwd=0.5, col="grey")
  mar_scale_bathy(atl, deg=4, x="topright", y=NULL, inset=20)
```
