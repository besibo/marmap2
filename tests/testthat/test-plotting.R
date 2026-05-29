make_plot_grid <- function() {
  xyz <- expand.grid(
    lon = c(-5, -4, -3),
    lat = c(48, 49, 50)
  )
  xyz$depth <- seq_len(nrow(xyz))
  xyz
}

make_contour_grid <- function() {
  xyz <- expand.grid(
    lon = 1:5,
    lat = 1:5
  )
  xyz$depth <- as.vector(outer(1:5, 1:5, function(x, y) x + y - 6))
  xyz
}

test_that("geom_bathy() builds with a tibble", {
  xyz <- tibble::as_tibble(make_plot_grid())

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy()
  )

  expect_equal(nrow(built$data[[1]]), nrow(xyz))
  expect_s3_class(built$plot$coordinates, "CoordSf")
})

test_that("geom_bathy() builds with a data.frame", {
  xyz <- make_plot_grid()

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy()
  )

  expect_equal(nrow(built$data[[1]]), nrow(xyz))
  expect_s3_class(built$plot$coordinates, "CoordSf")
})

test_that("geom_bathy() builds with a bathy object", {
  xyz <- make_plot_grid()
  bathy <- tbl_to_bathy(xyz)

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot() +
      geom_bathy(data = bathy)
  )

  expect_equal(nrow(built$data[[1]]), nrow(xyz))
  expect_s3_class(built$plot$coordinates, "CoordSf")
})

test_that("geom_bathy() builds with point sf data", {
  testthat::skip_if_not_installed("sf")
  xyz <- make_plot_grid()
  sf_xyz <- sf::st_as_sf(xyz, coords = c("lon", "lat"), crs = 4326)

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot() +
      geom_bathy(data = sf_xyz)
  )

  expect_equal(nrow(built$data[[1]]), nrow(xyz))
  expect_s3_class(built$plot$coordinates, "CoordSf")
})

test_that("geom_bathy() supports tile and raster rendering", {
  xyz <- make_plot_grid()

  tile_plot <- ggplot2::ggplot(xyz) +
    geom_bathy(geom = "tile")
  raster_plot <- ggplot2::ggplot(xyz) +
    geom_bathy(geom = "raster")

  tile_built <- ggplot2::ggplot_build(tile_plot)
  raster_built <- ggplot2::ggplot_build(raster_plot)

  expect_s3_class(tile_built$plot$layers[[1]]$geom, "GeomTile")
  expect_s3_class(raster_built$plot$layers[[1]]$geom, "GeomRaster")
})

test_that("geom_bathy() uses scale_fill_bathy() by default", {
  xyz <- data.frame(
    lon = 1:3,
    lat = 1,
    depth = c(-1000, 0, 1000)
  )

  geom_bathy_built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy()
  )
  explicit_scale_built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz, ggplot2::aes(lon, lat, fill = depth)) +
      ggplot2::geom_tile() +
      scale_fill_bathy()
  )

  expect_equal(geom_bathy_built$data[[1]]$fill, explicit_scale_built$data[[1]]$fill)
})

test_that("geom_bathy() default fill scale can be replaced silently", {
  xyz <- data.frame(
    lon = 1:3,
    lat = 1,
    depth = c(-1000, 0, 1000)
  )

  expect_silent(
    built <- ggplot2::ggplot_build(
      ggplot2::ggplot(xyz) +
        geom_bathy() +
        scale_fill_bathy(palette_ocean = "ocean_teal")
    )
  )

  explicit <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz, ggplot2::aes(lon, lat, fill = depth)) +
      ggplot2::geom_tile() +
      scale_fill_bathy(palette_ocean = "ocean_teal")
  )

  expect_equal(built$data[[1]]$fill, explicit$data[[1]]$fill)
})

test_that("geom_bathy() supports sf and fixed coordinates", {
  xyz <- make_plot_grid()

  sf_built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy(coord = "sf")
  )
  fixed_built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy(coord = "fixed")
  )

  expect_s3_class(sf_built$plot$coordinates, "CoordSf")
  expect_s3_class(fixed_built$plot$coordinates, "CoordCartesian")
})

