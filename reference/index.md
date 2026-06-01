# Package index

## Data import

- [`get_noaa()`](https://besibo.github.io/marmap2/reference/get_noaa.md)
  : Download bathymetry from NOAA ETOPO 2022
- [`get_noaa_erddap()`](https://besibo.github.io/marmap2/reference/get_noaa_erddap.md)
  : Download bathymetry from NOAA ETOPO 2022 through ERDDAP
- [`get_gebco()`](https://besibo.github.io/marmap2/reference/get_gebco.md)
  : Download bathymetry from the GEBCO download service
- [`read_bathy()`](https://besibo.github.io/marmap2/reference/read_bathy.md)
  : Read bathymetric data in XYZ format

## Bathy conversion and validation

- [`as_bathy()`](https://besibo.github.io/marmap2/reference/as_bathy.md)
  : Convert to bathymetric data in an object of class bathy
- [`as_xyz()`](https://besibo.github.io/marmap2/reference/as_xyz.md) :
  Convert to xyz format
- [`bathy_to_tbl()`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md)
  [`tbl_to_bathy()`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md)
  : Convert between bathy objects and tibbles
- [`as_sf()`](https://besibo.github.io/marmap2/reference/as_sf.md) :
  Convert bathymetric data to sf
- [`as_spatraster()`](https://besibo.github.io/marmap2/reference/as_spatraster.md)
  : Convert bathymetric data to a terra SpatRaster
- [`project_bathy()`](https://besibo.github.io/marmap2/reference/project_bathy.md)
  : Project bathymetric grids
- [`griddify()`](https://besibo.github.io/marmap2/reference/griddify.md)
  : Grid irregularly spaced bathymetric data
- [`reduce_bathy_resolution()`](https://besibo.github.io/marmap2/reference/reduce_bathy_resolution.md)
  : Reduce the spatial resolution of bathymetric data

## Plotting

- [`quickplot_bathy()`](https://besibo.github.io/marmap2/reference/quickplot_bathy.md)
  : Quickly plot bathymetric data
- [`geom_bathy()`](https://besibo.github.io/marmap2/reference/geom_bathy.md)
  : Plot bathymetric grids with ggplot2 and sf coordinates
- [`geom_coastline()`](https://besibo.github.io/marmap2/reference/geom_coastline.md)
  : Draw the coastline from bathymetric data
- [`coord_sf_antimeridian()`](https://besibo.github.io/marmap2/reference/coord_sf_antimeridian.md)
  : Coordinate system for sf data around the antimeridian
- [`scale_fill_bathy()`](https://besibo.github.io/marmap2/reference/scale_fill_bathy.md)
  [`scale_colour_bathy()`](https://besibo.github.io/marmap2/reference/scale_fill_bathy.md)
  [`scale_color_bathy()`](https://besibo.github.io/marmap2/reference/scale_fill_bathy.md)
  [`bathy_palette()`](https://besibo.github.io/marmap2/reference/scale_fill_bathy.md)
  [`bathy_palettes()`](https://besibo.github.io/marmap2/reference/scale_fill_bathy.md)
  : Bathymetry colour scales for ggplot2

## Package

- [`marmap2`](https://besibo.github.io/marmap2/reference/marmap2-package.md)
  [`marmap2-package`](https://besibo.github.io/marmap2/reference/marmap2-package.md)
  : marmap2: Import, Plot, and Analyze Bathymetric and Topographic Data
- [`summarise_bathy()`](https://besibo.github.io/marmap2/reference/summarise_bathy.md)
  : Summarise bathymetric data
