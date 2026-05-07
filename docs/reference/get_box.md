# Get bathymetric information of a belt transect

`get_box` gets depth information of a belt transect of width `width`
around a transect defined by two points on a bathymetric map.

## Usage

``` r
get_box(bathy,x1,x2,y1,y2,width,locator=FALSE,ratio=FALSE, ...)
```

## Arguments

  - bathy:
    
    Bathymetric data matrix of class `bathy`.

  - x1:
    
    Numeric. Start longitude of the transect. Requested when
    `locator=FALSE`.

  - x2:
    
    Numeric. Stop longitude of the transect. Requested when
    `locator=FALSE`.

  - y1:
    
    Numeric. Start latitude of the transect. Requested when
    `locator=FALSE`.

  - y2:
    
    Numeric. Stop latitude of the transect. Requested when
    `locator=FALSE`.

  - width:
    
    Numeric. Width of the belt transect in degrees.

  - locator:
    
    Logical. Whether to choose transect bounds interactively with a map
    or not. When `FALSE` (default), a bathymetric map
    (`plot_bathy(bathy,image=TRUE)`) is automatically plotted and the
    position of the belt transect is added.

  - ratio:
    
    Logical. Should aspect ratio for the `wireframe` plotting function
    (package `lattice`) be computed (default is `FALSE`).

  - ...:
    
    Other arguments to be passed to `locator` and `lines` to specify the
    characteristics of the points and lines to draw on the bathymetric
    map for both the transect and the bounding box of belt transect.

## Value

A matrix containing depth values for the belt transect. `rownames`
indicate the kilometric distance from the start of the transect and
`colnames` indicate the distance form the central transect in degrees.
If `ratio=TRUE`, a list of two elements: `depth`, a matrix containing
depth values for the belt transect similar to the description above and
`ratios` a vector of length two specifying the ratio between (i) the
width and length of the belt transect and (ii) the depth range and the
length of the belt transect. These ratios can be used by the function
`wireframe` to produce realistic 3D bathymetric plots of the selected
belt transect.

## Details

`get_box` allows the user to get depth data for a rectangle area of the
map around an approximate linear transect (belt transect). Both the
position and size of the belt transect are user defined. The position of
the transect can be specified either by inputing start and stop
coordinates, or by clicking on a map created with `plot_bathy`. In its
interactive mode, this function uses the `locator` function (`graphics`
package) to retrieve and plot the coordinates of the selected transect.
The argument `width` allows the user to specify the width of the belt
transect in degrees.

## See also

`plot_bathy`, `get_transect`, `get_depth`

## Author

Benoit Simon-Bouhet and Eric Pante

## Examples

``` r
# load and plot bathymetry
  data(hawaii)
  plot(hawaii,im=TRUE)

# get the depth matrix for a belt transect
  depth <- get_box(hawaii,x1=-157,y1=20,x2=-155.5,y2=21,width=0.5,col=2)

# plotting a 3D bathymetric map of the belt transect
  require(lattice)
  wireframe(depth,shade=TRUE)

# get the depth matrix for a belt transect with realistic aspect ratios
  depth <- get_box(hawaii,x1=-157,y1=20,x2=-155.5,y2=21,width=0.5,col=2,ratio=TRUE)

# plotting a 3D bathymetric map of the belt transect with realistic aspect ratios
  require(lattice)
  wireframe(depth[[1]],shade=TRUE,aspect=depth[[2]])
```
