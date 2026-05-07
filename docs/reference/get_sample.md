# Get sample data by clicking on a map

Outputs sample information based on points selected by clicking on a map

## Usage

``` r
get_sample(mat, sample, col.lon, col.lat, ...)
```

## Arguments

  - mat:
    
    bathymetric data matrix of class `bathy`, imported using
    `read_bathy` (no default)

  - sample:
    
    data.frame containing sampling information (at least longitude and
    latitude) (no default)

  - col.lon:
    
    column number of data frame `sample` containing longitude
    information (no default)

  - col.lat:
    
    column number of data frame `sample` containing latitude information
    (no default)

  - ...:
    
    further arguments to be passed to `rect` for drawing a box around
    the selected area

## Value

a dataframe of the elements of `sample` present within the area selected

## Details

`get_sample` allows the user to get sample data by clicking on a map
created with `plot_bathy`. This function uses the `locator` function
(`graphics` package). After creating a map with `plot_bathy`, the user
can click twice on the map to delimit an area (for example, lower left
and upper right corners of a rectangular area of interest), and get a
dataframe corresponding to the `sample` points present within the
selected area.

## See also

`read_bathy`, `summary_bathy`, `nw.atlantic`, `metallo`

## Author

Eric Pante

## Examples

``` r
if (FALSE) { # \dontrun{
# load metallo sampling data and add a third field containing a specimen ID
data(metallo)
metallo$id <- factor(paste("Metallo",1:38))

# load NW Atlantic data, convert to class bathy, and plot
data(nw.atlantic)
atl <- as_bathy(nw.atlantic)
plot(atl, deep=-8000, shallow=0, step=1000, col="grey")

# once the map is plotted, use get_sample to get sampling info!
get_sample(atl, metallo, 1, 2)
# click twice
} # }
```
