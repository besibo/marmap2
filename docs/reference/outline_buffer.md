# Get a composite buffer in a format suitable for plotting its outline

Get a buffer (i.e. a non-circular buffer as produced by
`combine_buffers()`) in a format suitable for plotting its outline.
`outline_buffer()` replaces any `NA` values in a `buffer` or `bathy`
object by 0 and non-`NA` values by -1.

## Usage

``` r
outline_buffer(buffer)
```

## Arguments

  - buffer:
    
    a buffer object of class `bathy` (i.e. `bathy` matrix containing
    depth/altitude values within the buffer and `NA`s outside)

## Value

An object of class `bathy` of the same dimensions as `buffer` containing
only zeros (outside the buffer area) and -1 values (within the buffer).

## Details

This function is essentially used to prepare a composite buffer for
plotting its outline on a bathymetric map. Plotting a single circular
buffer should be done using the `plot_buffer()` function since it offers
a more straightforward method for plotting and much smoother outlines,
especially for low-resolution bathymetries.

## See also

`create_buffer`, `combine_buffers`, `plot_bathy`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load and plot a bathymetry
data(florida)
plot(florida, lwd = 0.2)
plot(florida, n = 1, lwd = 0.7, add = TRUE)

# add points around which a buffer will be computed
loc <- data.frame(c(-80,-82), c(26,24))
points(loc, pch = 19, col = "red")

# create 2 distinct buffer objects with different radii
buf1 <- create_buffer(florida, loc[1,], radius=1.9)
buf2 <- create_buffer(florida, loc[2,], radius=1.2)

# combine both buffers
buf <- combine_buffers(buf1,buf2)

if (FALSE) { # \dontrun{
# Add outline of the resulting buffer in red
# and the outline of the original buffers in blue
plot(outline_buffer(buf), lwd = 3, col = 2, add=TRUE)
plot(buf1, lwd = 0.5, fg="blue")
plot(buf2, lwd = 0.5, fg="blue")
} # }
```
