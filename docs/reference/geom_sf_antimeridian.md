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

  Set of aesthetic mappings created by
  [`ggplot2::aes`](https://ggplot2.tidyverse.org/reference/aes.html).

- data:

  Data to display in this layer. Defaults to the data inherited from
  [`ggplot2::ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html).

- stat:

  Statistical transformation used by
  [`ggplot2::geom_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  Defaults to `"sf"`.

- position:

  Position adjustment. Defaults to `"identity"`.

- ...:

  Additional arguments passed to
  [`ggplot2::geom_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html).

- x_breaks:

  Breaks used for the x axis. The default lets ggplot2 choose breaks
  automatically. This only affects the longitude axis labels added by
  [`coord_sf_antimeridian`](https://besibo.github.io/marmap2/reference/coord_sf_antimeridian.md).

- na.rm, show.legend, inherit.aes:

  Arguments passed to
  [`ggplot2::geom_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html).

## Value

A list of ggplot2 components that can be added to a plot with `+`.

## See also

[`as_sf`](https://besibo.github.io/marmap2/reference/as_sf.md),
[`ggplot2::geom_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html),
[`coord_sf_antimeridian`](https://besibo.github.io/marmap2/reference/coord_sf_antimeridian.md)

## Examples

``` r
if (FALSE) { # \dontrun{
anti |>
  as_sf() |>
  ggplot2::ggplot() +
  geom_sf_antimeridian(ggplot2::aes(color = depth))
} # }
```
