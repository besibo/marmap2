make_noaa_bathy <- function(lon = c(-5, -4), lat = c(48, 49), offset = 0) {
  xyz <- expand.grid(lon = lon, lat = lat)
  xyz$depth <- seq_len(nrow(xyz)) + offset
  as_bathy(xyz)
}

with_fake_noaa_fetcher <- function(fetcher, code) {
  old <- getOption("marmap2.noaa_fetcher")
  options(marmap2.noaa_fetcher = fetcher)
  on.exit(options(marmap2.noaa_fetcher = old), add = TRUE)
  force(code)
}

test_that("NOAA helpers validate, sort, and select ETOPO layers", {
  request <- noaa_request_args(
    lon = c(10, -10),
    lat = c(45, 35),
    resolution = 0.4,
    path = tempdir(),
    progress = FALSE
  )

  expect_equal(request$x1, -10)
  expect_equal(request$x2, 10)
  expect_equal(request$y1, 35)
  expect_equal(request$y2, 45)
  expect_equal(request$resolution, 0.25)
  expect_equal(request$layer, "ETOPO_2022_v1_15s_bed_elev")
  expect_false(request$progress)

  expect_equal(noaa_layer_name(0.5), "ETOPO_2022_v1_30s_bed")
  expect_equal(noaa_layer_name(2), "ETOPO_2022_v1_60s_bed")
})

test_that("NOAA helpers report invalid arguments", {
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(48, 49), lon1 = -5), "either lon")
  expect_error(noaa_request_args(lon = c(-5, -5), lat = c(48, 49)), "longitudinal range")
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(48, 48)), "latitudinal range")
  expect_error(noaa_request_args(lon = c(-181, -4), lat = c(48, 49)), "Longitudes")
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(-91, 49)), "Latitudes")
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(48, 49), resolution = 0), "positive")
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(48, 49), antimeridian = NA), "TRUE or FALSE")
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(48, 49), progress = NA), "TRUE or FALSE")
  expect_error(noaa_request_args(lon = c(-5, -4), lat = c(48, 49), path = tempfile()), "path")
})

test_that("NOAA helpers build cache names and Grid Extract URLs", {
  request <- noaa_request_args(
    lon = c(10, -10),
    lat = c(45, 35),
    resolution = 5,
    antimeridian = TRUE,
    path = tempdir()
  )
  url <- noaa_export_image_url(
    left = -5,
    right = 5,
    bottom = 40,
    top = 45,
    ncol = 300,
    nrow = 150,
    layer = "ETOPO_2022_v1_60s_bed"
  )

  expect_equal(
    noaa_cache_name(request),
    "marmap_coord_-10;35;10;45_res_5_anti.csv"
  )
  expect_match(url, "ImageServer/exportImage", fixed = TRUE)
  expect_match(url, "bbox=-5,40,5,45", fixed = TRUE)
  expect_match(url, "size=300,150", fixed = TRUE)
  expect_match(url, "ETOPO_2022_v1_60s_bed", fixed = TRUE)
})

test_that("NOAA helpers compute request windows", {
  request <- noaa_request_args(
    lon = c(170, -170),
    lat = c(55, 45),
    resolution = 5,
    antimeridian = TRUE,
    path = tempdir()
  )
  windows <- noaa_request_windows(request)

  expect_named(windows, c("east", "west"))
  expect_equal(windows$east$left, 170)
  expect_equal(windows$east$right, 180)
  expect_equal(windows$west$left, -180)
  expect_equal(windows$west$right, -170)
  expect_equal(windows$east$ncol, 120)
  expect_equal(windows$east$nrow, 120)
})

test_that("NOAA helpers split large windows into latitude chunks", {
  window <- list(
    left = -5,
    right = 5,
    bottom = 40,
    top = 50,
    ncol = 1000L,
    nrow = 1000L
  )

  chunks <- noaa_window_chunks(window, max_cells = 250000)

  expect_true(length(chunks) > 1)
  expect_equal(sum(vapply(chunks, `[[`, numeric(1), "nrow")), window$nrow)
  expect_equal(chunks[[1]]$bottom, 40)
  expect_equal(chunks[[length(chunks)]]$top, 50)
  expect_true(all(vapply(chunks, noaa_window_cells, numeric(1)) <= 250000))
})

