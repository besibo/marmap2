# Download bathymetry from the GEBCO download service

Downloads a user-defined geographic subset from the official GEBCO
download service and returns it as an object of class `bathy`.

## Usage

``` r
get_gebco(
  lon1,
  lon2,
  lat1,
  lat2,
  resolution = 1,
  keep = FALSE,
  path = NULL,
  base_url = "https://download.gebco.net",
  grid_id = 1,
  data_source_id = 1,
  format_id = 1,
  poll_interval = 2,
  timeout = 300,
  quiet = FALSE
)
```

## Arguments

  - lon1:
    
    Western or first longitude bound in decimal degrees.

  - lon2:
    
    Eastern or second longitude bound in decimal degrees.

  - lat1:
    
    Southern or first latitude bound in decimal degrees.

  - lat2:
    
    Northern or second latitude bound in decimal degrees.

  - resolution:
    
    Output grid spacing in arc-minutes. Defaults to `1`. The GEBCO
    global NetCDF subset is downloaded at its native 15 arc-second
    resolution, then thinned locally when `resolution > 0.25`. Values
    lower than `0.25` return the native GEBCO global grid resolution.

  - keep:
    
    Logical. If `TRUE`, the xyz table returned as a `bathy` object is
    also written as a csv file in `path`.

  - path:
    
    Directory used for cached csv files when `keep = TRUE`, and where
    `get_gebco` looks for an already downloaded matching csv file.
    Defaults to the current working directory.

  - base\_url:
    
    Base URL of the official GEBCO download service.

  - grid\_id:
    
    Numeric GEBCO grid identifier used by the download service. The
    default, `1`, corresponds to the first grid returned by
    `/api/grids`; at the time this function was written, this was the
    latest global GEBCO grid.

  - data\_source\_id:
    
    Numeric GEBCO data-source identifier. The default, `1`, corresponds
    to the first bathymetry layer returned by `/api/grids`; at the time
    this function was written, this was bathymetry from the latest
    global GEBCO grid.

  - format\_id:
    
    Numeric GEBCO output-format identifier. The default, `1`,
    corresponds to NetCDF.

  - poll\_interval:
    
    Number of seconds between two status checks.

  - timeout:
    
    Maximum number of seconds to wait for the GEBCO basket to be
    processed.

  - quiet:
    
    Logical. If `FALSE`, progress messages are displayed.

## Value

An object of class `bathy`. If `keep = TRUE`, a csv copy of the
downloaded xyz table is written to `path`.

## Details

`get_gebco` uses the workflow implemented by the official GEBCO Grid
Subsetting App at <https://download.gebco.net/>. The function submits a
small JSON basket to `/api/queue`, polls `/api/queue/status/{basketId}`
until the basket is ready, downloads the resulting zip archive from
`/api/queue/download/{basketId}`, extracts the NetCDF file, reads the
`lat`, `lon`, and `elevation` variables, and converts them to a `bathy`
object.

The current global GEBCO grids are served by the GEBCO download service
at their native resolution of 15 arc-seconds, i.e. 0.25 arc-minutes or
0.0041667 decimal degrees. This corresponds to approximately 463 m at
the equator. The `resolution` argument is expressed in arc-minutes for
consistency with `get_noaa`, but it is not sent to the GEBCO API: the
NetCDF file is downloaded at native resolution, then thinned locally if
`resolution` is larger than 0.25. Values smaller than 0.25 therefore do
not increase the spatial resolution and return the native grid.

GEBCO also exposes some higher-resolution regional or experimental
products through the same download service, for example polar grids or
beta multi-resolution layers. Those products are selected with `grid_id`
and `data_source_id`; their native resolution and coordinate reference
system may differ from the global longitude/latitude grid. This function
is currently designed for global longitude/latitude bathymetry layers
whose NetCDF variables are named `lon`, `lat`, and `elevation`.

The GEBCO download service expects `left <= right`; areas crossing the
antimeridian are therefore not handled by this importer. Split such
requests into two calls, one on each side of the antimeridian.

## References

GEBCO Compilation Group. GEBCO Grid, a continuous terrain model for
oceans and land at 15 arc-second intervals. <https://www.gebco.net/>

## See also

`get_noaa`, `read_gebco_bathy`, `read_bathy`, `as_bathy`

## Examples

``` r
if (FALSE) { # \dontrun{
# Download a one-degree subset from the official GEBCO service
b <- get_gebco(
  lon1 = -6, lon2 = -5,
  lat1 = 49, lat2 = 50,
  resolution = 1
)

plot(b, image = TRUE, land = TRUE)
} # }
```
