# Bathymetric data for the Aleutians (Alaska)

Bathymetric matrix of class `bathy` created from NOAA GEODAS data.

## Usage

``` r
data(aleutians)
```

## Value

A text file.

## Details

Data imported from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>) and transformed into an
object of class `bathy` by `mar_as_bathy`.

## See also

`mar_as_bathy`, `mar_read_bathy`, `mar_antimeridian_box`

## Author

see <https://www.ncei.noaa.gov/maps/grid-extract/>

## Examples

``` r
# load celt data
data(aleutians)

# class "bathy"
class(aleutians)
summary(aleutians)

# test mar_plot_bathy
plot(aleutians,image = TRUE,
     bpal = list(c(0,max(aleutians),"grey"),
                 c(min(aleutians),0,"darkblue","lightblue")),
     land = TRUE, lwd = 0.1, axes = FALSE)
mar_antimeridian_box(aleutians, 10)
```
