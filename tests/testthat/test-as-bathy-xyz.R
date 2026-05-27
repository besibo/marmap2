test_that("as_bathy() converts a regular xyz table to a bathy object", {
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )

  bathy <- as_bathy(xyz)

  expect_s3_class(bathy, "bathy")
  expect_equal(dim(bathy), c(3L, 3L))
  expect_equal(as.numeric(rownames(bathy)), c(-5, -4, -3))
  expect_equal(as.numeric(colnames(bathy)), c(48, 49, 50))
  expect_equal(unclass(bathy)[1, 1], -80)
  expect_equal(unclass(bathy)[3, 3], -140)
})

test_that("as_bathy() orders unordered xyz tables by longitude and latitude", {
  xyz <- data.frame(
    lon = c(-4, -5, -3, -5, -4, -3, -3, -5, -4),
    lat = c(49, 48, 50, 50, 48, 49, 48, 49, 50),
    depth = c(-110, -80, -140, -60, -120, -150, -160, -70, -100)
  )

  bathy <- as_bathy(xyz)

  expect_equal(as.numeric(rownames(bathy)), c(-5, -4, -3))
  expect_equal(as.numeric(colnames(bathy)), c(48, 49, 50))
  expect_equal(as.numeric(unclass(bathy)[1, ]), c(-80, -70, -60))
  expect_equal(as.numeric(unclass(bathy)[2, ]), c(-120, -110, -100))
  expect_equal(as.numeric(unclass(bathy)[3, ]), c(-160, -150, -140))
})

test_that("as_bathy() keeps missing cells as NA in incomplete xyz tables", {
  xyz <- data.frame(
    lon = c(-5, -5, -4),
    lat = c(48, 49, 48),
    depth = c(-80, -70, -120)
  )

  bathy <- as_bathy(xyz)

  expect_s3_class(bathy, "bathy")
  expect_equal(dim(bathy), c(2L, 2L))
  expect_equal(as.numeric(rownames(bathy)), c(-5, -4))
  expect_equal(as.numeric(colnames(bathy)), c(48, 49))
  expect_equal(unclass(bathy)[1, 1], -80)
  expect_equal(unclass(bathy)[1, 2], -70)
  expect_equal(unclass(bathy)[2, 1], -120)
  expect_true(is.na(unclass(bathy)[2, 2]))
})

test_that("as_xyz() converts a bathy object to the historical xyz format", {
  xyz <- data.frame(
    lon = rep(c(-5, -4, -3), each = 3),
    lat = rep(c(48, 49, 50), times = 3),
    depth = c(-80, -70, -60, -120, -110, -100, -160, -150, -140)
  )
  bathy <- as_bathy(xyz)

  out <- as_xyz(bathy)

  expect_s3_class(out, "data.frame")
  expect_named(out, c("V1", "V2", "V3"))
  expect_equal(out$V1, c(-5, -4, -3, -5, -4, -3, -5, -4, -3))
  expect_equal(out$V2, c(50, 50, 50, 49, 49, 49, 48, 48, 48))
  expect_equal(out$V3, c(-60, -100, -140, -70, -110, -150, -80, -120, -160))
})

test_that("as_xyz() exports a tibble to the historical xyz format", {
  xyz <- tibble::tibble(
    lon = c(-5, -4, -3),
    lat = c(48, 49, 50),
    depth = c(-80, -110, -140)
  )

  out <- as_xyz(xyz)

  expect_s3_class(out, "data.frame")
  expect_false(inherits(out, "tbl_df"))
  expect_named(out, c("V1", "V2", "V3"))
  expect_equal(out$V1, xyz$lon)
  expect_equal(out$V2, xyz$lat)
  expect_equal(out$V3, xyz$depth)
})

test_that("as_xyz() supports custom input and output names", {
  xyz <- tibble::tibble(
    x = c(-5, -4, -3),
    y = c(48, 49, 50),
    z = c(-80, -110, -140)
  )

  out <- as_xyz(
    xyz,
    lon = "x",
    lat = "y",
    depth = "z",
    names = c("longitude", "latitude", "elevation")
  )

  expect_named(out, c("longitude", "latitude", "elevation"))
  expect_equal(out$longitude, xyz$x)
  expect_equal(out$latitude, xyz$y)
  expect_equal(out$elevation, xyz$z)
})

test_that("as_bathy() and as_xyz() report invalid inputs", {
  xyz <- data.frame(
    lon = rep(c(-5, -4), each = 2),
    lat = rep(c(48, 49), times = 2),
    depth = c(-80, -70, -120, -110)
  )
  bathy <- as_bathy(xyz)

  expect_error(as_bathy(bathy), "already of class 'bathy'")
  expect_error(as_bathy(xyz[, c("lon", "lat")]), "requires a 3-column table")
  expect_error(as_xyz(1), "class bathy, or a data.frame or tibble")
  expect_error(as_xyz(xyz[, c("lon", "lat")]), "must contain columns")
  expect_error(as_xyz(xyz, lon = c("lon", "x")), "column names")
  expect_error(as_xyz(xyz, lon = NA_character_), "column names")
  expect_error(as_xyz(xyz, names = c("x", "y")), "length 3")
  expect_error(as_xyz(xyz, names = c("x", NA, "z")), "length 3")
})
