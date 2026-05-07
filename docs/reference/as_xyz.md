# Convert to xyz format

Converts a matrix of class `bathy` into a three-column data.frame
containing longitude, latitude and depth data.

## Usage

``` r
as_xyz(bathy)
```

## Arguments

  - bathy:
    
    matrix of class `bathy`.

## Value

Three-column data.frame with a format similar to xyz files downloaded
from the NOAA Grid Extract webpage
(<https://www.ncei.noaa.gov/maps/grid-extract/>). The first column
contains longitude data, the second contains latitude data and the third
contains depth/elevation data.

## Details

The use of `as_bathy` and `as_xyz` allows to swicth back and forth
between the long format (xyz) and the wide format of class `bathy`
suitable for plotting bathymetric maps, computing least cost distances,
etc. `as_xyz` is especially usefull for exporting xyz files when data
are obtained using `subset_sql`, i.e. bathymetric matrices of class
`bathy`.

## See also

`as_bathy`, `summary_bathy`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load celt data
data(celt)
dim(celt)
class(celt)
summary(celt)
plot(celt,deep= -300,shallow= -25,step=25)

# use as_xyz
celt2 <- as_xyz(celt)
dim(celt2)
class(celt2)
summary(celt2)
```
