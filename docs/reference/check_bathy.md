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

[`read_bathy`](https://besibo.github.io/marmap2/reference/read_bathy.md),
[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`get_noaa`](https://besibo.github.io/marmap2/reference/get_noaa.md)

## Author

Eric Pante

## Examples

``` r
matrix(1:100, ncol=5, dimnames=list(20:1, c(3,2,4,1,5))) -> a
check_bathy(a)
#>     1  2  3  4   5
#> 1  80 40 20 60 100
#> 2  79 39 19 59  99
#> 3  78 38 18 58  98
#> 4  77 37 17 57  97
#> 5  76 36 16 56  96
#> 6  75 35 15 55  95
#> 7  74 34 14 54  94
#> 8  73 33 13 53  93
#> 9  72 32 12 52  92
#> 10 71 31 11 51  91
#> 11 70 30 10 50  90
#> 12 69 29  9 49  89
#> 13 68 28  8 48  88
#> 14 67 27  7 47  87
#> 15 66 26  6 46  86
#> 16 65 25  5 45  85
#> 17 64 24  4 44  84
#> 18 63 23  3 43  83
#> 19 62 22  2 42  82
#> 20 61 21  1 41  81
```
