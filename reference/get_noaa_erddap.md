# Download bathymetry from NOAA ETOPO 2022 through ERDDAP

Experimental ERDDAP-based downloader for NOAA ETOPO 2022 bathymetry. It
uses the ERDDAP `griddap` endpoint, which can return NetCDF subsets
directly and can reduce download size by requesting one native grid
point every `stride` cells.

## Usage

``` r
get_noaa_erddap(
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
  progress = TRUE,
  timeout = 300,
  connect_timeout = 60,
  base_url = noaa_erddap_default_base_urls(),
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

- lon1, lon2, lat1, lat2:

  Explicit coordinate bounds, kept for compatibility with older calling
  styles.

- resolution:

  Requested grid resolution in arc-minutes. The value is converted to
  the nearest ERDDAP stride from the native 0.25 arc-minute grid.

- antimeridian:

  Logical. Whether the requested region crosses the antimeridian.

- keep:

  Logical. Whether to write the downloaded xyz table to disk.

- path:

  Directory used for cached csv files when `keep = TRUE`, and where
  cached files are searched before downloading.

- progress:

  Logical. If `TRUE`, show curl's download progress when the server
  provides enough information. If a precise progress bar is not
  possible, the function still reports the expected grid size.

- timeout:

  Timeout in seconds for the ERDDAP download request. Defaults to `300`.

- connect_timeout:

  Timeout in seconds for the initial connection to each ERDDAP server.
  Defaults to `60`.

- base_url:

  ERDDAP griddap endpoint(s). Defaults to NOAA OceanWatch and NOAA
  CoastWatch endpoints. If several endpoints are provided, they are
  tried in order until one succeeds.

- class:

  Character. Class of the returned object. Use `"tbl"` (default) to
  return a tibble with columns `lon`, `lat`, and `depth`; use `"bathy"`
  to return a historical matrix of class `bathy`.

## Value

A tibble by default, or an object of class `bathy` when
`class = "bathy"`.

## Details

ETOPO 2022 is exposed by NOAA ERDDAP at a native resolution of 15
arc-seconds, i.e. 0.25 arc-minutes. The `resolution` argument is
converted to an ERDDAP stride using:


    stride = round(resolution / 0.25)

The effective downloaded resolution is therefore `stride * 0.25`
arc-minutes. This is server-side sub-sampling, not local aggregation:
ERDDAP returns one native cell every `stride` cells. For local
aggregation by mean or median, download at the native resolution and use
[`reduce_bathy_resolution`](https://besibo.github.io/marmap2/reference/reduce_bathy_resolution.md)
afterwards.

This function is intentionally separate from
[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md)
while the ERDDAP workflow is being evaluated.

## See also

[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md),
[`reduce_bathy_resolution`](https://besibo.github.io/marmap2/reference/reduce_bathy_resolution.md),
[`read_bathy`](https://besibo.github.io/marmap2/reference/read_bathy.md),
[`geom_bathy`](https://besibo.github.io/marmap2/reference/geom_bathy.md)

## Examples

``` r
if (FALSE) { # \dontrun{
dat <- get_noaa_erddap(
  lon = c(-5, 5),
  lat = c(40, 45),
  resolution = 1
)
} # }
```
