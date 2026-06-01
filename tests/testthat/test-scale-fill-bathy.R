scale_fill_values <- function(depth, scale = scale_fill_bathy()) {
  dat <- data.frame(
    lon = seq_along(depth),
    lat = 1,
    depth = depth
  )
  ggplot2::ggplot_build(
    ggplot2::ggplot(dat, ggplot2::aes(lon, lat, fill = depth)) +
      ggplot2::geom_tile() +
      scale
  )$data[[1]]$fill
}

scale_colour_values <- function(depth, scale = scale_colour_bathy()) {
  dat <- data.frame(
    lon = seq_along(depth),
    lat = 1,
    depth = depth
  )
  ggplot2::ggplot_build(
    ggplot2::ggplot(dat, ggplot2::aes(lon, lat, colour = depth)) +
      ggplot2::geom_point() +
      scale
  )$data[[1]]$colour
}

test_that("bathy_palettes() lists coherent palette families", {
  all_palettes <- bathy_palettes()
  ocean_palettes <- bathy_palettes("ocean")
  land_palettes <- bathy_palettes("land")

  expect_type(all_palettes, "character")
  expect_true(all(ocean_palettes %in% all_palettes))
  expect_true(all(land_palettes %in% all_palettes))
  expect_true(all(startsWith(ocean_palettes, "ocean_")))
  expect_true(all(startsWith(land_palettes, "land_")))
  expect_error(bathy_palettes("invalid"), "'arg' should be one of")
})

test_that("bathy_palette() returns colour vectors", {
  expect_equal(length(bathy_palette("ocean_blues", n = 5)), 5L)
  expect_equal(length(bathy_palette("land_earth", n = 5)), 5L)
  expect_true(all(grepl("^#", bathy_palette("ocean_blues", n = 5))))
  expect_equal(bathy_palette("red", n = 3), rep("red", 3))
  expect_equal(length(bathy_palette(c("red", "blue"), n = 4)), 4L)
  expect_equal(
    bathy_palette(function(n) rep("green", n), n = 3),
    rep("#00FF00", 3)
  )
})

test_that("internal ocean and land palettes work in scale_fill_bathy()", {
  depths <- c(-1000, -10, 0, 10, 1000)

  for (palette in bathy_palettes("ocean")) {
    fills <- scale_fill_values(
      depths,
      scale_fill_bathy(palette_ocean = palette, palette_land = "grey80")
    )
    expect_equal(length(fills), length(depths))
    expect_false(anyNA(fills))
  }

  for (palette in bathy_palettes("land")) {
    fills <- scale_fill_values(
      depths,
      scale_fill_bathy(palette_ocean = "#D8EEF3", palette_land = palette)
    )
    expect_equal(length(fills), length(depths))
    expect_false(anyNA(fills))
  }
})

test_that("scale_fill_bathy() accepts single colours, vectors, and functions", {
  depths <- c(-10, 0, 10)

  single <- scale_fill_values(
    depths,
    scale_fill_bathy(palette_ocean = "grey20", palette_land = "grey80")
  )
  vector <- scale_fill_values(
    depths,
    scale_fill_bathy(
      palette_ocean = c("navy", "cyan"),
      palette_land = c("tan", "brown")
    )
  )
  fun <- scale_fill_values(
    depths,
    scale_fill_bathy(
      palette_ocean = function(n) grDevices::hcl.colors(n, "Blues 3"),
      palette_land = function(n) grDevices::hcl.colors(n, "Terrain 2")
    )
  )

  expect_equal(single[1], single[2])
  expect_false(anyNA(single))
  expect_false(anyNA(vector))
  expect_false(anyNA(fun))
})

test_that("scale_colour_bathy() and scale_color_bathy() map colour aesthetics", {
  depths <- c(-1000, 0, 1000)

  colour <- scale_colour_values(depths)
  color <- scale_colour_values(depths, scale_color_bathy())

  expect_equal(colour, color)
  expect_equal(length(unique(colour)), 3L)
  expect_false(anyNA(colour))
})

