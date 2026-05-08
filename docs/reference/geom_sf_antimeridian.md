# Plot sf bathymetry around the antimeridian

Adds an `sf` layer with longitude axis labels adapted for data stored in
the 0-360 longitude convention around the antimeridian.

## Usage

``` r
geom_sf_antimeridian(
  mapping = NULL,
  data = NULL,
  stat = "sf",
  position = "identity",
  ...,
  x_breaks = ggplot2::waiver(),
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

  - mapping:
    
    Set of aesthetic mappings created by `ggplot2::aes`.

  - data:
    
    Data to display in this layer. Defaults to the data inherited from
    `ggplot2::ggplot`.

  - stat:
    
    Statistical transformation used by `ggplot2::geom_sf`. Defaults to
    `"sf"`.

  - position:
    
    Position adjustment. Defaults to `"identity"`.

  - ...:
    
    Additional arguments passed to `ggplot2::geom_sf`.

  - x\_breaks:
    
    Breaks used for the x axis. The default lets ggplot2 choose breaks
    automatically. This only affects the longitude axis labels added by
    `coord_sf_antimeridian`.

  - na.rm, show.legend, inherit.aes:
    
    Arguments passed to `ggplot2::geom_sf`.

## Value

A list of ggplot2 components that can be added to a plot with `+`.

## See also

`as_sf`, `ggplot2::geom_sf`, `coord_sf_antimeridian`

## Examples

``` r
if (FALSE) { # \dontrun{
anti |>
  as_sf() |>
  ggplot2::ggplot() +
  geom_sf_antimeridian(ggplot2::aes(color = depth))
} # }
```
