# Computes least cost distances between two or more locations

Computes least cost distances between two or more locations

## Usage

``` r
least_cost_distance2(
  trans,
  loc,
  res = c("dist", "path"),
  unit = "meter",
  speed = 8,
  round = 0
)
```

## Arguments

  - trans:
    
    transition object as computed by `transition_matrix`

  - loc:
    
    A two-columns matrix or data.frame containing latitude and longitude
    for 2 or more locations.

  - res:
    
    either `"dist"` or `"path"`. See details.

  - unit:
    
    Character. The unit in which the results should be provided.
    Possible values are: `"meter"` (default), `"km"` (kilometers),
    `"miles"`, `"nmiles"` (nautic miles), `"hours"` or `"hours.min"`
    (hours and minutes).

  - speed:
    
    Speed in knots (nautic miles per hour). Used only to compute
    distances when `unit = "hours"` or `unit = "hours.min"`

  - round:
    
    integer indicating the number of decimal places to be used for
    printing results when `res = "dist"`.

## Value

Results can be presented either as a kilometric distance matrix between
all possible pairs of locations (argument `res="dist"`) or as a list of
paths (i.e. 2-columns matrices of routes) between pairs of locations
(`res="path"`).

## Details

`least_cost_distance2` computes least cost distances between 2 or more
locations. This function relies on the package `gdistance` (van Etten,
2011. <https://CRAN.R-project.org/package=gdistance>) and on the
`transition_matrix` function to define a range of depths where the paths
are possible.

## References

Jacob van Etten (2011). gdistance: distances and routes on geographical
grids. R package version 1.1-2.
<https://CRAN.R-project.org/package=gdistance>

## See also

`transition_matrix`, `least_cost_distance`

## Author

Benoit Simon-Bouhet and Eric Pante

## Examples

``` r
# Load and plot bathymetry
  data(hawaii)
  pal <- colorRampPalette(c("black","darkblue","blue","lightblue"))
  plot(hawaii,image=TRUE,bpal=pal(100),asp=1,col="grey40",lwd=.7,
       main="Bathymetric map of Hawaii")

# Load and plot several locations
  data(hawaii.sites)
  sites <- hawaii.sites[-c(1,4),]
  rownames(sites) <- 1:4
  points(sites,pch=21,col="yellow",bg=color_to_alpha("yellow",.9),cex=1.2)
  text(sites[,1],sites[,2],lab=rownames(sites),pos=c(3,4,1,2),col="yellow")

if (FALSE) { # \dontrun{
# Compute transition object with no depth constraint
  trans1 <- transition_matrix(hawaii)

# Compute transition object with minimum depth constraint:
# path impossible in waters shallower than -200 meters depth
  trans2 <- transition_matrix(hawaii,min.depth=-200)

# Computes least cost distances for both transition matrix and plots the results on the map
  out1 <- least_cost_distance2(trans1,sites,res="path")
  out2 <- least_cost_distance2(trans2,sites,res="path")
  lapply(out1,lines,col="yellow",lwd=4,lty=1) # No depth constraint (yellow paths)
  lapply(out2,lines,col="red",lwd=1,lty=1) # Min depth set to -200 meters (red paths)

# Computes and display distance matrices for both situations
  dist1 <- least_cost_distance2(trans1,sites,res="dist")
  dist2 <- least_cost_distance2(trans2,sites,res="dist")
  dist1
  dist2

# plots the depth profile between location 1 and 3 in the two situations
  dev.new()
  par(mfrow=c(2,1))
  path_profile(out1[[2]],hawaii,pl=TRUE,
                 main="Path between locations 1 & 3\nProfile with no depth constraint")
  path_profile(out2[[2]],hawaii,pl=TRUE,
                 main="Path between locations 1 & 3\nProfile with min depth set to -200m")
} # }
```
