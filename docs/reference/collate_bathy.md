# Collates two bathy matrices with data from either sides of the antimeridian

Collates two bathy matrices, one with longitude 0 to 180 degrees East,
and the other with longitude 0 to 180 degrees West

## Usage

``` r
collate_bathy(east,west)
```

## Arguments

  - east:
    
    matrix of class `bathy` with eastern data (West of antimeridian)

  - west:
    
    matrix of class `bathy` with western data (East of antimeridian)

## Value

A single matrix of class `bathy` that can be interpreted by
`plot_bathy`. When plotting collated data (with longitudes 0 to 180 and
180 to 360 degrees), plots can be modified to display the conventional
coordinate system (with longitudes 0 to 180 and -180 to 0 degrees) using
function `antimeridian_box()`.

## Details

This function is meant to be used with `read_bathy()` or
`read_gebco_bathy()`, when data is downloaded from either sides of the
antimeridian line (180 degrees longitude). If, for example, data is
downloaded from GEBCO for longitudes of 170E-180 and 180-170W,
`collate_bathy()` will create a single matrix of class `bathy` with a
coordinate system going from 170 to 190 degrees longitude.

`get_noaa()` deals with data from both sides of the antimeridian and
does not need further processing with `collate_bathy()`.

## See also

`get_noaa`, `summary_bathy`, `plot_bathy`, `antimeridian_box`

## Author

Eric Pante

## Examples

``` r
## faking two datasets using aleutians, for this example
## "a" and "b" simulate two datasets downloaded from GEBCO, for ex.
  data(aleutians)
  aleutians[1:181,] -> a ; "bathy" -> class(a)
  aleutians[182:601,] -> b ; "bathy" -> class(b)
  -(360-as.numeric(rownames(b))) -> rownames(b)

## check these objects with summary(): pay attention of the Longitudinal range
  summary(aleutians)
  summary(a)
  summary(b)

## merge datasets:
  collate_bathy(a,b) -> collated
  summary(collated) # should be identical to summary(aleutians)
```
