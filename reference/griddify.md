# Grid irregularly spaced bathymetric data

`griddify()` converts irregularly spaced longitude/latitude/depth data
to a regular bathymetric grid. It is useful when external data are
available as scattered xyz points rather than as a regular raster-like
grid.

## Usage

``` r
griddify(
  x,
  nlon,
  nlat,
  lon = "lon",
  lat = "lat",
  depth = "depth",
  crs = 4326,
  interpolate = TRUE,
  radius = NULL,
  power = 2,
  class = c("tbl", "bathy", "spatraster")
)
```

## Arguments

- x:

  A data frame/tibble with longitude, latitude, and depth columns, a
  three-column matrix, a point `sf` object, a
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
  or a historical `bathy` object.

- nlon, nlat:

  Integer. Number of longitude and latitude cells in the target grid.

- lon, lat, depth:

  Character. Names of the longitude, latitude, and depth columns when
  `x` is tabular.

- crs:

  Coordinate reference system assigned to the target grid. Can be a CRS
  string such as `"EPSG:4326"` or a numeric EPSG code such as `4326`.

- interpolate:

  Logical. If `TRUE`, empty target cells are filled where possible by
  inverse distance weighting from the input points.

- radius:

  Numeric. Search radius used for inverse distance weighting when
  `interpolate = TRUE`. If `NULL`, a radius based on the target cell
  size is used.

- power:

  Numeric. Distance weighting power passed to
  [`terra::interpIDW`](https://rspatial.github.io/terra/reference/interpIDW.html).

- class:

  Character. Output class. `"tbl"` returns a tibble with columns `lon`,
  `lat`, and `depth`; `"bathy"` returns a historical `bathy` matrix;
  `"spatraster"` returns a
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html).

## Value

A tibble by default, or an object of class `bathy` or
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html).

## Details

Points falling in the same target cell are averaged. When
`interpolate = TRUE`, cells without observations are filled with inverse
distance weighting. This interpolation is intended as a pragmatic
gridding step for visualisation and exploratory mapping; it should not
be interpreted as a substitute for a domain-specific spatial
interpolation model.

## See also

[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`as_spatraster`](https://besibo.github.io/marmap2/reference/as_spatraster.md),
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md),
[`quickplot_bathy`](https://besibo.github.io/marmap2/reference/quickplot_bathy.md)

## Examples

``` r
set.seed(1)
xyz <- data.frame(
  lon = runif(100, -5, -3),
  lat = runif(100, 47, 49),
  depth = rnorm(100, -100, 30)
)

grid <- griddify(xyz, nlon = 30, nlat = 30)
summarise_bathy(grid)
#> Bathymetric data summary
#>   Class:      tbl_df/tbl/data.frame
#>   Dimensions: 30 longitude x 30 latitude (900 cells)
#>   Longitude:  4.941 W to 3.049 W
#>   Latitude:   47.06 N to 48.95 N
#>   Resolution: 3.914 x 3.918 arc-minutes
#>   Depth:      -157.4 to -30.76 (mean -99.86, median -101.1)
#>   Missing:    101
#>   Memory:     22.2 Kb
```
