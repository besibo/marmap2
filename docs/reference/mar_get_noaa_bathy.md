# Import bathymetric data from the NOAA server

Imports bathymetric data from the NOAA server, given coordinate bounds
and resolution.

## Usage

``` r
mar_get_noaa_bathy(lon1, lon2, lat1, lat2, resolution = 4,
              keep = FALSE, antimeridian = FALSE, path = NULL)

getNOAA.bathy(
  lon1,
  lon2,
  lat1,
  lat2,
  resolution = 4,
  keep = FALSE,
  antimeridian = FALSE,
  path = NULL
)
```

## Arguments

  - lon1:
    
    first longitude of the area for which bathymetric data will be
    downloaded

  - lon2:
    
    second longitude of the area for which bathymetric data will be
    downloaded

  - lat1:
    
    first latitude of the area for which bathymetric data will be
    downloaded

  - lat2:
    
    second latitude of the area for which bathymetric data will be
    downloaded

  - resolution:
    
    resolution of the grid, in minutes (default is 4)

  - keep:
    
    whether to write the data downloaded from NOAA into a file (default
    is FALSE)

  - antimeridian:
    
    whether the area should include the antimeridian (longitude 180 or
    -180). See details.

  - path:
    
    Where should bathymetric data be downloaded to if `keep = TRUE`?
    Where should `mar_get_noaa_bathy()` look up for bathymetric data
    already downloaded? Defaults to the current working directory.

## Value

The output of `mar_get_noaa_bathy` is a matrix of class `bathy`, which
dimensions depends on the resolution of the grid uploaded from the NOAA
server. The class `bathy` has its own methods for summarizing and
plotting the data. If `keep=TRUE`, a csv file containing the downloaded
data is produced. This file is named using the following format:
'marmap\_coord\_COORDINATES\_res\_RESOLUTION.csv' (COORDINATES separated
by semicolons, and the RESOLUTION in degrees).

## Details

`mar_get_noaa_bathy` queries the ETOPO 2022 database hosted on the NOAA
website, given the coordinates of the area of interest and desired
resolution. Users have the option of directly writing the downloaded
data into a file (`keep = TRUE` argument ; see below). If an identical
query is performed (i.e. using identical lat-long and resolution),
`mar_get_noaa_bathy` will load data from the file previously written to
the disk instead of querying the NOAA database. This behavior should be
used preferentially (1) to reduce the number of uncessary queries to the
NOAA website, and (2) to reduce data load time. If the user wants to
make multiple, identical queries to the NOAA website without loading the
data written to disk, the data file name must be modified by the user.
Alternatively, the data file can be moved outside of the present working
directory.

`mar_get_noaa_bathy` allows users to download bathymetric data in the
antimeridian region when `antimeridian=TRUE`. The antimeridian is the
180th meridian and is located about in the middle of the Pacific Ocean,
east of New Zealand and Fidji, west of Hawaii and Tonga. For a given
pair of longitude values, e.g. -150 (150 degrees West) and 150 (degrees
East), you have the possibility to get data for 2 distinct regions: the
area centered on the antimeridian (60 degrees wide, when `antimeridian =
TRUE`) or the area centered on the prime meridian (300 degrees wide,
when `antimeridian = FALSE`). It is recommended to use `keep = TRUE` in
combination with `antimeridian = TRUE` since gathering data for an area
around the antimeridian requires two distinct queries to NOAA servers.

## References

NOAA National Centers for Environmental Information. 2022: ETOPO 2022 15
Arc-Second Global Relief Model. NOAA National Centers for Environmental
Information.
[doi:10.25921/fd45-gt74](https://doi.org/10.25921/fd45-gt74)

## See also

`mar_read_bathy`, `mar_read_gebco_bathy`, `mar_plot_bathy`

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
if (FALSE) { # \dontrun{
# you must have an internet connection. This line queries the NOAA ETOPO 2022 database
# for data from North Atlantic, for a resolution of 10 minutes.

mar_get_noaa_bathy(lon1=-20,lon2=-90,lat1=50,lat2=20, resolution=10) -> a
plot(a, image=TRUE, deep=-6000, shallow=0, step=1000)

# download speed for a matrix of 10 degrees x 10 degrees x 30 minutes
system.time(mar_get_noaa_bathy(lon1=0,lon2=10,lat1=0,lat2=10, resolution=30))
} # }
```
