# Test whether an object is of class bathy

Test whether an object is of class bathy

## Usage

``` r
is_bathy(xyz)
```

## Arguments

  - xyz:
    
    three-column data.frame with longitude (x), latitude (y) and depth
    (z) (no default)

## Value

The function returns `TRUE` or `FALSE`

## See also

`as_bathy`, `summary_bathy`, `read_bathy`

## Author

Eric Pante

## Examples

``` r
# load NW Atlantic data
data(nw.atlantic)

# test class "bathy"
is_bathy(nw.atlantic)

# use as_bathy
atl <- as_bathy(nw.atlantic)

# class "bathy"
class(atl)
is_bathy(atl)

# summarize data of class "bathy"
summary(atl)
```
