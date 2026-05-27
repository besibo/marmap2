make_reduction_grid <- function() {
  xyz <- expand.grid(
    lon = (0:6) / 60,
    lat = 10 + (0:6) / 60
  )
  xyz <- xyz[order(xyz$lon, xyz$lat), ]
  xyz$depth <- seq_len(nrow(xyz))
  rownames(xyz) <- NULL
  xyz
}

expect_regular_spacing <- function(x, resolution) {
  expect_equal(
    unique(round(diff(sort(unique(x$lon))) * 60, 10)),
    resolution
  )
  expect_equal(
    unique(round(diff(sort(unique(x$lat))) * 60, 10)),
    resolution
  )
}

test_that("reduce_bathy_resolution() preserves input classes", {
  xyz <- make_reduction_grid()
  tbl <- tibble::as_tibble(xyz)
  bathy <- tbl_to_bathy(xyz)

  out_df <- reduce_bathy_resolution(xyz, resolution = 3)
  out_tbl <- reduce_bathy_resolution(tbl, resolution = 3)
  out_bathy <- reduce_bathy_resolution(bathy, resolution = 3)

  expect_s3_class(out_df, "data.frame")
  expect_false(inherits(out_df, "tbl_df"))
  expect_s3_class(out_tbl, "tbl_df")
  expect_s3_class(out_bathy, "bathy")
})

test_that("method = 'nearest' keeps nearest native cells", {
  xyz <- make_reduction_grid()

  out <- reduce_bathy_resolution(xyz, resolution = 3, method = "nearest")

  expect_equal(nrow(out), 4L)
  expect_equal(out$lon, c(0.025, 0.075, 0.025, 0.075))
  expect_equal(out$lat, c(10.075, 10.075, 10.025, 10.025))
  expect_equal(out$depth, c(19, 40, 17, 38))
})

test_that("method = 'mean' aggregates native cells", {
  xyz <- make_reduction_grid()

  out <- reduce_bathy_resolution(xyz, resolution = 3, method = "mean")

  expect_equal(nrow(out), 4L)
  expect_equal(out$depth, c(12.5, 37, 9, 33.5))
})

test_that("method = 'median' aggregates native cells", {
  xyz <- make_reduction_grid()

  out <- reduce_bathy_resolution(xyz, resolution = 3, method = "median")

  expect_equal(nrow(out), 4L)
  expect_equal(out$depth, c(12.5, 37, 9, 33.5))
})

test_that("coarser target resolutions reduce the grid", {
  xyz <- make_reduction_grid()

  out <- reduce_bathy_resolution(xyz, resolution = 3)

  expect_lt(nrow(out), nrow(xyz))
  expect_equal(length(unique(out$lon)), 2L)
  expect_equal(length(unique(out$lat)), 2L)
})

test_that("equal or finer target resolutions return the input unchanged", {
  xyz <- make_reduction_grid()
  tbl <- tibble::as_tibble(xyz)
  bathy <- tbl_to_bathy(xyz)

  expect_message(
    out_df <- reduce_bathy_resolution(xyz, resolution = 1),
    "returning input unchanged"
  )
  expect_message(
    out_tbl <- reduce_bathy_resolution(tbl, resolution = 0.5),
    "returning input unchanged"
  )
  expect_message(
    out_bathy <- reduce_bathy_resolution(bathy, resolution = 1),
    "returning input unchanged"
  )

  expect_identical(out_df, xyz)
  expect_identical(out_tbl, tbl)
  expect_identical(out_bathy, bathy)
})

test_that("non-multiple target resolutions produce a regular grid", {
  xyz <- make_reduction_grid()

  out <- reduce_bathy_resolution(xyz, resolution = 2.5)

  expect_equal(length(unique(out$lon)), 2L)
  expect_equal(length(unique(out$lat)), 2L)
  expect_regular_spacing(out, 2.5)
})

test_that("resolution = 0.6 does not introduce empty grid lines", {
  native_step <- 0.25 / 60
  xyz <- expand.grid(
    lon = 2 + (0:24) * native_step,
    lat = 42 + (0:24) * native_step
  )
  xyz <- xyz[order(xyz$lon, xyz$lat), ]
  xyz$depth <- seq_len(nrow(xyz))
  rownames(xyz) <- NULL

  out <- reduce_bathy_resolution(xyz, resolution = 0.6)

  expect_equal(nrow(out), length(unique(out$lon)) * length(unique(out$lat)))
  expect_false(anyNA(out$depth))
  expect_regular_spacing(out, 0.6)
})

test_that("target spacing matches the requested resolution", {
  xyz <- make_reduction_grid()

  out <- reduce_bathy_resolution(xyz, resolution = 3)

  expect_regular_spacing(out, 3)
})

test_that("NA values are ignored unless a whole output cell is missing", {
  xyz <- make_reduction_grid()
  missing_cell <- xyz$lon < 0.05 & xyz$lat < 10.05
  xyz$depth[missing_cell] <- NA_real_
  xyz$depth[xyz$lon > 0.05 & xyz$lat > 10.05][1] <- NA_real_

  out <- reduce_bathy_resolution(xyz, resolution = 3, method = "mean")

  fully_missing <- out$lon == 0.025 & out$lat == 10.025
  partly_missing <- out$lon == 0.075 & out$lat == 10.075
  expect_true(is.na(out$depth[fully_missing]))
  expect_false(is.na(out$depth[partly_missing]))
})

test_that("reduce_bathy_resolution() reports invalid inputs", {
  xyz <- make_reduction_grid()

  expect_error(reduce_bathy_resolution(xyz, resolution = 0), "positive numeric")
  expect_error(reduce_bathy_resolution(xyz, resolution = -1), "positive numeric")
  expect_error(reduce_bathy_resolution(xyz, resolution = "3"), "positive numeric")
  expect_error(reduce_bathy_resolution(xyz, resolution = c(3, 4)), "positive numeric")
  expect_error(reduce_bathy_resolution(1, resolution = 3), "data frame/tibble")
  expect_error(
    reduce_bathy_resolution(xyz[, c("lon", "lat")], resolution = 3),
    "lon, lat, and depth"
  )
  expect_error(
    reduce_bathy_resolution(xyz, resolution = 3, method = "bilinear"),
    "'arg' should be one of"
  )
})
