make_gebco_bathy <- function(lon = c(-5, -4), lat = c(48, 49), offset = 0) {
  xyz <- expand.grid(lon = lon, lat = lat)
  xyz$depth <- seq_len(nrow(xyz)) + offset
  as_bathy(xyz)
}

with_fake_gebco_fetcher <- function(fetcher, code) {
  old <- getOption("marmap2.gebco_fetcher")
  options(marmap2.gebco_fetcher = fetcher)
  on.exit(options(marmap2.gebco_fetcher = old), add = TRUE)
  force(code)
}

test_that("GEBCO helpers validate and sort coordinate arguments", {
  request <- gebco_request_args(
    lon = c(10, -10),
    lat = c(45, 35),
    path = tempdir()
  )

  expect_equal(request$x1, -10)
  expect_equal(request$x2, 10)
  expect_equal(request$y1, 35)
  expect_equal(request$y2, 45)
  expect_false(request$antimeridian)
})

test_that("GEBCO helpers report invalid coordinate arguments", {
  expect_error(gebco_request_args(lon = c(-5, -4), lat = c(48, 49), lon1 = -5), "either lon")
  expect_error(gebco_request_args(lon = c(-5, -5), lat = c(48, 49)), "longitudinal range")
  expect_error(gebco_request_args(lon = c(-5, -4), lat = c(48, 48)), "latitudinal range")
  expect_error(gebco_request_args(lon = c(-181, -4), lat = c(48, 49)), "Longitudes")
  expect_error(gebco_request_args(lon = c(-5, -4), lat = c(-91, 49)), "Latitudes")
  expect_error(gebco_request_args(lon = c(-5, -4), lat = c(48, 49), antimeridian = NA), "TRUE or FALSE")
  expect_error(gebco_request_args(lon = c(-5, -4), lat = c(48, 49), path = tempfile()), "path does not exist")
})

test_that("GEBCO helpers build cache names and queue JSON", {
  request <- gebco_request_args(
    lon = c(10, -10),
    lat = c(45, 35),
    antimeridian = TRUE,
    path = tempdir()
  )
  body <- gebco_queue_body(
    left = -10,
    right = 10,
    bottom = 35,
    top = 45,
    submission_date = "2026-05-29T00:00:00"
  )

  expect_equal(
    gebco_cache_name(request),
    "marmap_gebco_coord_-10;35;10;45_anti.csv"
  )
  expect_false(grepl('"basketId"', body, fixed = TRUE))
  expect_match(body, '"grid_id":1', fixed = TRUE)
  expect_match(body, '"left":-10', fixed = TRUE)
  expect_match(body, '"right":10', fixed = TRUE)
  expect_match(body, '"top":45', fixed = TRUE)
  expect_match(body, '"bottom":35', fixed = TRUE)
  expect_error(gebco_queue_body(10, -10, 35, 45), "left < right")
})

test_that("GEBCO helpers extract JSON values", {
  json <- '{"basketId":"abc123","status":"finished"}'

  expect_equal(gebco_extract_json_value(json, "basketId"), "abc123")
  expect_equal(gebco_extract_json_value(json, "status"), "finished")
  expect_true(is.na(gebco_extract_json_value(json, "missing")))
})

test_that("GEBCO helpers compute antimeridian windows", {
  request <- gebco_request_args(
    lon = c(170, -170),
    lat = c(45, 55),
    antimeridian = TRUE,
    path = tempdir()
  )
  windows <- gebco_request_windows(request)

  expect_named(windows, c("east", "west"))
  expect_equal(windows$east, list(left = 170, right = 180, bottom = 45, top = 55))
  expect_equal(windows$west, list(left = -180, right = -170, bottom = 45, top = 55))
})

