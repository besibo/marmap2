# marmap2

`marmap2` imports, plots and analyses bathymetric and topographic data
in R. It is a modernisation workspace for the historical `marmap`
package, with tidier function names, updated documentation and newer
data import workflows.

``` r
library(marmap2)

bathy <- mar_get_noaa(
  lon1 = -6, lon2 = -5,
  lat1 = 49, lat2 = 50,
  resolution = 1
)

plot(bathy, image = TRUE, land = TRUE)
```

The package also includes an importer for the official GEBCO download
service:

``` r
gebco <- mar_get_gebco(
  lon1 = -6, lon2 = -5,
  lat1 = 49, lat2 = 50,
  resolution = 1
)
```
