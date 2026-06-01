make_spatial_grid <- function() {
  xyz <- expand.grid(
    lon = c(-5, -4, -3),
    lat = c(48, 49, 50)
  )
  xyz <- xyz[order(xyz$lon, xyz$lat), ]
  xyz$depth <- seq_len(nrow(xyz))
  rownames(xyz) <- NULL
  xyz
}

test_that("as_sf() converts data.frames, tibbles, and bathy objects", {
  testthat::skip_if_not_installed("sf")
  xyz <- make_spatial_grid()
  tbl <- tibble::as_tibble(xyz)
  bathy <- tbl_to_bathy(xyz)

  sf_df <- as_sf(xyz)
  sf_tbl <- as_sf(tbl)
  sf_bathy <- as_sf(bathy)

  expect_s3_class(sf_df, "sf")
  expect_s3_class(sf_tbl, "sf")
  expect_s3_class(sf_bathy, "sf")
  expect_equal(nrow(sf_df), nrow(xyz))
  expect_equal(nrow(sf_tbl), nrow(xyz))
  expect_equal(nrow(sf_bathy), nrow(xyz))
  expect_true(all(sf::st_geometry_type(sf_df) == "POINT"))
})

test_that("as_sf() accepts numeric and string CRS definitions", {
  testthat::skip_if_not_installed("sf")
  xyz <- make_spatial_grid()

  epsg <- as_sf(xyz, crs = 4326)
  string <- as_sf(xyz, crs = "EPSG:4326")

  expect_equal(sf::st_crs(epsg)$epsg, 4326)
  expect_equal(sf::st_crs(string)$epsg, 4326)
})

test_that("as_sf() supports remove = FALSE and remove = TRUE", {
  testthat::skip_if_not_installed("sf")
  xyz <- make_spatial_grid()

  keep <- as_sf(xyz, remove = FALSE)
  drop <- as_sf(xyz, remove = TRUE)

  expect_true(all(c("lon", "lat", "depth", "geometry") %in% names(keep)))
  expect_false("lon" %in% names(drop))
  expect_false("lat" %in% names(drop))
  expect_true("depth" %in% names(drop))
  expect_true("geometry" %in% names(drop))
})

test_that("as_sf() reports invalid inputs", {
  testthat::skip_if_not_installed("sf")
  xyz <- make_spatial_grid()

  expect_error(as_sf(1), "class 'bathy'")
  expect_error(as_sf(xyz[, c("lon", "depth")]), "lon and lat")
  expect_error(as_sf(transform(xyz, lon = as.character(lon))), "must be numeric")
  expect_error(as_sf(xyz, lon = c("lon", "x")), "column names")
})

test_that("as_spatraster() converts data.frames, tibbles, and bathy objects", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()
  tbl <- tibble::as_tibble(xyz)
  bathy <- tbl_to_bathy(xyz)

  r_df <- as_spatraster(xyz)
  r_tbl <- as_spatraster(tbl)
  r_bathy <- as_spatraster(bathy)

  expect_s4_class(r_df, "SpatRaster")
  expect_s4_class(r_tbl, "SpatRaster")
  expect_s4_class(r_bathy, "SpatRaster")
  expect_equal(dim(r_df)[1:2], c(3L, 3L))
  expect_equal(dim(r_tbl)[1:2], c(3L, 3L))
  expect_equal(dim(r_bathy)[1:2], c(3L, 3L))
})

test_that("as_spatraster() accepts numeric and string CRS definitions", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()

  epsg <- as_spatraster(xyz, crs = 4326)
  string <- as_spatraster(xyz, crs = "EPSG:4326")

  expect_match(terra::crs(epsg), "EPSG\",4326", fixed = TRUE)
  expect_match(terra::crs(string), "EPSG\",4326", fixed = TRUE)
})

test_that("as_spatraster() reports invalid inputs", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()
  irregular <- data.frame(
    lon = c(0, 1, 3),
    lat = c(0, 0, 0),
    depth = c(-1, -2, -3)
  )

  expect_error(as_spatraster(1), "data.frame/tibble")
  expect_error(as_spatraster(xyz[, c("lon", "lat")]), "lon, lat, and depth")
  expect_error(as_spatraster(transform(xyz, depth = as.character(depth))), "must be numeric")
  expect_error(as_spatraster(irregular), "raster geometry|SpatRaster|rast")
  expect_error(as_spatraster(xyz, crs = 4326.5), "whole-number EPSG")
  expect_error(as_spatraster(xyz, crs = NA_character_), "CRS string")
})

test_that("project_bathy() projects to numeric and string CRS definitions", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()

  epsg <- project_bathy(xyz, crs_to = 3857, method = "near")
  string <- project_bathy(xyz, crs_to = "EPSG:3857", method = "near")

  expect_s3_class(epsg, "projected_bathy")
  expect_s3_class(epsg, "tbl_df")
  expect_named(epsg, c("lon", "lat", "depth"))
  expect_named(string, c("lon", "lat", "depth"))
  expect_match(attr(epsg, "crs_to"), "EPSG\",3857", fixed = TRUE)
  expect_match(attr(string, "crs_to"), "EPSG\",3857", fixed = TRUE)
})

test_that("project_bathy() preserves bathy input class", {
  testthat::skip_if_not_installed("terra")
  bathy <- tbl_to_bathy(make_spatial_grid())

  out <- project_bathy(bathy, crs_to = 3857, method = "near")

  expect_s3_class(out, "projected_bathy")
  expect_s3_class(out, "bathy")
  expect_true(is.matrix(out))
  expect_s4_class(attr(out, "spatraster"), "SpatRaster")
  expect_match(attr(out, "crs_to"), "EPSG\",3857", fixed = TRUE)
})

test_that("project_bathy() supports bilinear and near methods", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()

  bilinear <- project_bathy(xyz, crs_to = 3857, method = "bilinear")
  near <- project_bathy(xyz, crs_to = 3857, method = "near")

  expect_s3_class(bilinear, "projected_bathy")
  expect_s3_class(near, "projected_bathy")
  expect_named(bilinear, c("lon", "lat", "depth"))
  expect_named(near, c("lon", "lat", "depth"))
})

test_that("project_bathy() stores CRS and SpatRaster attributes", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()

  out <- project_bathy(xyz, crs_to = 3857, crs_from = 4326, method = "near")

  expect_match(attr(out, "crs_from"), "EPSG\",4326", fixed = TRUE)
  expect_match(attr(out, "crs_to"), "EPSG\",3857", fixed = TRUE)
  expect_s4_class(attr(out, "spatraster"), "SpatRaster")
})

test_that("project_bathy() supports explicit output resolution", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()

  out <- project_bathy(xyz, crs_to = 3857, resolution = 100000, method = "near")

  expect_s3_class(out, "projected_bathy")
  expect_equal(terra::res(attr(out, "spatraster")), c(100000, 100000))
})

test_that("project_bathy() reports invalid inputs", {
  testthat::skip_if_not_installed("terra")
  xyz <- make_spatial_grid()

  expect_error(project_bathy(xyz), "crs_to must be supplied")
  expect_error(project_bathy(xyz, crs_to = 3857, crs_from = 4326.5), "whole-number EPSG")
  expect_error(project_bathy(xyz, crs_to = 3857, resolution = 0), "positive numeric")
  expect_error(project_bathy(xyz, crs_to = 3857, names = c("x", "y")), "length 3")
  expect_error(project_bathy(xyz, crs_to = 3857, na.rm = NA), "TRUE or FALSE")
})
