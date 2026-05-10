# Plot bathymetric grids with ggplot2 and sf coordinates

Adds a raster-like bathymetry layer from a long table, a point `sf`
object, or a `bathy` object. The data are kept as regular x/y/z data, so
other ggplot2 layers such as `ggplot2::geom_contour` can be added to the
same plot. A `ggplot2::coord_sf` coordinate system is added
automatically, or `coord_sf_antimeridian` when `antimeridian = TRUE`.
Projected tibbles returned by `project_bathy` are detected automatically
and plotted with `ggplot2::coord_sf` using their projected CRS.

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
    
    Set of aesthetic mappings created by `ggplot2::aes`. If `x`, `y`, or
    `fill` are missing, they default to `lon`, `lat`, and `depth`.

  - data:
    
    A long data frame/tibble, a point `sf` object, or a `bathy` object.
    If `NULL`, data are inherited from `ggplot2::ggplot`.

  - ...:
    
    Additional arguments passed to `ggplot2::geom_tile` or
    `ggplot2::geom_raster`. For `geom = "tile"`, cell borders are
    coloured like the fill by default to mask anti-aliasing seams
    between adjacent tiles.

  - lon, lat, depth:
    
    Character. Names of the longitude, latitude, and depth columns.

  - geom:
    
    Character. Rendering geom, either `"tile"` or `"raster"`. `"tile"`
    is the default because it works quietly with `ggplot2::coord_sf`.
    With `coord_sf()`, ggplot2 draws `geom_raster()` through a rectangle
    fallback and may emit an informational message.

  - crs:
    
    Coordinate reference system used by `ggplot2::coord_sf` for non-`sf`
    layers. Defaults to `4326`, i.e. WGS84 longitude/latitude.

  - antimeridian:
    
    Logical. If `TRUE`, uses longitude labels adapted to data crossing
    the antimeridian.

  - coord:
    
    Character. Coordinate system to add. `"auto"` is the default and
    uses `"sf"` for geographic and projected bathymetry. Projected
    tibbles returned by `project_bathy` are detected automatically and
    their destination CRS is used. `"sf"` uses `ggplot2::coord_sf` or
    `coord_sf_antimeridian`. `"fixed"` uses `ggplot2::coord_fixed`.

  - asp:
    
    Numeric. Aspect ratio used when `coord = "fixed"`. The default `1`
    gives longitude and latitude degrees the same graphical scale.

  - x\_breaks:
    
    Breaks used for the x axis when `antimeridian = TRUE`. The default
    lets ggplot2 choose breaks automatically.

  - expand:
    
    Logical or character vector passed to `ggplot2::coord_sf`. Use
    `expand = FALSE` to remove padding around the bathymetric grid while
    keeping geographic axis labels.

  - na.rm, show.legend, inherit.aes:
    
    Arguments passed to the selected geom.

## Value

A list of ggplot2 components that can be added to a plot with `+`.

## See also

`coord_sf_antimeridian`, `geom_sf_antimeridian`, `as_sf`, `bathy_to_tbl`

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
