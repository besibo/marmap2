# Summary of bathymetric data of class `bathy`

Summary of bathymetric data of class `bathy`. Provides geographic bounds
and resolution (in minutes) of the dataset, statistics on depth data,
and a preview of the bathymetric matrix.

## Usage

``` r
summary_bathy(object, ...)
```

## Arguments

- object:

  object of class `bathy`

- ...:

  additional arguments affecting the summary produced (see `base`
  function `summary`).

## Value

Information on the geographic bounds of the dataset (minimum and maximum
latitude and longitude), resolution of the matrix in minutes, statistics
on the depth data (e.g. min, max, median...), and a preview of the data.

## See also

[`read_bathy`](https://besibo.github.io/marmap2/reference/read_bathy.md),
[`as_bathy`](https://besibo.github.io/marmap2/reference/as_bathy.md),
[`bathy_to_tbl`](https://besibo.github.io/marmap2/reference/bathy_to_tbl.md)

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
xyz <- data.frame(
  lon = rep(c(-5, -4, -3), each = 3),
  lat = rep(c(48, 49, 50), times = 3),
  depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
)

bathy <- as_bathy(xyz)
summary(bathy)
#> Bathymetric data of class 'bathy', with 3 rows and 3 columns
#> Latitudinal range: 48 to 50 (48 N to 50 N)
#> Longitudinal range: -5 to -3 (5 W to 3 W)
#> Cell size: 60 minute(s)
#> 
#> Depth statistics:
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    -160    -140    -110    -110     -80     -60 
#> 
#> First 5 columns and rows of the bathymetric matrix:
#>      48   49   50
#> -5  -80  -70  -60
#> -4 -120 -110 -100
#> -3 -160 -150 -140
```
