# Project bathymetric grids

Projects bathymetric data to a destination coordinate reference system
and returns a tibble suitable for plotting with
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md).

## Usage

``` r
project_bathy(
  x,
  crs_to,
  crs_from = "EPSG:4326",
  resolution = NULL,
  method = "bilinear",
  lon = "lon",
  lat = "lat",
  depth = "depth",
  names = c("lon", "lat", "depth"),
  na.rm = TRUE
)
```

## Arguments

- x:

  A data frame/tibble with longitude, latitude, and depth columns, or an
  object inheriting from class `bathy`.

- crs_to:

  Destination coordinate reference system. Can be a CRS string such as
  `"EPSG:3857"`, or a numeric EPSG code such as `3857`. Passed to
  [`terra::project`](https://rspatial.github.io/terra/reference/project.html).

- crs_from:

  Source coordinate reference system. Defaults to `"EPSG:4326"`. Can
  also be supplied as a numeric EPSG code such as `4326`.

- resolution:

  Optional output resolution in destination map units. If `NULL`, terra
  chooses a suitable resolution.

- method:

  Resampling method passed to
  [`terra::project`](https://rspatial.github.io/terra/reference/project.html).
  Use `"bilinear"` for continuous bathymetry/elevation values or
  `"near"` for nearest neighbour resampling.

- lon, lat, depth:

  Column names used when `x` is a data frame/tibble.

- names:

  Character vector of length 3 giving the names of the projected
  coordinate and depth columns in the returned tibble. Defaults to
  `c("lon", "lat", "depth")`.

- na.rm:

  Logical. If `TRUE`, cells with missing depth values are removed from
  the returned tibble.

## Value

A tibble with projected coordinates and depth values. The source CRS,
destination CRS, and projected
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
are stored in attributes named `crs_from`, `crs_to`, and `spatraster`.

## Details

Projection of a regular longitude/latitude bathymetric grid generally
requires resampling. `project_bathy()` therefore converts the input to a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
projects the raster with
[`terra::project()`](https://rspatial.github.io/terra/reference/project.html),
and converts the projected grid back to a long tibble. The output is not
a `bathy` object because projected coordinates are not
longitude/latitude row and column names.

To plot the projected result with
[`geom_bathy()`](https://besibo.github.io/marmap2/reference/geom_bathy.md),
use `coord = "fixed"` because the returned `lon` and `lat` columns
contain projected coordinates, not geographic longitude/latitude values:


    dat_proj |>
      ggplot2::ggplot() +
      geom_bathy(
        ggplot2::aes(lon, lat, fill = depth),
        coord = "fixed"
      ) +
      ggplot2::labs(x = "Easting", y = "Northing")

## See also

[`as_spatraster`](https://besibo.github.io/marmap2/reference/as_spatraster.md),
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md),
[`terra::project`](https://rspatial.github.io/terra/reference/project.html)

## Examples

``` r
if (requireNamespace("terra", quietly = TRUE)) {
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )

  xyz_proj <- project_bathy(xyz, crs_to = 3857)
  head(xyz_proj)
}
#> # A tibble: 6 × 3
#>        lon      lat  depth
#>      <dbl>    <dbl>  <dbl>
#> 1 -540488. 6461552.  -71.0
#> 2 -396948. 6461552. -118. 
#> 3 -540488. 6318013.  -78.5
#> 4 -396948. 6318013. -126. 
#> 5 -540488. 6174473.  -87.0
#> 6 -396948. 6174473. -134. 
```
