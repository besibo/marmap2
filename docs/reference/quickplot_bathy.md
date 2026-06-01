# Quickly plot bathymetric data

`quickplot_bathy()` creates a simple bathymetric/topographic map from a
tibble/data frame or a historical `bathy` object, with sensible defaults
for most situations. It is intended for quick visual checks after
downloading data with `get_noaa` or `get_gebco`.

## Usage

``` r
quickplot_bathy(
  x,
  lon = "lon",
  lat = "lat",
  depth = "depth",
  ocean_breaks = seq(0, -6000, by = -500),
  land_breaks = seq(0, 2500, by = 500),
  contour_colour = "grey20",
  contour_linewidth = 0.2,
  coastline_colour = "black",
  coastline_linewidth = 0.4,
  palette_ocean = "ocean_blues",
  palette_land = "land_hcl",
  expand = FALSE,
  theme = ggplot2::theme_bw(),
  ...
)
```

## Arguments

  - x:
    
    A data frame/tibble with longitude, latitude, and depth columns, or
    an object inheriting from class `bathy`.

  - lon, lat, depth:
    
    Character. Names of the longitude, latitude, and depth columns when
    `x` is a data frame/tibble.

  - ocean\_breaks, land\_breaks:
    
    Numeric vectors giving contour breaks for ocean depths and land
    elevations.

  - contour\_colour, contour\_linewidth:
    
    Colour and linewidth used for bathymetric/topographic contour lines.

  - coastline\_colour, coastline\_linewidth:
    
    Colour and linewidth used for the coastline.

  - palette\_ocean, palette\_land:
    
    Palettes passed to `scale_fill_bathy`.

  - expand:
    
    Logical or character vector passed to `geom_bathy`. Defaults to
    `FALSE` to remove padding around the downloaded grid.

  - theme:
    
    ggplot2 theme added to the plot. Defaults to `ggplot2::theme_bw`.

  - ...:
    
    Additional arguments passed to `geom_bathy`.

## Value

A ggplot object.

## See also

`geom_bathy`, `geom_coastline`, `scale_fill_bathy`

## Examples

``` r
if (FALSE) { # \dontrun{
dat <- get_gebco(lon = c(2, 7), lat = c(42, 44))
quickplot_bathy(dat)
} # }
```
