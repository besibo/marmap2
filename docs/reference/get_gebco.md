# Download bathymetry from the GEBCO download service

Downloads a user-defined geographic subset from the official GEBCO
download service and returns it as a tibble or an object of class
`bathy`.

## Usage

``` r
get_gebco(
  lon = NULL,
  lat = NULL,
  lon1 = NULL,
  lon2 = NULL,
  lat1 = NULL,
  lat2 = NULL,
  resolution = 1,
  antimeridian = FALSE,
  keep = FALSE,
  path = NULL,
  class = c("tbl", "bathy")
)
```

## Arguments

- lon:

  Numeric vector of length 2 giving the longitude bounds in decimal
  degrees. This is the recommended syntax.

- lat:

  Numeric vector of length 2 giving the latitude bounds in decimal
  degrees. This is the recommended syntax.

- lon1:

  First longitude bound in decimal degrees. Alternative to `lon`.

- lon2:

  Second longitude bound in decimal degrees. Alternative to `lon`.

- lat1:

  First latitude bound in decimal degrees. Alternative to `lat`.

- lat2:

  Second latitude bound in decimal degrees. Alternative to `lat`.

- resolution:

  Output grid spacing in arc-minutes. Defaults to `1`. The GEBCO global
  NetCDF subset is downloaded at its native 15 arc-second resolution,
  then resampled locally with nearest-neighbour selection when
  `resolution > 0.25`. Values lower than `0.25` return the native GEBCO
  global grid resolution.

- antimeridian:

  Logical. If `TRUE`, the requested longitudinal range is interpreted as
  crossing the antimeridian. The function downloads two GEBCO subsets
  and stitches them into one `bathy` object. The order of `lon1` and
  `lon2` does not matter.

- keep:

  Logical. If `TRUE`, the xyz table returned as a `bathy` object is also
  written as a csv file in `path`.

- path:

  Directory used for cached csv files when `keep = TRUE`, and where
  `get_gebco` looks for an already downloaded matching csv file.
  Defaults to the current working directory.

- class:

  Character. Class of the returned object. Use `"tbl"` (default) to
  return a tibble with columns `lon`, `lat`, and `depth`; use `"bathy"`
  to return a historical matrix of class `bathy`.

## Value

A tibble by default, or an object of class `bathy` when
`class = "bathy"`. If `keep = TRUE`, a csv copy of the downloaded xyz
table is written to `path`.

## Details

`get_gebco` uses the workflow implemented by the official GEBCO Grid
Subsetting App at <https://download.gebco.net/>. The function submits a
small JSON basket to `/api/queue`, polls `/api/queue/status/{basketId}`
until the basket is ready, downloads the resulting zip archive from
`/api/queue/download/{basketId}`, extracts the NetCDF file, reads the
`lat`, `lon`, and `elevation` variables, and converts them to the
requested output class.

The current global GEBCO grids are served by the GEBCO download service
at their native resolution of 15 arc-seconds, i.e. 0.25 arc-minutes or
0.0041667 decimal degrees. This corresponds to approximately 463 m at
the equator. The `resolution` argument is expressed in arc-minutes for
consistency with
[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md),
but it is not sent to the GEBCO API: the NetCDF file is downloaded at
native resolution, then resampled locally with nearest-neighbour
selection on a regular grid if `resolution` is larger than 0.25. Values
smaller than 0.25 therefore do not increase the spatial resolution and
return the native grid.

GEBCO also exposes some higher-resolution regional or experimental
products through the same download service, for example polar grids or
beta multi-resolution layers. This function intentionally targets the
default global longitude/latitude bathymetry layer whose NetCDF
variables are named `lon`, `lat`, and `elevation`.

The GEBCO download service expects `left <= right`; areas crossing the
antimeridian are therefore downloaded as two geographic subsets, one
from the eastern longitude bound to 180 degrees and one from -180
degrees to the western longitude bound. The two subsets are then
stitched into a single `bathy` object whose longitudes are expressed in
the 0-360 degree range. As in
[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md),
the order of `lon1`/`lon2` and `lat1`/`lat2` does not matter: the
function sorts the coordinate bounds internally before submitting
requests to GEBCO.

## References

GEBCO Compilation Group. GEBCO Grid, a continuous terrain model for
oceans and land at 15 arc-second intervals. <https://www.gebco.net/>

## See also

[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md),
[`read_bathy`](https://besibo.github.io/marmap2/reference/read_bathy.md),
[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Download a one-degree subset from the official GEBCO service
b <- get_gebco(
  lon = c(-6, -5),
  lat = c(49, 50),
  resolution = 1
)

} # }
```
