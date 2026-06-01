make_irregular_points <- function() {
  data.frame(
    lon = c(-5.0, -4.8, -4.5, -4.2, -4.0, -3.7, -3.4, -3.1),
    lat = c(47.0, 47.3, 47.8, 48.2, 48.7, 49.0, 49.4, 49.8),
    depth = c(-100, -120, -180, -240, -300, -340, -420, -500)
  )
}

test_that("griddify() returns a regular tibble by default", {
  out <- griddify(make_irregular_points(), nlon = 10, nlat = 8, interpolate = FALSE)

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("lon", "lat", "depth"))
  expect_equal(nrow(out), 80L)
  expect_equal(length(unique(out$lon)), 10L)
  expect_equal(length(unique(out$lat)), 8L)
})

test_that("griddify() supports bathy and SpatRaster outputs", {
  xyz <- make_irregular_points()

  bathy <- griddify(xyz, nlon = 10, nlat = 8, interpolate = FALSE, class = "bathy")
  raster <- griddify(xyz, nlon = 10, nlat = 8, interpolate = FALSE, class = "spatraster")

  expect_s3_class(bathy, "bathy")
  expect_equal(dim(bathy), c(10L, 8L))
  expect_s4_class(raster, "SpatRaster")
  expect_equal(dim(raster)[1:2], c(8L, 10L))
})

test_that("griddify() accepts custom column names", {
  xyz <- data.frame(
    x = c(-5, -4.5, -4, -3.5),
    y = c(47, 48, 49, 50),
    z = c(-100, -200, -300, -400)
  )

  out <- griddify(xyz, nlon = 5, nlat = 5, lon = "x", lat = "y", depth = "z")

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("lon", "lat", "depth"))
})

test_that("griddify() reports invalid inputs", {
  xyz <- make_irregular_points()

  expect_error(griddify(xyz, nlon = 1, nlat = 8), "nlon")
  expect_error(griddify(xyz, nlon = 10, nlat = 1), "nlat")
  expect_error(griddify(xyz[, c("lon", "lat")], nlon = 10, nlat = 8), "longitude, latitude, and depth")
  expect_error(griddify(transform(xyz, depth = as.character(depth)), nlon = 10, nlat = 8), "must be numeric")
})