test_that("scale_fill_bathy() supports ocean-only and land-only scales", {
  depths <- c(-10, 0, 10)

  ocean_only <- scale_fill_values(
    depths,
    scale_fill_bathy(palette_ocean = "ocean_blues", palette_land = NULL)
  )
  land_only <- scale_fill_values(
    depths,
    scale_fill_bathy(palette_ocean = NULL, palette_land = "land_earth")
  )

  expect_false(anyNA(ocean_only))
  expect_false(anyNA(land_only))
  expect_equal(ocean_only[3], "#CCCCCC")
  expect_equal(land_only[1], "#D8EEF3")
})

test_that("scale_fill_bathy() supports rescale and truncate modes", {
  depths <- c(-1000, -500, 0)

  rescale <- scale_fill_values(
    depths,
    scale_fill_bathy(palette_land = NULL, mode = "rescale")
  )
  truncate <- scale_fill_values(
    depths,
    scale_fill_bathy(palette_land = NULL, mode = "truncate")
  )

  expect_false(anyNA(rescale))
  expect_false(anyNA(truncate))
  expect_false(identical(rescale, truncate))
})

test_that("scale_fill_bathy() supports custom truncate reference limits", {
  depths <- c(-2000, -1000, 0, 1000)
  reference <- data.frame(
    lon = 1:4,
    lat = 1,
    depth = c(-4000, -2000, 0, 2000)
  )

  from_vector <- scale_fill_values(
    depths,
    scale_fill_bathy(
      mode = "truncate",
      reference_limits = range(reference$depth)
    )
  )
  from_data <- scale_fill_values(
    depths,
    scale_fill_bathy(
      mode = "truncate",
      reference_limits = reference
    )
  )
  default_reference <- scale_fill_values(
    depths,
    scale_fill_bathy(mode = "truncate")
  )

  expect_equal(from_vector, from_data)
  expect_false(identical(from_vector, default_reference))
  expect_error(
    scale_fill_bathy(mode = "truncate", reference_limits = "bad"),
    "reference_limits"
  )
  expect_error(
    scale_fill_bathy(mode = "truncate", reference_limits = data.frame(depth = NA_real_)),
    "finite depth"
  )
})

test_that("scale_fill_bathy() handles ocean-only, land-only, and mixed data", {
  ocean <- scale_fill_values(c(-1000, -500, 0))
  land <- scale_fill_values(c(0, 500, 1000))
  mixed <- scale_fill_values(c(-1000, 0, 1000))

  expect_equal(length(unique(ocean)), 3L)
  expect_equal(length(unique(land)), 3L)
  expect_equal(length(unique(mixed)), 3L)
  expect_false(anyNA(ocean))
  expect_false(anyNA(land))
  expect_false(anyNA(mixed))
})

test_that("scale_fill_bathy() supports limits and NA values", {
  limited <- scale_fill_values(
    c(-1000, -100, 0, 100, 1000),
    scale_fill_bathy(limits = c(-100, 100))
  )
  with_na <- scale_fill_values(
    c(-1000, NA, 1000),
    scale_fill_bathy(na.value = "pink")
  )

  expect_equal(limited[1], limited[2])
  expect_equal(limited[4], limited[5])
  expect_equal(with_na[2], "pink")
})

test_that("scale_fill_bathy() reports invalid palettes and limits", {
  expect_error(
    scale_fill_bathy(palette_ocean = "not_a_palette_or_colour"),
    "palette_ocean"
  )
  expect_error(scale_fill_bathy(palette_ocean = NA_character_), "palette_ocean")
  expect_error(scale_fill_bathy(palette_ocean = NULL, palette_land = NULL), "At least one")
  expect_error(scale_fill_bathy(limits = c(0, 100)), "spanning zero")
  expect_error(scale_fill_bathy(limits = "bad"), "finite numeric")
})
