# Read bathymetric data in XYZ format

Reads a three-column table containing longitude (x), latitude (y) and
depth (z) data.

## Usage

``` r
mar_read_bathy(xyz, header = FALSE, sep = ",", ...)

read.bathy(xyz, header = FALSE, sep = ",", ...)
```

## Arguments

  - xyz:
    
    three-column table with longitude (x), latitude (y) and depth (z)
    (no default)

  - header:
    
    whether this table has a row of column names (default = FALSE)

  - sep:
    
    character separating columns, (default=",")

  - ...:
    
    further arguments to be passed to `read.table()`

## Value

The output of `mar_read_bathy` is a matrix of class `bathy`, which
dimensions depends on the resolution of the grid uploaded from the NOAA
GEODAS server (Grid Cell Size). The class `bathy` has its own methods
for summarizing and ploting the data.

## See also

`mar_summary_bathy`, `mar_plot_bathy`, `mar_read_gebco_bathy`

## Author

Eric Pante

## Examples

``` r
# load NW Atlantic data
data(nw.atlantic)

# write example file to disk
write.table(nw.atlantic, "NW_Atlantic.csv", sep=",", quote=FALSE, row.names=FALSE)

# use mar_read_bathy
mar_read_bathy("NW_Atlantic.csv", header=TRUE) -> atl

# remove temporary file
system("rm NW_Atlantic.csv") # remove file, for unix-like systems

# class "bathy"
class(atl)

# summarize data of class "bathy"
summary(atl)
```
