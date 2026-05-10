# Coordinate system for sf data around the antimeridian

A small wrapper around
[`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
that keeps the standard
[`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
behaviour but allows longitude axis labels beyond 180 degrees to be
displayed as western longitudes.

## Usage

``` r
coord_sf_antimeridian(
  xlim = NULL,
  ylim = NULL,
  expand = TRUE,
  crs = NULL,
  default_crs = NULL,
  datum = sf::st_crs(4326),
  label_graticule = ggplot2::waiver(),
  label_axes = ggplot2::waiver(),
  lims_method = "cross",
  ndiscr = 100,
  default = FALSE,
  clip = "on",
  reverse = "none",
  x_breaks = ggplot2::waiver()
)
```

## Arguments

- xlim, ylim:

  Limits for the x and y axes. These limits are specified in the units
  of the default CRS. By default, this means projected coordinates
  (`default_crs = NULL`). How limit specifications translate into the
  exact region shown on the plot can be confusing when non-linear or
  rotated coordinate systems are used as the default crs. First,
  different methods can be preferable under different conditions. See
  parameter `lims_method` for details. Second, specifying limits along
  only one direction can affect the automatically generated limits along
  the other direction. Therefore, it is best to always specify limits
  for both x and y. Third, specifying limits via position scales or
  [`xlim()`](https://ggplot2.tidyverse.org/reference/lims.html)/[`ylim()`](https://ggplot2.tidyverse.org/reference/lims.html)
  is strongly discouraged, as it can result in data points being dropped
  from the plot even though they would be visible in the final plot
  region.

- expand:

  If `TRUE`, the default, adds a small expansion factor to the limits to
  ensure that data and axes don't overlap. If `FALSE`, limits are taken
  exactly from the data or `xlim`/`ylim`. Giving a logical vector will
  separately control the expansion for the four directions (top, left,
  bottom and right). The `expand` argument will be recycled to length 4
  if necessary. Alternatively, can be a named logical vector to control
  a single direction, e.g. `expand = c(bottom = FALSE)`.

- crs:

  The coordinate reference system (CRS) into which all data should be
  projected before plotting. If not specified, will use the CRS defined
  in the first sf layer of the plot.

- default_crs:

  The default CRS to be used for non-sf layers (which don't carry any
  CRS information) and scale limits. The default value of `NULL` means
  that the setting for `crs` is used. This implies that all non-sf
  layers and scale limits are assumed to be specified in projected
  coordinates. A useful alternative setting is
  `default_crs = sf::st_crs(4326)`, which means x and y positions are
  interpreted as longitude and latitude, respectively, in the World
  Geodetic System 1984 (WGS84).

- datum:

  CRS that provides datum to use when generating graticules.

- label_graticule:

  Character vector indicating which graticule lines should be labeled
  where. Meridians run north-south, and the letters `"N"` and `"S"`
  indicate that they should be labeled on their north or south end
  points, respectively. Parallels run east-west, and the letters `"E"`
  and `"W"` indicate that they should be labeled on their east or west
  end points, respectively. Thus, `label_graticule = "SW"` would label
  meridians at their south end and parallels at their west end, whereas
  `label_graticule = "EW"` would label parallels at both ends and
  meridians not at all. Because meridians and parallels can in general
  intersect with any side of the plot panel, for any choice of
  `label_graticule` labels are not guaranteed to reside on only one
  particular side of the plot panel. Also, `label_graticule` can cause
  labeling artifacts, in particular if a graticule line coincides with
  the edge of the plot panel. In such circumstances, `label_axes` will
  generally yield better results and should be used instead.

  This parameter can be used alone or in combination with `label_axes`.

- label_axes:

  Character vector or named list of character values specifying which
  graticule lines (meridians or parallels) should be labeled on which
  side of the plot. Meridians are indicated by `"E"` (for East) and
  parallels by `"N"` (for North). Default is `"--EN"`, which specifies
  (clockwise from the top) no labels on the top, none on the right,
  meridians on the bottom, and parallels on the left. Alternatively,
  this setting could have been specified with
  `list(bottom = "E", left = "N")`.

  This parameter can be used alone or in combination with
  `label_graticule`.

- lims_method:

  Method specifying how scale limits are converted into limits on the
  plot region. Has no effect when `default_crs = NULL`. For a very
  non-linear CRS (e.g., a perspective centered around the North pole),
  the available methods yield widely differing results, and you may want
  to try various options. Methods currently implemented include
  `"cross"` (the default), `"box"`, `"orthogonal"`, and
  `"geometry_bbox"`. For method `"cross"`, limits along one direction
  (e.g., longitude) are applied at the midpoint of the other direction
  (e.g., latitude). This method avoids excessively large limits for
  rotated coordinate systems but means that sometimes limits need to be
  expanded a little further if extreme data points are to be included in
  the final plot region. By contrast, for method `"box"`, a box is
  generated out of the limits along both directions, and then limits in
  projected coordinates are chosen such that the entire box is visible.
  This method can yield plot regions that are too large. Finally, method
  `"orthogonal"` applies limits separately along each axis, and method
  `"geometry_bbox"` ignores all limit information except the bounding
  boxes of any objects in the `geometry` aesthetic.

- ndiscr:

  Number of segments to use for discretising graticule lines; try
  increasing this number when graticules look incorrect.

- default:

  Is this the default coordinate system? If `FALSE` (the default), then
  replacing this coordinate system with another one creates a message
  alerting the user that the coordinate system is being replaced. If
  `TRUE`, that warning is suppressed.

- clip:

  Should drawing be clipped to the extent of the plot panel? A setting
  of `"on"` (the default) means yes, and a setting of `"off"` means no.
  In most cases, the default of `"on"` should not be changed, as setting
  `clip = "off"` can cause unexpected results. It allows drawing of data
  points anywhere on the plot, including in the plot margins. If limits
  are set via `xlim` and `ylim` and some data points fall outside those
  limits, then those data points may show up in places such as the axes,
  the legend, the plot title, or the plot margins.

- reverse:

  A string giving which directions to reverse. `"none"` (default) keeps
  directions as is. `"x"` and `"y"` can be used to reverse their
  respective directions. `"xy"` can be used to reverse both directions.

- x_breaks:

  Breaks used for the x axis. The default lets ggplot2 choose breaks
  automatically.

## Value

A ggplot2 coordinate system.

## See also

[`geom_sf_antimeridian`](https://besibo.github.io/marmap2/reference/geom_sf_antimeridian.md),
[`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
