# Plot bathymetric grids with ggplot2 and sf coordinates

Adds a raster-like bathymetry layer from a long table, a point `sf`
object, or a `bathy` object. The data are kept as regular x/y/z data, so
other ggplot2 layers such as
[`ggplot2::geom_contour`](https://ggplot2.tidyverse.org/reference/geom_contour.html)
can be added to the same plot. A
[`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
coordinate system is added automatically, or
[`coord_sf_antimeridian`](https://besibo.github.io/marmap2/reference/coord_sf_antimeridian.md)
when `antimeridian = TRUE`. Projected tibbles returned by
[`project_bathy`](https://besibo.github.io/marmap2/reference/project_bathy.md)
are detected automatically and plotted with
[`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
using their projected CRS.

## Usage

``` r
geom_bathy(
  mapping = NULL,
  data = NULL,
  ...,
  lon = "lon",
  lat = "lat",
  depth = "depth",
  geom = c("tile", "raster"),
  crs = 4326,
  antimeridian = FALSE,
  coord = c("auto", "sf", "fixed"),
  asp = 1,
  x_breaks = ggplot2::waiver(),
  expand = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`ggplot2::aes`](https://ggplot2.tidyverse.org/reference/aes.html). If
  `x`, `y`, or `fill` are missing, they default to `lon`, `lat`, and
  `depth`.

- data:

  A long data frame/tibble, a point `sf` object, or a `bathy` object. If
  `NULL`, data are inherited from
  [`ggplot2::ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html).

- ...:

  Additional arguments passed to
  [`ggplot2::geom_tile`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
  or
  [`ggplot2::geom_raster`](https://ggplot2.tidyverse.org/reference/geom_tile.html).
  For `geom = "tile"`, cell borders are coloured like the fill by
  default to mask anti-aliasing seams between adjacent tiles.

- lon, lat, depth:

  Character. Names of the longitude, latitude, and depth columns.

- geom:

  Character. Rendering geom, either `"tile"` or `"raster"`. `"tile"` is
  the default because it works quietly with
  [`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  With
  [`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html),
  ggplot2 draws
  [`geom_raster()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
  through a rectangle fallback and may emit an informational message.

- crs:

  Coordinate reference system used by
  [`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
  for non-`sf` layers. Defaults to `4326`, i.e. WGS84
  longitude/latitude.

- antimeridian:

  Logical. If `TRUE`, uses longitude labels adapted to data crossing the
  antimeridian.

- coord:

  Character. Coordinate system to add. `"auto"` is the default and uses
  `"sf"` for geographic and projected bathymetry. Projected tibbles
  returned by
  [`project_bathy`](https://besibo.github.io/marmap2/reference/project_bathy.md)
  are detected automatically and their destination CRS is used. `"sf"`
  uses
  [`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
  or
  [`coord_sf_antimeridian`](https://besibo.github.io/marmap2/reference/coord_sf_antimeridian.md).
  `"fixed"` uses
  [`ggplot2::coord_fixed`](https://ggplot2.tidyverse.org/reference/coord_fixed.html).

- asp:

  Numeric. Aspect ratio used when `coord = "fixed"`. The default `1`
  gives longitude and latitude degrees the same graphical scale.

- x_breaks:

  Breaks used for the x axis when `antimeridian = TRUE`. The default
  lets ggplot2 choose breaks automatically.

- expand:

  Logical or character vector passed to
  [`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  Use `expand = FALSE` to remove padding around the bathymetric grid
  while keeping geographic axis labels.

- na.rm, show.legend, inherit.aes:

  Arguments passed to the selected geom.

## Value

A list of ggplot2 components that can be added to a plot with `+`.

## See also

[`coord_sf_antimeridian`](https://besibo.github.io/marmap2/reference/coord_sf_antimeridian.md),
[`geom_sf_antimeridian`](https://besibo.github.io/marmap2/reference/geom_sf_antimeridian.md),
[`as_sf`](https://besibo.github.io/marmap2/reference/as_sf.md),
[`bathy_to_tbl`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)

xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

xyz |>
  ggplot() +
  geom_bathy() +
  geom_contour(aes(lon, lat, z = depth), color = "white")
} # }
```
