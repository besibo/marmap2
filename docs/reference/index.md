# Package index

## Data import

<!-- end list -->

  - `get_noaa()` : Download bathymetry from NOAA ETOPO 2022
  - `get_noaa_erddap()` : Download bathymetry from NOAA ETOPO 2022
    through ERDDAP
  - `get_gebco()` : Download bathymetry from the GEBCO download service
  - `read_bathy()` : Read bathymetric data in XYZ format

## Bathy conversion and validation

<!-- end list -->

  - `as_bathy()` : Convert to bathymetric data in an object of class
    bathy
  - `as_xyz()` : Convert to xyz format
  - `bathy_to_tbl()` `tbl_to_bathy()` : Convert between bathy objects
    and tibbles
  - `as_sf()` : Convert bathymetric data to sf
  - `as_spatraster()` : Convert bathymetric data to a terra SpatRaster
  - `project_bathy()` : Project bathymetric grids
  - `griddify()` : Grid irregularly spaced bathymetric data
  - `reduce_bathy_resolution()` : Reduce the spatial resolution of
    bathymetric data

## Plotting

<!-- end list -->

  - `quickplot_bathy()` : Quickly plot bathymetric data
  - `geom_bathy()` : Plot bathymetric grids with ggplot2 and sf
    coordinates
  - `geom_coastline()` : Draw the coastline from bathymetric data
  - `coord_sf_antimeridian()` : Coordinate system for sf data around the
    antimeridian
  - `scale_fill_bathy()` `scale_colour_bathy()` `scale_color_bathy()`
    `bathy_palette()` `bathy_palettes()` : Bathymetry colour scales for
    ggplot2

## Package

<!-- end list -->

  - `marmap2` `marmap2-package` : marmap2: Import, Plot, and Analyze
    Bathymetric and Topographic Data
  - `summarise_bathy()` : Summarise bathymetric data