test_that("GEBCO NetCDF reader converts a small lat/lon/elevation fixture", {
  testthat::skip_if_not_installed("ncdf4")
  nc_file <- tempfile(fileext = ".nc")
  lon <- c(-5, -4, -3)
  lat <- c(48, 49)
  lon_dim <- ncdf4::ncdim_def("lon", "degrees_east", lon)
  lat_dim <- ncdf4::ncdim_def("lat", "degrees_north", lat)
  elev_var <- ncdf4::ncvar_def("elevation", "m", list(lat_dim, lon_dim), -9999)
  nc <- ncdf4::nc_create(nc_file, elev_var)
  ncdf4::ncvar_put(
    nc,
    elev_var,
    matrix(c(-10, -20, -30, -40, -50, -60), nrow = 2, ncol = 3)
  )
  ncdf4::nc_close(nc)

  bathy <- gebco_read_netcdf(nc_file)

  expect_s3_class(bathy, "bathy")
  expect_equal(as.numeric(rownames(bathy)), lon)
  expect_equal(as.numeric(colnames(bathy)), lat)
  expect_equal(unclass(bathy)[1, 1], -10)
  expect_equal(unclass(bathy)[3, 2], -60)
})

test_that("get_gebco() uses cached csv files without fetching", {
  tmp <- tempdir()
  request <- gebco_request_args(lon = c(-5, -4), lat = c(48, 49), path = tmp)
  bathy <- make_gebco_bathy()
  utils::write.table(
    as_xyz(bathy),
    file = gebco_cache_file(tmp, request),
    sep = ",",
    quote = FALSE,
    row.names = FALSE
  )

  with_fake_gebco_fetcher(
    function(...) stop("network should not be called"),
    {
      out_tbl <- suppressMessages(get_gebco(lon = c(-5, -4), lat = c(48, 49), path = tmp))
      out_bathy <- suppressMessages(get_gebco(lon = c(-5, -4), lat = c(48, 49), path = tmp, class = "bathy"))
    }
  )

  expect_s3_class(out_tbl, "tbl_df")
  expect_s3_class(out_bathy, "bathy")
  expect_equal(nrow(out_tbl), 4L)
})

test_that("get_gebco() supports keep = TRUE with a fake fetcher", {
  tmp <- tempdir()
  request <- gebco_request_args(lon = c(-5, -4), lat = c(48, 49), path = tmp)
  csv_file <- gebco_cache_file(tmp, request)
  if (file.exists(csv_file)) {
    unlink(csv_file)
  }

  with_fake_gebco_fetcher(
    function(left, right, bottom, top, ...) {
      make_gebco_bathy(lon = c(left, right), lat = c(bottom, top))
    },
    {
      out <- get_gebco(lon = c(-5, -4), lat = c(48, 49), keep = TRUE, path = tmp)
    }
  )

  expect_s3_class(out, "tbl_df")
  expect_true(file.exists(csv_file))
  expect_s3_class(read_bathy(csv_file, header = TRUE), "bathy")
})

test_that("get_gebco() handles antimeridian requests without network", {
  calls <- list()
  fake_fetcher <- function(left, right, bottom, top, ...) {
    calls[[length(calls) + 1L]] <<- list(left = left, right = right, bottom = bottom, top = top)
    make_gebco_bathy(lon = c(left, right), lat = c(bottom, top), offset = length(calls) * 10)
  }

  with_fake_gebco_fetcher(
    fake_fetcher,
    {
      out <- suppressMessages(get_gebco(
        lon = c(170, -170),
        lat = c(55, 45),
        antimeridian = TRUE,
        path = tempdir(),
        class = "bathy"
      ))
    }
  )

  expect_s3_class(out, "bathy")
  expect_equal(calls[[1]], list(left = 170, right = 180, bottom = 45, top = 55))
  expect_equal(calls[[2]], list(left = -180, right = -170, bottom = 45, top = 55))
  expect_equal(as.numeric(rownames(out)), c(170, 180, 190))
})

test_that("get_gebco() no longer exposes resolution reduction", {
  expect_false("resolution" %in% names(formals(get_gebco)))
})
