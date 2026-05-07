# Finds matrix diagonal for non-square matrices

Finds either the values of the coordinates of the non-linear diagonal of
non-square matrices.

## Usage

``` r
diag_bathy(mat,coord=FALSE)
```

## Arguments

  - mat:
    
    a data matrix

  - coord:
    
    whether of not to output the coordinates of the diagonal (default is
    `FALSE`)

## Value

A vector of diagonal values is `coord` is `FALSE`, or a table of
diagonal coordinates if`coord` is `FALSE`

## Details

diag\_bathy gets the values or coordinates from the first element of a
matrix to its last elements. If the matrix is non-square, that is, its
number of rows and columns differ, diag\_bathy computes an approximate
diagonal.

## See also

`get_transect`, `diag`

## Author

Eric Pante

## Examples

``` r
# a square matrix: diag_bathy behaves as diag
  matrix(1:25, 5, 5) -> a ; a
  diag(a)
  diag_bathy(a)

# a non-square matrix: diag_bathy does not behaves as diag
  matrix(1:15, 3, 5) -> b ; b
  diag(b)
  diag_bathy(b)

# output the diagonal or its coordinates:
  rownames(b) <- seq(32,35, length.out=3)
  colnames(b) <- seq(-100,-95, length.out=5)
  diag_bathy(b, coord=FALSE)
  diag_bathy(b, coord=TRUE)
```
