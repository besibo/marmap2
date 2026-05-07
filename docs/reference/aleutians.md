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
object of class `bathy` by `as_bathy`.

## See also

`as_bathy`, `read_bathy`, `antimeridian_box`

## Author

see <https://www.ncei.noaa.gov/maps/grid-extract/>

## Examples

``` r
# load celt data
data(aleutians)

# class "bathy"
class(aleutians)
summary(aleutians)

# test plot_bathy
plot(aleutians,image = TRUE,
     bpal = list(c(0,max(aleutians),"grey"),
                 c(min(aleutians),0,"darkblue","lightblue")),
     land = TRUE, lwd = 0.1, axes = FALSE)
antimeridian_box(aleutians, 10)
```
