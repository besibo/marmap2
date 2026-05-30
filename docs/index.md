# marmap2

`marmap2` imports, converts and plots bathymetric and topographic data
in R. It is a modernisation workspace for the historical `marmap`
package, with tidier function names, updated documentation, tibble-first
workflows and newer data import tools.

``` r

library(marmap2)
library(ggplot2)

dat <- get_gebco(
  lon = c(2, 7),
  lat = c(42, 44)
)

quickplot_bathy(dat)
```

![Bathymetric map generated with GEBCO data and
geom_bathy](reference/figures/gebco-mediterranean.png)

Bathymetric map generated with GEBCO data and geom_bathy

NOAA ETOPO data can be imported with the same tibble-first approach:

``` r

dat_noaa <- get_noaa(
  lon = c(-6, -5),
  lat = c(49, 50),
  resolution = 1
)
```

For publication-quality maps, the same data can be passed to the
underlying ggplot2 layers:

``` r

dat |>
  ggplot() +
  geom_bathy(expand = FALSE) +
  geom_coastline(linewidth = 0.4) +
  geom_contour(
    aes(lon, lat, z = depth),
    color = "grey20",
    breaks = seq(0, -2500, by = -200),
    linewidth = 0.2
  ) +
  scale_fill_bathy(
    palette_ocean = "ocean_blues",
    palette_land = "land_hcl"
  ) +
  theme_bw()
```
