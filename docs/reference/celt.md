# Bathymetric data for the North Est Atlantic

Bathymetric matrix of class `bathy` created from NOAA GEODAS data.

## Usage

``` r
data(celt)
```

## Value

A text file.

## Details

Data imported from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>) and transformed into an
object of class `bathy` by `mar_as_bathy`.

## See also

`mar_as_bathy`, `mar_read_bathy`

## Author

see <https://www.ncei.noaa.gov/maps/grid-extract/>

## Examples

``` r
# load celt data
data(celt)

# class "bathy"
class(celt)
summary(celt)

# test mar_plot_bathy
plot(celt, deep=-300, shallow=-50, step=25)
```
