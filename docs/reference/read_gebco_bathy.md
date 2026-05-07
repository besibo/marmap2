# Read bathymetric data from a GEBCO file

Imports 30-sec and 1-min bathymetric data from a .nc file downloaded on
the GEBCO website.

## Usage

``` r
read_gebco_bathy(file, resolution = 1, sid = FALSE)
```

## Arguments

  - file:
    
    name of the `.nc` file

  - resolution:
    
    resolution of the grid, in units of the selected database (default
    is 1; see details)

  - sid:
    
    logical. Is the data file containing SID information?

## Value

The output of `read_gebco_bathy` is a matrix of class `bathy`, which
dimensions depends on the resolution specified (one-minute, the original
GEBCO resolution, is the default). The class `bathy` has its own methods
for summarizing and ploting the data.

## Details

`read_gebco_bathy` reads a 30 arcseconds or 1 arcminute bathymetry file
downloaded from the GEBCO (General Bathymetric Chart of the Oceans)
website (British Oceanographic Data Center). The website allows the
download of bathymetric data in the netCDF format. `read_gebco_bathy`
uses the `ncdf4` package to load the data into R, and parses it into an
object of class `bathy`.

Data can be downloaded from the 30 arcseconds database (GEBCO\_08) or
the 1 arcminute database (GEBCO\_1min, the default). A third database
type, GEBCO\_08 SID, is available from the website. This database
includes a source identifier specifying which grid cells have depth
information based on soundings ; it does not include bathymetry or
topography data. `read_gebco_bathy` can read this type of database when
`sid` is set to `TRUE`. Then only the SID information will be included
in the object of class `bathy`. Therefore, to display a map with both
the bathymetry and the SID information, you will have to download both
datasets from GEBCO, and import and plot both independently.

The argument `resolution` specifies the resolution of the object of
class `bathy`. Because the resolution of GEBCO data is rather fine, we
offer the possibility of downsizing the dataset with `resolution`.
`resolution` is in units of the selected database: in "GEBCO\_1min",
`resolution` is in minutes; in "GEBCO\_08", `resolution` is in 30
arcseconds (that is, `resolution = 3` corresponds to 3x30sec, or 1.5
arcminute).

## References

British Oceanographic Data Center: General Bathymetric Chart of the
Oceans gridded bathymetric data sets (accessed July 10, 2020)
<https://www.bodc.ac.uk/data/hosted_data_systems/gebco_gridded_bathymetry_data/>

General Bathymetric Chart of the Oceans website (accessed Oct 5, 2013)
<https://www.gebco.net>

David Pierce (2019). ncdf4: Interface to Unidata netCDF (Version 4 or
Earlier) Format Data Files. R package version 1.17.
https://cran.r-project.org/package=ncdf4

## See also

`get_noaa`, `read_bathy`, `plot_bathy`

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
if (FALSE) { # \dontrun{
# This example will not run, and we do not provide the dummy "gebco_file.nc" file,
# because a copyright license must be signed on the GEBCO website before the data can be
# downloaded and used. We just provide this line as an example for synthax.
  read_gebco_bathy(file="gebco_file.nc", resolution=1) -> nw.atl

# Second not-run example, with GEBCO_08 and SID:
  read_gebco_bathy("gebco_08_7_38_10_43_corsica.nc") -> med
  summary(med) # the bathymetry data

  read_gebco_bathy("gebco_SID_7_38_10_43_corsica.nc")-> sid
  summary(sid) # the SID data

  colorRampPalette(c("lightblue","cadetblue1","white")) -> blues # custom col palette
  plot(med, n=1, im=T, bpal=blues(100)) # bathymetry

  as.numeric(rownames(sid)) -> x.sid
  as.numeric(colnames(sid)) -> y.sid
  contour(x.sid, y.sid, sid, drawlabels=FALSE, lwd=.1, add=TRUE) # SID
} # }
```
