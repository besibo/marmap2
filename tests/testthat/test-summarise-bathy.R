test_that("summarise_bathy() summarises a data.frame", {
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )

  out <- summarise_bathy(xyz)

  expect_s3_class(out, "bathy_summary")
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 1L)
  expect_equal(out$class, "data.frame")
  expect_equal(out$n_cells, 9L)
  expect_equal(out$n_lon, 3L)
  expect_equal(out$n_lat, 3L)
  expect_equal(out$coord_type, "geographic")
  expect_equal(out$crs, "EPSG:4326")
  expect_equal(out$x_min, -5)
  expect_equal(out$x_max, -3)
  expect_equal(out$y_min, 48)
  expect_equal(out$y_max, 50)
  expect_equal(out$lon_min, -5)
  expect_equal(out$lon_max, -3)
  expect_equal(out$lat_min, 48)
  expect_equal(out$lat_max, 50)
  expect_equal(out$resolution_x, 1)
  expect_equal(out$resolution_y, 1)
  expect_equal(out$resolution_lon, 60)
  expect_equal(out$resolution_lat, 60)
  expect_equal(out$depth_min, -160)
  expect_equal(out$depth_max, -60)
  expect_equal(out$depth_mean, -110)
  expect_equal(out$depth_median, -110)
  expect_equal(out$n_na, 0L)
  expect_type(out$memory, "character")
})

test_that("summarise_bathy() summarises a tibble with multiple classes", {
  xyz <- tibble::tibble(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(-80, -70, -120, -110)
  )

  out <- summarise_bathy(xyz)

  expect_s3_class(out, "bathy_summary")
  expect_equal(out$class, "tbl_df/tbl/data.frame")
  expect_equal(out$n_cells, 4L)
  expect_equal(out$n_lon, 2L)
  expect_equal(out$n_lat, 2L)
})

test_that("summarise_bathy() summarises a bathy object", {
  xyz <- data.frame(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(-80, -70, -120, -110)
  )
  bathy <- as_bathy(xyz)

  out <- summarise_bathy(bathy)

  expect_s3_class(out, "bathy_summary")
  expect_equal(out$class, "bathy")
  expect_equal(out$n_cells, 4L)
  expect_equal(out$n_lon, 2L)
  expect_equal(out$n_lat, 2L)
  expect_equal(out$lon_min, -5)
  expect_equal(out$lon_max, -4)
  expect_equal(out$lat_min, 48)
  expect_equal(out$lat_max, 49)
  expect_equal(out$depth_min, -120)
  expect_equal(out$depth_max, -70)
})

test_that("summarise_bathy() ignores NA values in depth statistics", {
  xyz <- tibble::tibble(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(NA_real_, -70, -120, -110)
  )

  out <- summarise_bathy(xyz)

  expect_equal(out$depth_min, -120)
  expect_equal(out$depth_max, -70)
  expect_equal(out$depth_mean, -100)
  expect_equal(out$depth_median, -110)
  expect_equal(out$n_na, 1L)
})

test_that("summarise_bathy() handles all-NA depth values", {
  xyz <- tibble::tibble(
    lon = c(-5, -4),
    lat = c(48, 49),
    depth = c(NA_real_, NA_real_)
  )

  out <- summarise_bathy(xyz)

  expect_true(is.na(out$depth_min))
  expect_true(is.na(out$depth_max))
  expect_true(is.na(out$depth_mean))
  expect_true(is.na(out$depth_median))
  expect_equal(out$n_na, 2L)
})

test_that("summarise_bathy() can be converted to a plain tibble", {
  xyz <- tibble::tibble(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(-80, -70, -120, -110)
  )

  out <- tibble::as_tibble(summarise_bathy(xyz))

  expect_s3_class(out, "tbl_df")
  expect_false(inherits(out, "bathy_summary"))
  expect_named(out, c(
    "class", "coord_type", "crs", "crs_unit",
    "n_cells", "n_lon", "n_lat",
    "x_min", "x_max", "y_min", "y_max",
    "lon_min", "lon_max", "lat_min", "lat_max",
    "resolution_x", "resolution_y",
    "resolution_lon", "resolution_lat", "resolution_unit",
    "depth_min", "depth_max", "depth_mean", "depth_median",
    "n_na", "memory"
  ))
})

test_that("summarise_bathy() reports projected coordinate metadata", {
  testthat::skip_if_not_installed("terra")
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )
  projected <- project_bathy(xyz, crs_to = 3857, method = "near")

  out <- summarise_bathy(projected)

  expect_equal(out$coord_type, "projected")
  expect_equal(out$crs, "EPSG:3857")
  expect_equal(out$crs_unit, "m")
  expect_true(is.na(out$resolution_lon))
  expect_true(is.na(out$resolution_lat))
  expect_equal(out$resolution_unit, "m")
  expect_true(is.finite(out$x_min))
  expect_true(is.finite(out$y_min))
  expect_true(is.finite(out$lon_min))
  expect_true(is.finite(out$lat_min))
})

test_that("print.bathy_summary() uses projected labels for projected data", {
  testthat::skip_if_not_installed("terra")
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )
  projected <- project_bathy(xyz, crs_to = 3857, method = "near")

  printed <- capture.output(returned <- print(summarise_bathy(projected)))

  expect_true(any(grepl("CRS:        EPSG:3857", printed, fixed = TRUE)))
  expect_true(any(grepl("X range:", printed, fixed = TRUE)))
  expect_true(any(grepl("Y range:", printed, fixed = TRUE)))
  expect_true(any(grepl("Geographic:", printed, fixed = TRUE)))
  expect_s3_class(returned, "bathy_summary")
})

test_that("print.bathy_summary() formats coordinates and returns invisibly", {
  xyz <- tibble::tibble(
    lon = c(-5, 3),
    lat = c(-12, 48),
    depth = c(-100, 20)
  )
  out <- summarise_bathy(xyz)

  printed <- capture.output(returned <- print(out))

  expect_true(any(grepl("Longitude:  5 W to 3 E", printed, fixed = TRUE)))
  expect_true(any(grepl("Latitude:   12 S to 48 N", printed, fixed = TRUE)))
  expect_identical(returned, out)
})

test_that("summarise_bathy() reports invalid inputs", {
  xyz <- tibble::tibble(
    lon = c(-5, -4),
    lat = c(48, 49),
    depth = c(-80, -70)
  )

  expect_error(summarise_bathy(1), "data frame/tibble")
  expect_error(summarise_bathy(xyz[, c("lon", "lat")]), "lon, lat, and depth")
  expect_error(
    summarise_bathy(transform(xyz, depth = as.character(depth))),
    "must be numeric"
  )
})
