# Sort bathymetric data matrix by increasing latitude and longitude

Reads a bathymetric data matrix and orders its rows and columns by
increasing latitude and longitude.

## Usage

``` r
mar_check_bathy(x)

check.bathy(x)
```

## Arguments

  - x:
    
    a matrix

## Value

The output of `mar_check_bathy` is an ordered matrix.

## Details

`mar_check_bathy` allows to sort rows and columns by increasing latitude
and longitude, which is necessary for ploting with the function `image`
(package `graphics`). `mar_check_bathy` is used within the `marmap`
functions `mar_read_bathy` and `mar_as_bathy` (it is also used in
`mar_get_noaa_bathy` through `mar_as_bathy`).

## See also

`mar_read_bathy`, `mar_as_bathy`, `mar_get_noaa_bathy`

## Author

Eric Pante

## Examples

``` r
matrix(1:100, ncol=5, dimnames=list(20:1, c(3,2,4,1,5))) -> a
mar_check_bathy(a)
```
