# Sort bathymetric data matrix by increasing latitude and longitude

Reads a bathymetric data matrix and orders its rows and columns by
increasing latitude and longitude.

## Usage

``` r
check_bathy(x)
```

## Arguments

  - x:
    
    a matrix

## Value

The output of `check_bathy` is an ordered matrix.

## Details

`check_bathy` allows to sort rows and columns by increasing latitude and
longitude, which is necessary for ploting with the function `image`
(package `graphics`). `check_bathy` is used within the `marmap`
functions `read_bathy` and `as_bathy` (it is also used in `get_noaa`
through `as_bathy`).

## See also

`read_bathy`, `as_bathy`, `get_noaa`

## Author

Eric Pante

## Examples

``` r
matrix(1:100, ncol=5, dimnames=list(20:1, c(3,2,4,1,5))) -> a
check_bathy(a)
```
