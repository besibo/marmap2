# Test whether an object is of class bathy

Test whether an object is of class bathy

## Usage

``` r
mar_is_bathy(xyz)

is.bathy(xyz)
```

## Arguments

  - xyz:
    
    three-column data.frame with longitude (x), latitude (y) and depth
    (z) (no default)

## Value

The function returns `TRUE` or `FALSE`

## See also

`mar_as_bathy`, `mar_summary_bathy`, `mar_read_bathy`

## Author

Eric Pante

## Examples

``` r
# load NW Atlantic data
data(nw.atlantic)

# test class "bathy"
mar_is_bathy(nw.atlantic)

# use mar_as_bathy
atl <- mar_as_bathy(nw.atlantic)

# class "bathy"
class(atl)
mar_is_bathy(atl)

# summarize data of class "bathy"
summary(atl)
```
