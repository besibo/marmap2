# Etopo colours

Various ways to access the colors on the etopo color scale

## Usage

``` r
etopo

etopo_colors(n)

scale_fill_etopo(...)
scale_color_etopo(...)

scale_fill_etopo(...)

scale_color_etopo(...)
```

## Arguments

  - n:
    
    number of colors to get from the scale. Those are evenly spaced
    within the scale.

  - ...:
    
    passed to `scale_fill_gradientn` or `scale_color_gradientn`

## Details

`etopo_colors` is equivalent to other color scales in R (e.g.
`grDevices::heat.colors`, `grDevices::cm.colors`).

`scale_fill/color_etopo` are meant to be used with ggplot2. They allow
consistent plots in various subregions by setting the limits of the
scale explicitly.

## See also

`autoplot_bathy`, `palette_bathy`

## Author

Jean-Olivier Irisson

## Examples

``` r
# load NW Atlantic data and convert to class bathy
data(nw.atlantic)
atl <- as_bathy(nw.atlantic)

# plot with base graphics
plot(atl, image=TRUE)

# using the etopo color scale
etopo_cols <- rev(etopo_colors(8))
plot(atl, image=TRUE, bpal=list(
  c(min(atl), 0, etopo_cols[1:2]),
  c(0, max(atl), etopo_cols[3:8])
))


# plot using ggplot2; in which case the limits of the scale are automatic
library("ggplot2")
ggplot(atl, aes(x=x, y=y)) + coord_quickmap() +
  # background
  geom_raster(aes(fill=z)) +
  scale_fill_etopo() +
  # countours
  geom_contour(aes(z=z),
    breaks=c(0, -100, -200, -500, -1000, -2000, -4000),
    colour="black", size=0.2
  ) +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0))
```
