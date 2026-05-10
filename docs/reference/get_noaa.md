# Download bathymetry from NOAA ETOPO 2022

Imports bathymetric and topographic data from the NOAA ETOPO 2022 image
service, given coordinate bounds and a requested spatial resolution.

## Usage

``` r
get_noaa(
  lon = NULL,
  lat = NULL,
  lon1 = NULL,
  lon2 = NULL,
  lat1 = NULL,
  lat2 = NULL,
  resolution = 4,
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

  First longitude bound of the area for which bathymetric data will be
  downloaded, in decimal degrees. Alternative to `lon`.

- lon2:

  Second longitude bound of the area for which bathymetric data will be
  downloaded, in decimal degrees. Alternative to `lon`.

- lat1:

  First latitude bound of the area for which bathymetric data will be
  downloaded, in decimal degrees. Alternative to `lat`.

- lat2:

  Second latitude bound of the area for which bathymetric data will be
  downloaded, in decimal degrees. Alternative to `lat`.

- resolution:

  Requested grid resolution in arc-minutes. Defaults to `4`.

- antimeridian:

  Logical. Whether the requested region crosses the antimeridian,
  longitude 180 or -180.

- keep:

  Logical. Whether to write the downloaded xyz table to disk. Defaults
  to `FALSE`.

- path:

  Directory used for cached csv files when `keep = TRUE`, and where
  `get_noaa()` looks for already downloaded matching data. Defaults to
  the current working directory.

- class:

  Character. Class of the returned object. Use `"tbl"` (default) to
  return a tibble with columns `lon`, `lat`, and `depth`; use `"bathy"`
  to return a historical matrix of class `bathy`.

## Value

A tibble by default, or an object of class `bathy` when
`class = "bathy"`. If `keep = TRUE`, a csv file containing the
downloaded xyz table is written to `path`. This file is named using the
format `marmap_coord_COORDINATES_res_RESOLUTION.csv`, with coordinates
separated by semicolons; antimeridian requests add the `_anti` suffix.

## Details

`get_noaa()` queries the ETOPO 2022 database hosted by NOAA, using the
coordinates of the area of interest and the desired resolution. The
function uses the NOAA ArcGIS image service and returns a long tibble by
default, or a matrix of class `bathy` when `class = "bathy"`.

The `resolution` argument is expressed in arc-minutes. The function uses
the 15 arc-second ETOPO 2022 layer for `resolution = 0.25`, the 30
arc-second layer for `resolution = 0.5`, and the 60 arc-second layer for
coarser resolutions. Values lower than `0.5` are rounded to `0.25`;
values between `0.5` and `1` are rounded to `0.5`.

Users can optionally write the downloaded data to disk with
`keep = TRUE`. If an identical query is performed later, using the same
longitudes, latitudes, resolution, and antimeridian setting,
`get_noaa()` will load the local file instead of querying the NOAA
server again. This behaviour should be used preferentially to reduce
unnecessary queries to the NOAA service and to reduce data loading time.
If several identical queries should be forced to download fresh data,
the cached csv file must be renamed, removed, or moved outside `path`.

`get_noaa()` can download bathymetric data around the antimeridian when
`antimeridian = TRUE`. The antimeridian is the 180th meridian, located
in the Pacific Ocean, east of New Zealand and Fiji and west of Hawaii
and Tonga. For a pair of longitude values such as `-150` and `150`, two
different areas can be requested: the 60 degree-wide area centered on
the antimeridian when `antimeridian = TRUE`, or the 300 degree-wide area
centered on the prime meridian when `antimeridian = FALSE`. Data around
the antimeridian require two distinct NOAA queries, so `keep = TRUE` can
be especially useful in this case.

The order of longitude and latitude bounds does not matter: `get_noaa()`
sorts the coordinate bounds internally before querying NOAA. Longitude
and latitude bounds should preferably be supplied with the vector syntax
`lon = c(lon1, lon2)` and `lat = c(lat1, lat2)`. The explicit `lon1`,
`lon2`, `lat1`, and `lat2` arguments remain available for compatibility
with older code.

## References

NOAA National Centers for Environmental Information. 2022: ETOPO 2022 15
Arc-Second Global Relief Model. NOAA National Centers for Environmental
Information.
[doi:10.25921/fd45-gt74](https://doi.org/10.25921/fd45-gt74)

## See also

[`get_gebco`](https://besibo.github.io/marmap2/reference/get_gebco.md),
[`read_bathy`](https://besibo.github.io/marmap2/reference/read_bathy.md),
[`bathy_to_tbl`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md),
[`tbl_to_bathy`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md),
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Query NOAA ETOPO 2022 for the North Atlantic at 10 arc-minutes.
atl <- get_noaa(
  lon = c(-20, -90),
  lat = c(50, 20),
  resolution = 10
)

# Same query using explicit lon1/lon2/lat1/lat2 arguments.
atl_tbl <- get_noaa(
  lon1 = -20, lon2 = -90,
  lat1 = 50, lat2 = 20,
  resolution = 10
)

# Download speed for a 10 x 10 degree area at 30 arc-minutes.
system.time(get_noaa(lon = c(0, 10), lat = c(0, 10), resolution = 30))

# Antimeridian request around the Aleutian Islands.
aleu <- get_noaa(
  lon = c(165, -145),
  lat = c(50, 65),
  resolution = 5,
  antimeridian = TRUE
)
} # }
```
