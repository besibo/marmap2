# Bathymetric data around Florida, USA

Bathymetric object of class `bathy` created from NOAA GEODAS data.

## Usage

``` r
data(florida)
```

## Value

A bathymetric object of class `bathy` with 539 rows and 659 columns.

## Details

Data imported from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>) and transformed into an
object of class `bathy` by `read_bathy`.

## See also

`plot_bathy`, `summary_bathy`

## Author

see <https://www.ncei.noaa.gov/maps/grid-extract/>

## Examples

``` r
# load florida data
data(florida)

# class "bathy"
class(florida)
summary(florida)

# test plot_bathy
plot(florida,asp=1)
plot(florida,asp=1,image=TRUE,drawlabels=TRUE,land=TRUE,n=40)
```
