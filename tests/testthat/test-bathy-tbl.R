test_that("bathy_to_tbl() converts a bathy object to a tibble", {
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )
  bathy <- tbl_to_bathy(xyz)

  out <- bathy_to_tbl(bathy)

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("lon", "lat", "depth"))
  expect_equal(nrow(out), 9)
  expect_equal(out$lon, c(-5, -4, -3, -5, -4, -3, -5, -4, -3))
  expect_equal(out$lat, c(50, 50, 50, 49, 49, 49, 48, 48, 48))
  expect_equal(out$depth, c(-60, -100, -140, -70, -110, -150, -80, -120, -160))
})

test_that("bathy_to_tbl() supports custom output names", {
  xyz <- data.frame(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(-80, -70, -120, -110)
  )
  bathy <- tbl_to_bathy(xyz)

  out <- bathy_to_tbl(bathy, names = c("x", "y", "z"))

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("x", "y", "z"))
})

test_that("tbl_to_bathy() converts a regular tibble to a bathy object", {
  xyz <- tibble::tibble(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )

  bathy <- tbl_to_bathy(xyz)

  expect_s3_class(bathy, "bathy")
  expect_equal(dim(bathy), c(3L, 3L))
  expect_equal(as.numeric(rownames(bathy)), c(-5, -4, -3))
  expect_equal(as.numeric(colnames(bathy)), c(48, 49, 50))
  expect_equal(unclass(bathy)[1, 1], -80)
  expect_equal(unclass(bathy)[3, 3], -140)
})

test_that("tbl_to_bathy() supports custom input column names", {
  xyz <- tibble::tibble(
    x = rep(c(-5, -4), each = 2),
    y = rep(c(48, 49), times = 2),
    z = c(-80, -70, -120, -110)
  )

  bathy <- tbl_to_bathy(xyz, lon = "x", lat = "y", depth = "z")

  expect_s3_class(bathy, "bathy")
  expect_equal(dim(bathy), c(2L, 2L))
  expect_equal(unclass(bathy)[1, 1], -80)
})

test_that("tbl/bathy round trips preserve coordinates and values", {
  xyz <- tibble::tibble(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )

  bathy <- tbl_to_bathy(xyz)
  out <- bathy_to_tbl(bathy)
  bathy_roundtrip <- tbl_to_bathy(out)

  expect_equal(unclass(bathy_roundtrip), unclass(bathy))
  expect_equal(as.numeric(rownames(bathy_roundtrip)), as.numeric(rownames(bathy)))
  expect_equal(as.numeric(colnames(bathy_roundtrip)), as.numeric(colnames(bathy)))
})

test_that("bathy/tbl round trips preserve the bathy matrix", {
  bathy <- matrix(
    c(-80, -120, -160, -70, -110, -150, -60, -100, -140),
    nrow = 3,
    ncol = 3,
    dimnames = list(c(-5, -4, -3), c(48, 49, 50))
  )
  class(bathy) <- "bathy"

  out <- bathy |>
    bathy_to_tbl() |>
    tbl_to_bathy()

  expect_equal(unclass(out), unclass(bathy))
  expect_equal(as.numeric(rownames(out)), as.numeric(rownames(bathy)))
  expect_equal(as.numeric(colnames(out)), as.numeric(colnames(bathy)))
})

test_that("conversion functions report invalid inputs", {
  xyz <- tibble::tibble(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(-80, -70, -120, -110)
  )
  bathy <- tbl_to_bathy(xyz)

  expect_error(bathy_to_tbl(xyz), "class 'bathy'")
  expect_error(bathy_to_tbl(bathy, names = c("x", "y")), "length 3")
  expect_error(bathy_to_tbl(bathy, names = c("x", NA, "z")), "length 3")
  expect_error(tbl_to_bathy(1), "data.frame or tibble")
  expect_error(tbl_to_bathy(xyz[, c("lon", "lat")]), "must contain columns")
  expect_error(tbl_to_bathy(xyz, lon = c("lon", "x")), "column names")
  expect_error(tbl_to_bathy(xyz, lon = NA_character_), "column names")
})
