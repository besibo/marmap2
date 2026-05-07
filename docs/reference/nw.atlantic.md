# Bathymetric data for the North West Atlantic

Data imported from the NOAA GEODAS server

## Usage

``` r
data(nw.atlantic)
```

## Value

A three-columns data.frame containing longitude, latitude and
depth/elevation data.

## Details

Data imported from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>). To prepare data from
NOAA, fill the custom grid form, and choose "XYZ (lon,lat,depth)" as the
"Output Grid Format", "No Header" as the "Output Grid Header", and
either of the space, tab or comma as the column delimiter (either can be
used, but "comma" is the default import format of `read_bathy`). Choose
"omit empty grid cells" to reduce memory usage.

## See also

`plot_bathy`, `summary_bathy`

## Author

see <https://www.ncei.noaa.gov/maps/grid-extract/>

## Examples

``` r
# load NW Atlantic data
data(nw.atlantic)

# use as_bathy
atl <- as_bathy(nw.atlantic)

# class "bathy"
class(atl)
summary(atl)

# test plot_bathy
plot(atl, deep=-8000, shallow=-1000, step=1000)
```
