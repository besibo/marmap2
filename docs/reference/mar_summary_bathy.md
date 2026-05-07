# Summary of bathymetric data of class `bathy`

Summary of bathymetric data of class `bathy`. Provides geographic bounds
and resolution (in minutes) of the dataset, statistics on depth data,
and a preview of the bathymetric matrix.

## Usage

``` r
# S3 method for class 'bathy'
summary(object, ...)

mar_summary_bathy(object, ...)
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

`mar_read_bathy`, `mar_plot_bathy`

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
# load NW Atlantic data
data(nw.atlantic)

# use mar_as_bathy
atl <- mar_as_bathy(nw.atlantic)

# class bathy
class(atl)

# summarize data of class bathy
summary(atl)
```
