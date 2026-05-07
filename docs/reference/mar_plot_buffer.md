# Plots a circular buffer and or its outline

`mar_plot_buffer` is a generic function that allows the plotting of
objects of class `buffer`, either as new plots or as a new layer added
on top of an existing one. The plotting of both the
bathymetry/hypsometry as well as the outline of the buffer is possible.

## Usage

``` r
# S3 method for class 'buffer'
plot(x, outline = TRUE, add = TRUE, ...)

mar_plot_buffer(x, outline = TRUE, add = TRUE, ...)
```

## Arguments

  - x:
    
    an object of class `buffer` as produced by the `mar_create_buffer()`
    function.

  - outline:
    
    Should the outline of the buffer be plotted (default) or the
    bathymetric/hypsometric data within the buffer.

  - add:
    
    Should the plot be added on top of an existing
    bathymetric/hypsometric plot (default) or as a new plot

  - ...:
    
    Further arguments to be passed to the `symbols()` function from the
    `graphics` package when `outline = TRUE` (default) or to
    `mar_plot_bathy()` when `outline = FALSE`.

## Value

Either a plot of the outline of a buffer (default) or a bathymetric map
with isobaths of a buffer when `outline = FALSE`

## See also

`mar_create_buffer`, `mar_combine_buffers`, `mar_plot_bathy`

## Author

Benoit Simon-Bouhet

## Examples

``` r
# load and plot a bathymetry
data(florida)
plot(florida, lwd = 0.2)
plot(florida, n = 0, lwd = 0.7, add = TRUE)

# add points around which a buffer will be computed
loc <- data.frame(-80, 26)
points(loc, pch = 19, col = "red")

# compute buffer
buf <- mar_create_buffer(florida, loc, radius=1.5)

# plot buffer bathymetry
plot(buf, outline=FALSE, n=10, lwd=.5, col=2)

# add buffer outline
plot(buf, lwd=.7, fg=2)
```
