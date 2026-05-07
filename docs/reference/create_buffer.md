# Create a buffer of specified radius around one or several points

Create a circular buffer of user-defined radius around one or several
points defined by their longitudes and latitudes.

## Usage

``` r
create_buffer(x, loc, radius, km = FALSE)

print_buffer(x, ...)
```

## Arguments

  - x:
    
    an object of class `bathy`

  - loc:
    
    a 2-column `data.frame` of longitudes and latitudes for points
    around which the buffer is to be created.

  - radius:
    
    `numeric`. Radius of the buffer in the same unit as the `bathy`
    object (i.e. usually decimal degrees) when `km=FALSE` (default) or
    in kilometers when `radius=TRUE`.

  - km:
    
    `logical`. If `TRUE`, the `radius` should be provided in kilometers.
    When `FALSE` (default) the radius is in the same unit as the `bathy`
    object (i.e. usually decimal degrees).

## Value

An object of class `bathy` of the same size as `mat` containing only
`NA`s outside of the buffer and values of depth/altitude (taken from
`mat`) within the buffer.

## Details

This function takes advantage of the `buffer` function from package
`adehabitatMA` and several functions from packages `sp` to define the
buffer around the points provided by the user.

## See also

`outline_buffer`, `combine_buffers`, `plot_bathy`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load and plot a bathymetry
data(florida)
plot(florida, lwd = 0.2)
plot(florida, n = 1, lwd = 0.7, add = TRUE)

# add a point around which a buffer will be created
loc <- data.frame(-80, 26)
points(loc, pch = 19, col = "red")

# compute and print buffer
buf <- create_buffer(florida, loc, radius=1.5)
buf

# highlight isobath with the buffer and add outline
plot(buf, outline=FALSE, n = 10, col = 2, lwd=.4)
plot(buf, lwd = 0.7, fg = 2)
```
