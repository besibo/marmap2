# Builds a bathymetry- and/or topography-constrained color palette

Builds a constrained color palette based on depth / altitude bounds and
given colors.

## Usage

``` r
palette_bathy(mat, layers, land=FALSE, default.col="white")
```

## Arguments

  - mat:
    
    a matrix of bathymetric data, class bathy not required.

  - layers:
    
    a list of depth bounds and colors (see below)

  - land:
    
    logical. Wether to consider land or not (`default` is `FALSE`)

  - default.col:
    
    a color for the area of the matrix not bracketed by the list
    supplied to `layers`

## Value

A vector of colors which size depends on the depth / altitude range of
the `bathy` matrix.

## Details

`palette_bathy` allows the production of color palettes for specified
bathymetric and/or topographic layers. The `layers` argument must be a
list of vectors. Each vector corresponds to a bathymetry/topography
layer (for example, one layer for bathymetry and one layer for
topography). The first and second elements of the vector are the minimum
and maximum bathymetry/topography, respectively. The other elements of
the vector (3, onward) correspond to colors (see example below).
`palette_bathy` is called internally by `plot_bathy` when the `image`
argument is set to `TRUE`.

## See also

`plot_bathy`

## Author

Eric Pante and Benoit Simon-Bouhet

## Examples

``` r
# load NW Atlantic data and convert to class bathy
  data(nw.atlantic)
  atl <- as_bathy(nw.atlantic)

# creating depth-constrained palette for the ocean only
    newcol <- palette_bathy(mat=atl,
    layers = list(c(min(atl), 0, "purple", "blue", "lightblue")),
    land = FALSE, default.col = "grey" )
  plot(atl, land = FALSE, n = 10, lwd = 0.5, image = TRUE,
    bpal = newcol, default.col = "grey")

# same:
  plot(atl, land = FALSE, n = 10, lwd = 0.5, image = TRUE,
    bpal = list(c(min(atl), 0, "purple", "blue", "lightblue")),
    default.col = "gray")

# creating depth-constrained palette for 3 ocean "layers"
  newcol <- palette_bathy(mat = atl, layers = list(
    c(min(atl), -3000, "purple", "blue", "grey"),
    c(-3000, -150, "white"),
    c(-150, 0, "yellow", "green", "brown")),
    land = FALSE, default.col = "grey")
  plot(atl, land = FALSE, n = 10, lwd = 0.7, image = TRUE,
    bpal = newcol, default.col = "grey")

# same
  plot(atl, land = FALSE, n = 10, lwd = 0.7, image = TRUE,
    bpal = list(c(min(atl), -3000, "purple","blue","grey"),
          c(-3000, -150, "white"),
          c(-150, 0, "yellow", "green", "brown")),
    default.col = "grey")

# creating depth-constrained palette for land and ocean
  newcol <- palette_bathy(mat= atl, layers = list(
    c(min(atl),0,"purple","blue","lightblue"),
    c(0, max(atl), "gray90", "gray10")),
    land = TRUE)
  plot(atl, land = TRUE, n = 10, lwd = 0.5, image = TRUE, bpal = newcol)

# same
  plot(atl, land = TRUE, n = 10, lwd = 0.7, image = TRUE,
    bpal = list(
      c(min(atl), 0, "purple", "blue", "lightblue"),
      c(0, max(atl), "gray90", "gray10")))
```
