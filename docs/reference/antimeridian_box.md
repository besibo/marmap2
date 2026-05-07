# Adds a box to maps including antimeridian

Adds a box on maps including the antimeridian (180)

## Usage

``` r
antimeridian_box(object, tick.spacing)
```

## Arguments

  - object:
    
    matrix of class bathy

  - tick.spacing:
    
    spacing between tick marks (in degrees, default=20)

## Value

The function adds a box and tick marks to an existing plot which
contains the antimeridian line (180 degrees).

## See also

`plot_bathy`

## Author

Eric Pante & Benoit Simon-Bouhet

## Examples

``` r
data(aleutians)

# default plot:
plot(aleutians,n=1)

# plot with corrected box and labels:
plot(aleutians,n=1,axes=FALSE)
antimeridian_box(aleutians, 10)
```