test_that("geom_bathy() labels axes by default and allows overrides", {
  xyz <- make_plot_grid()

  default_plot <- ggplot2::ggplot(xyz) +
    geom_bathy()
  custom_plot <- ggplot2::ggplot(xyz) +
    geom_bathy() +
    ggplot2::labs(x = "x", y = "y")

  expect_equal(default_plot$labels$x, "Longitude")
  expect_equal(default_plot$labels$y, "Latitude")
  expect_equal(custom_plot$labels$x, "x")
  expect_equal(custom_plot$labels$y, "y")
})

test_that("geom_bathy() uses antimeridian longitude labels", {
  xyz <- expand.grid(
    lon = c(170, 180, 190),
    lat = c(50, 51, 52)
  )
  xyz$depth <- seq_len(nrow(xyz))

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy(antimeridian = TRUE, x_breaks = c(170, 180, 190))
  )

  labels <- unlist(built$layout$panel_params[[1]]$x$get_labels())
  expect_equal(labels, c("170\u00b0E", "180\u00b0", "170\u00b0W"))
})

test_that("geom_bathy() does not add internal columns to user data", {
  xyz <- make_plot_grid()

  ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy()
  )

  expect_false(".bathy_width" %in% names(xyz))
  expect_false(".bathy_height" %in% names(xyz))
  expect_false(any(c(".bathy_width", ".bathy_height") %in% names(ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_bathy()
  )$data[[1]])))
})

test_that("geom_coastline() produces a contour layer at 0 m", {
  xyz <- make_contour_grid()
  plot <- ggplot2::ggplot(xyz) +
    geom_coastline()
  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(plot$layers[[1]]$geom, "GeomContour")
  expect_equal(plot$layers[[1]]$stat_params$breaks, 0)
  expect_true(nrow(built$data[[1]]) > 0)
  expect_equal(unique(built$data[[1]]$level), 0)
})

test_that("geom_coastline() supports line style arguments", {
  xyz <- make_contour_grid()

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      geom_coastline(colour = "red", linewidth = 1.2, linetype = "dashed")
  )

  expect_equal(unique(built$data[[1]]$colour), "red")
  expect_equal(unique(built$data[[1]]$linewidth), 1.2)
  expect_equal(unique(built$data[[1]]$linetype), "dashed")
})

test_that("geom_coastline() inherits mappings", {
  xyz <- make_contour_grid()

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz, ggplot2::aes(lon, lat, z = depth)) +
      geom_coastline()
  )

  expect_true(nrow(built$data[[1]]) > 0)
  expect_equal(unique(built$data[[1]]$level), 0)
})

test_that("coord_sf_antimeridian() returns sf coordinates with 360 labels", {
  coord <- coord_sf_antimeridian(x_breaks = c(170, 180, 190))
  xyz <- expand.grid(
    lon = c(170, 180, 190),
    lat = c(50, 51, 52)
  )
  xyz$depth <- seq_len(nrow(xyz))

  built <- ggplot2::ggplot_build(
    ggplot2::ggplot(xyz) +
      ggplot2::geom_tile(ggplot2::aes(lon, lat, fill = depth)) +
      coord
  )

  labels <- unlist(built$layout$panel_params[[1]]$x$get_labels())
  expect_s3_class(coord, "CoordSf")
  expect_equal(labels, c("170\u00b0E", "180\u00b0", "170\u00b0W"))
})

test_that("quickplot_bathy() builds a default bathymetric map", {
  xyz <- make_contour_grid()

  plot <- quickplot_bathy(xyz)
  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(plot, "ggplot")
  expect_length(plot$layers, 4)
  expect_s3_class(plot$layers[[1]]$geom, "GeomTile")
  expect_s3_class(plot$layers[[2]]$geom, "GeomContour")
  expect_s3_class(built$plot$coordinates, "CoordSf")
})

test_that("quickplot_bathy() accepts bathy objects", {
  xyz <- make_contour_grid()
  bathy <- tbl_to_bathy(xyz)

  plot <- quickplot_bathy(bathy)
  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(built$data[[1]]), nrow(xyz))
})