test_that("NOAA helpers preserve bathy class after combining chunks", {
  chunks <- list(
    make_noaa_bathy(lon = c(-5, -4), lat = c(48, 49)),
    make_noaa_bathy(lon = c(-5, -4), lat = c(50, 51), offset = 10)
  )

  out <- noaa_combine_latitude_chunks(chunks)

  expect_s3_class(out, "bathy")
  expect_equal(as.numeric(rownames(out)), c(-5, -4))
  expect_equal(as.numeric(colnames(out)), c(48, 49, 50, 51))
})

test_that("get_noaa() returns a tibble after multi-chunk downloads", {
  calls <- 0
  fake_fetcher <- function(left, right, bottom, top, ncol, nrow, layer) {
    calls <<- calls + 1L
    lat <- seq(bottom, top, length.out = nrow)
    lon <- seq(left, right, length.out = ncol)
    make_noaa_bathy(lon = lon, lat = lat, offset = calls * 10)
  }

  with_fake_noaa_fetcher(
    fake_fetcher,
    {
      out <- suppressMessages(get_noaa(
        lon = c(-5, -4),
        lat = c(40, 50),
        resolution = 0.25,
        progress = FALSE
      ))
    }
  )

  expect_true(calls > 1)
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("lon", "lat", "depth"))
})

test_that("get_noaa() uses cached csv files without fetching", {
  tmp <- tempdir()
  request <- noaa_request_args(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp)
  bathy <- make_noaa_bathy()
  utils::write.table(
    as_xyz(bathy),
    file = noaa_cache_file(tmp, request),
    sep = ",",
    quote = FALSE,
    row.names = FALSE
  )

  with_fake_noaa_fetcher(
    function(...) stop("network should not be called"),
    {
      out_tbl <- suppressMessages(get_noaa(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp))
      out_bathy <- suppressMessages(get_noaa(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp, class = "bathy"))
    }
  )

  expect_s3_class(out_tbl, "tbl_df")
  expect_s3_class(out_bathy, "bathy")
  expect_equal(nrow(out_tbl), 4L)
})

test_that("get_noaa() supports keep = TRUE with a fake fetcher", {
  tmp <- tempdir()
  request <- noaa_request_args(lon = c(-5, -4), lat = c(48, 49), resolution = 1, path = tmp)
  csv_file <- noaa_cache_file(tmp, request)
  if (file.exists(csv_file)) {
    unlink(csv_file)
  }

  with_fake_noaa_fetcher(
    function(left, right, bottom, top, ncol, nrow, layer) {
      make_noaa_bathy(lon = c(left, right), lat = c(bottom, top))
    },
    {
      out <- get_noaa(lon = c(-5, -4), lat = c(48, 49), resolution = 1, keep = TRUE, path = tmp, progress = FALSE)
    }
  )

  expect_s3_class(out, "tbl_df")
  expect_true(file.exists(csv_file))
  expect_s3_class(read_bathy(csv_file, header = TRUE), "bathy")
})

test_that("get_noaa() handles antimeridian requests without network", {
  calls <- list()
  fake_fetcher <- function(left, right, bottom, top, ncol, nrow, layer) {
    calls[[length(calls) + 1L]] <<- list(
      left = left,
      right = right,
      bottom = bottom,
      top = top,
      ncol = ncol,
      nrow = nrow,
      layer = layer
    )
    make_noaa_bathy(lon = c(left, right), lat = c(bottom, top), offset = length(calls) * 10)
  }

  with_fake_noaa_fetcher(
    fake_fetcher,
    {
      out <- suppressMessages(get_noaa(
        lon = c(170, -170),
        lat = c(55, 45),
        resolution = 5,
        antimeridian = TRUE,
        path = tempdir(),
        progress = FALSE,
        class = "bathy"
      ))
    }
  )

  expect_s3_class(out, "bathy")
  expect_equal(calls[[1]]$left, 170)
  expect_equal(calls[[1]]$right, 180)
  expect_equal(calls[[2]]$left, -180)
  expect_equal(calls[[2]]$right, -170)
  expect_equal(as.numeric(rownames(out)), c(170, 180, 190))
})
