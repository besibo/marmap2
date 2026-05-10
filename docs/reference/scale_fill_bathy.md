# Bathymetry colour scales for ggplot2

`scale_fill_bathy()` provides perceptually ordered colour scales for
bathymetric and topographic rasters drawn with ggplot2. The ocean and
land parts of the scale are selected independently:

- use a palette name to map a side with a colour gradient;

- use a single colour name or code to draw a side with a constant
  colour;

- use `NULL` to leave a side undefined;

- use both `palette_ocean` and `palette_land` to map depths and
  altitudes with separate palettes joined at sea level.

## Usage

``` r
scale_fill_bathy(
  palette_ocean = "ocean_blues",
  palette_land = "land_earth",
  limits = NULL,
  mode = c("rescale", "truncate"),
  na.value = "grey90",
  name = "depth",
  oob = NULL,
  ...
)

bathy_palette(palette = "ocean_blues", n = 256)

bathy_palettes(type = c("all", "ocean", "land"))
```

## Arguments

- palette_ocean, palette_land:

  Palette definition used for ocean values (`<= 0`) and land values
  (`>= 0`), respectively. Can be a palette name, a single colour, a
  vector of colours, a function taking `n` and returning colours, or
  `NULL`.

- limits:

  Numeric vector of length two. Limits of the fill scale. If `NULL`, the
  scale limits are trained from the plotted data.

- mode:

  Character. Either `"rescale"` or `"truncate"`. With `"truncate"`, the
  legend spans the data range but colours remain anchored to fixed
  bathymetric/topographic reference depths, so the same depth or
  altitude keeps the same colour across maps. With `"rescale"`, the
  selected palette part is stretched over the plotted data range.

- na.value:

  Colour used for missing values.

- name:

  Scale name passed to
  [`ggplot2::scale_fill_gradientn`](https://ggplot2.tidyverse.org/reference/scale_gradient.html).

- oob:

  Function used for out-of-bounds values. If `NULL`, values are squished
  to the nearest scale limit.

- ...:

  Additional arguments passed to
  [`ggplot2::scale_fill_gradientn`](https://ggplot2.tidyverse.org/reference/scale_gradient.html).

- palette:

  Palette name, single colour, colour vector, or function taking `n` and
  returning colours.

- n:

  Integer. Number of colours returned by `bathy_palette()`.

- type:

  Character. Palette family to list. One of `"all"`, `"ocean"`, or
  `"land"`.

## Value

A ggplot2 fill scale.

For `bathy_palette()`, a character vector of colours. For
`bathy_palettes()`, a character vector of palette names.

## See also

[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md),
`bathy_palette`, `bathy_palettes`

## Examples

``` r
if (FALSE) { # \dontrun{
dat |>
  ggplot2::ggplot() +
  geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
  scale_fill_bathy(palette_land = "grey85")

dat |>
  ggplot2::ggplot() +
  geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
  scale_fill_bathy(
    palette_ocean = "ocean_blues",
    palette_land = "land_hcl"
  )

dat |>
  ggplot2::ggplot() +
  geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
  scale_fill_bathy(palette_ocean = "#D8EEF3", palette_land = "land_hcl")

dat |>
  ggplot2::ggplot() +
  geom_bathy(ggplot2::aes(lon, lat, fill = depth), expand = FALSE) +
  scale_fill_bathy(
    palette_ocean = grDevices::hcl.colors(256, "Blues 3"),
    palette_land = function(n) grDevices::hcl.colors(n, "Terrain 2")
  )
} # }
```
