make_noaa_erddap_bathy <- function(lon = c(-5, -4), lat = c(48, 49), offset = 0) {
  xyz <- expand.grid(lon = lon, lat = lat)
  xyz$depth <- seq_len(nrow(xyz)) + offset
  as_bathy(xyz)
}

with_fake_noaa_erddap_fetcher <- function(fetcher, code) {
  old <- getOption("marmap2.noaa_erddap_fetcher")
  options(marmap2.noaa_erddap_fetcher = fetcher)
  on.exit(options(marmap2.noaa_erddap_fetcher = old), add = TRUE)
  force(code)
}

test_that("NOAA ERDDAP helpers validate, sort, and compute stride", {
  request <- noaa_erddap_request_args(
    lon = c(10, -10),
    lat = c(45, 35),
    resolution = 1,
    path = tempdir(),
    timeout = 120,
    connect_timeout = 30,
    base_url = "https://example.test/erddap/griddap"
  )

  expect_equal(request$x1, -10)
  expect_equal(request$x2, 10)
  expect_equal(request$y1, 35)
  expect_equal(request$y2, 45)
  expect_equal(request$stride, 4L)
  expect_equal(request$effective_resolution, 1)
  expect_equal(request$timeout, 120)
  expect_equal(request$connect_timeout, 30)
  expect_equal(request$base_url, "https://example.test/erddap/griddap")
})

test_that("NOAA ERDDAP helpers report invalid arguments", {
  expect_error(noaa_erddap_request_args(lon = c(-5, -5), lat = c(48, 49)), "longitudinal range")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 48)), "latitudinal range")
  expect_error(noaa_erddap_request_args(lon = c(-181, -4), lat = c(48, 49)), "Longitudes")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(-91, 49)), "Latitudes")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), resolution = 0), "positive")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), antimeridian = NA), "TRUE or FALSE")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), progress = NA), "TRUE or FALSE")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), timeout = 0), "positive")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), connect_timeout = 0), "positive")
  expect_error(noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), base_url = NA_character_), "base_url")
})

test_that("NOAA ERDDAP helpers build cache names and URLs", {
  request <- noaa_erddap_request_args(
    lon = c(10, -10),
    lat = c(45, 35),
    resolution = 1,
    antimeridian = TRUE,
    path = tempdir()
  )
  url <- noaa_erddap_url(
    left = -5,
    right = 5,
    bottom = 40,
    top = 45,
    stride = 4
  )

  expect_equal(
    noaa_erddap_cache_name(request),
    "marmap_noaa_erddap_coord_-10;35;10;45_res_1_anti.csv"
  )
  expect_match(url, "ETOPO_2022_v1_15s.nc?z", fixed = TRUE)
  expect_match(url, "%5B(40):4:(45)%5D", fixed = TRUE)
  expect_match(url, "%5B(-5):4:(5)%5D", fixed = TRUE)
  expect_error(noaa_erddap_url(5, -5, 40, 45), "left < right")
  expect_error(noaa_erddap_url(-5, 5, 40, 45, stride = 1.5), "whole number")
})

test_that("NOAA ERDDAP helpers compute antimeridian windows", {
  request <- noaa_erddap_request_args(
    lon = c(170, -170),
    lat = c(45, 55),
    resolution = 5,
    antimeridian = TRUE,
    path = tempdir()
  )
  windows <- noaa_erddap_request_windows(request)

  expect_named(windows, c("east", "west"))
  expect_equal(windows$east, list(left = 170, right = 180, bottom = 45, top = 55))
  expect_equal(windows$west, list(left = -180, right = -170, bottom = 45, top = 55))
})

