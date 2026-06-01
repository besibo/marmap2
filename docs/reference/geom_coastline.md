# Draw the coastline from bathymetric data

`geom_coastline()` draws the `0 m` contour line from a regular
bathymetric grid. It is a small convenience wrapper around
`ggplot2::geom_contour` with `breaks = 0`.

## Usage

``` r
geom_coastline(
  mapping = NULL,
  data = NULL,
  ...,
  lon = "lon",
  lat = "lat",
  depth = "depth",
  colour = "black",
  linewidth = 0.6,
  linetype = "solid",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

  - mapping:
    
    Set of aesthetic mappings created by `ggplot2::aes`. If `x`, `y`, or
    `z` are missing, they default to `lon`, `lat`, and `depth`.

  - data:
    
    Data to display in this layer. Defaults to the data inherited from
    `ggplot2::ggplot`.

  - ...:
    
    Additional arguments passed to `ggplot2::geom_contour`.

  - lon, lat, depth:
    
    Character. Names of the longitude, latitude, and depth columns used
    when the corresponding aesthetics are not supplied in `mapping`.

  - colour, linewidth, linetype:
    
    Default line style. These can be changed to customize the coastline.

  - na.rm, show.legend, inherit.aes:
    
    Arguments passed to `ggplot2::geom_contour`.

## Value

A ggplot2 layer.

## See also

`geom_bathy`, `ggplot2::geom_contour`

## Examples

``` r
if (FALSE) { # \dontrun{
dat |>
  ggplot2::ggplot() +
  geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
  geom_coastline()

dat |>
  ggplot2::ggplot() +
  geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
  geom_coastline(colour = "grey25", linewidth = 0.6, linetype = "dashed")
} # }
```