test_that("NOAA ERDDAP NetCDF reader converts a small latitude/longitude/z fixture", {
  testthat::skip_if_not_installed("ncdf4")
  nc_file <- tempfile(fileext = ".nc")
  lon <- c(-5, -4, -3)
  lat <- c(48, 49)
  lon_dim <- ncdf4::ncdim_def("longitude", "degrees_east", lon)
  lat_dim <- ncdf4::ncdim_def("latitude", "degrees_north", lat)
  z_var <- ncdf4::ncvar_def("z", "m", list(lat_dim, lon_dim), -9999)
  nc <- ncdf4::nc_create(nc_file, z_var)
  ncdf4::ncvar_put(
    nc,
    z_var,
    matrix(c(-10, -20, -30, -40, -50, -60), nrow = 2, ncol = 3)
  )
  ncdf4::nc_close(nc)

  bathy <- noaa_erddap_read_netcdf(nc_file)

  expect_s3_class(bathy, "bathy")
  expect_equal(as.numeric(rownames(bathy)), lon)
  expect_equal(as.numeric(colnames(bathy)), lat)
  expect_equal(unclass(bathy)[1, 1], -10)
  expect_equal(unclass(bathy)[3, 2], -60)
})

test_that("get_noaa_erddap() uses cached csv files without fetching", {
  tmp <- tempdir()
  request <- noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp)
  bathy <- make_noaa_erddap_bathy()
  utils::write.table(
    as_xyz(bathy),
    file = noaa_erddap_cache_file(tmp, request),
    sep = ",",
    quote = FALSE,
    row.names = FALSE
  )

  with_fake_noaa_erddap_fetcher(
    function(...) stop("network should not be called"),
    {
      out_tbl <- suppressMessages(get_noaa_erddap(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp))
      out_bathy <- suppressMessages(get_noaa_erddap(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp, class = "bathy"))
    }
  )

  expect_s3_class(out_tbl, "tbl_df")
  expect_s3_class(out_bathy, "bathy")
  expect_equal(nrow(out_tbl), 4L)
})

test_that("get_noaa_erddap() supports keep = TRUE with a fake fetcher", {
  tmp <- tempdir()
  request <- noaa_erddap_request_args(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp)
  csv_file <- noaa_erddap_cache_file(tmp, request)
  if (file.exists(csv_file)) {
    unlink(csv_file)
  }

  with_fake_noaa_erddap_fetcher(
    function(left, right, bottom, top, stride, progress, timeout, connect_timeout, base_url) {
      make_noaa_erddap_bathy(lon = c(left, right), lat = c(bottom, top))
    },
    {
      out <- get_noaa_erddap(lon = c(-5, -4), lat = c(48, 49), resolution = 1, keep = TRUE, path = tmp)
    }
  )

  expect_s3_class(out, "tbl_df")
  expect_true(file.exists(csv_file))
  expect_s3_class(read_bathy(csv_file, header = TRUE), "bathy")
})

test_that("get_noaa_erddap() handles antimeridian requests without network", {
  calls <- list()
  fake_fetcher <- function(left, right, bottom, top, stride, progress, timeout, connect_timeout, base_url) {
    calls[[length(calls) + 1L]] <<- list(
      left = left,
      right = right,
      bottom = bottom,
      top = top,
      stride = stride,
      timeout = timeout,
      connect_timeout = connect_timeout,
      base_url = base_url
    )
    make_noaa_erddap_bathy(lon = c(left, right), lat = c(bottom, top), offset = length(calls) * 10)
  }

  with_fake_noaa_erddap_fetcher(
    fake_fetcher,
    {
      out <- suppressMessages(get_noaa_erddap(
        lon = c(170, -170),
        lat = c(55, 45),
        resolution = 5,
        antimeridian = TRUE,
        path = tempdir(),
        timeout = 120,
        connect_timeout = 30,
        base_url = "https://example.test/erddap/griddap",
        class = "bathy"
      ))
    }
  )

  expect_s3_class(out, "bathy")
  expect_equal(calls[[1]], list(
    left = 170,
    right = 180,
    bottom = 45,
    top = 55,
    stride = 20L,
    timeout = 120,
    connect_timeout = 30,
    base_url = "https://example.test/erddap/griddap"
  ))
  expect_equal(calls[[2]], list(
    left = -180,
    right = -170,
    bottom = 45,
    top = 55,
    stride = 20L,
    timeout = 120,
    connect_timeout = 30,
    base_url = "https://example.test/erddap/griddap"
  ))
  expect_equal(as.numeric(rownames(out)), c(170, 180, 190))
})
