#' Download bathymetry from NOAA ETOPO 2022 through ERDDAP
#'
#' @description
#' Experimental ERDDAP-based downloader for NOAA ETOPO 2022 bathymetry. It uses
#' the ERDDAP `griddap` endpoint, which can return NetCDF subsets directly and
#' can reduce download size by requesting one native grid point every `stride`
#' cells.
#'
#' @details
#' ETOPO 2022 is exposed by NOAA ERDDAP at a native resolution of 15 arc-seconds,
#' i.e. 0.25 arc-minutes. The `resolution` argument is converted to an ERDDAP
#' stride using:
#'
#' \preformatted{
#' stride = round(resolution / 0.25)
#' }
#'
#' The effective downloaded resolution is therefore `stride * 0.25`
#' arc-minutes. This is server-side sub-sampling, not local aggregation: ERDDAP
#' returns one native cell every `stride` cells. For local aggregation by mean or
#' median, download at the native resolution and use
#' \code{\link{reduce_bathy_resolution}} afterwards.
#'
#' This function is intentionally separate from \code{\link{get_noaa}} while the
#' ERDDAP workflow is being evaluated.
#'
#' @param lon Numeric vector of length 2 giving the longitude bounds in decimal
#'   degrees. This is the recommended syntax.
#' @param lat Numeric vector of length 2 giving the latitude bounds in decimal
#'   degrees. This is the recommended syntax.
#' @param lon1,lon2,lat1,lat2 Explicit coordinate bounds, kept for compatibility
#'   with older calling styles.
#' @param resolution Requested grid resolution in arc-minutes. The value is
#'   converted to the nearest ERDDAP stride from the native 0.25 arc-minute
#'   grid.
#' @param antimeridian Logical. Whether the requested region crosses the
#'   antimeridian.
#' @param keep Logical. Whether to write the downloaded xyz table to disk.
#' @param path Directory used for cached csv files when \code{keep = TRUE}, and
#'   where cached files are searched before downloading.
#' @param progress Logical. If \code{TRUE}, show curl's download progress when
#'   the server provides enough information. If a precise progress bar is not
#'   possible, the function still reports the expected grid size.
#' @param timeout Timeout in seconds for the ERDDAP download request. Defaults
#'   to \code{300}.
#' @param connect_timeout Timeout in seconds for the initial connection to each
#'   ERDDAP server. Defaults to \code{60}.
#' @param base_url ERDDAP griddap endpoint(s). Defaults to NOAA OceanWatch and
#'   NOAA CoastWatch endpoints. If several endpoints are provided, they are
#'   tried in order until one succeeds.
#' @param class Character. Class of the returned object. Use \code{"tbl"}
#'   (default) to return a tibble with columns \code{lon}, \code{lat}, and
#'   \code{depth}; use \code{"bathy"} to return a historical matrix of class
#'   \code{bathy}.
#'
#' @return
#' A tibble by default, or an object of class \code{bathy} when
#' \code{class = "bathy"}.
#'
#' @seealso
#' \code{\link{get_noaa}}, \code{\link{reduce_bathy_resolution}},
#' \code{\link{read_bathy}}, \code{\link{geom_bathy}}
#'
#' @examples
#' \dontrun{
#' dat <- get_noaa_erddap(
#'   lon = c(-5, 5),
#'   lat = c(40, 45),
#'   resolution = 1
#' )
#' }
#' @export
get_noaa_erddap <- function(
    lon = NULL,
    lat = NULL,
    lon1 = NULL,
    lon2 = NULL,
    lat1 = NULL,
    lat2 = NULL,
    resolution = 4,
    antimeridian = FALSE,
    keep = FALSE,
    path = NULL,
    progress = TRUE,
    timeout = 300,
    connect_timeout = 60,
    base_url = noaa_erddap_default_base_urls(),
    class = c("tbl", "bathy")
) {
  output_class <- match.arg(class)
  request <- noaa_erddap_request_args(
    lon = lon,
    lat = lat,
    lon1 = lon1,
    lon2 = lon2,
    lat1 = lat1,
    lat2 = lat2,
    resolution = resolution,
    antimeridian = antimeridian,
    path = path,
    progress = progress,
    timeout = timeout,
    connect_timeout = connect_timeout,
    base_url = base_url
  )

  if (!requireNamespace("ncdf4", quietly = TRUE)) {
    stop("Package 'ncdf4' is required.", call. = FALSE)
  }
  if (!requireNamespace("curl", quietly = TRUE)) {
    stop("Package 'curl' is required.", call. = FALSE)
  }

  file <- noaa_erddap_cache_name(request)
  csv_file <- noaa_erddap_cache_file(request$path, request)
  if (file.exists(csv_file)) {
    message("File already exists; loading '", file, "'")
    existing_bathy <- read_bathy(csv_file, header = TRUE)
    if (identical(output_class, "tbl")) {
      return(bathy_to_tbl(existing_bathy))
    }
    return(existing_bathy)
  }

  fetcher <- getOption("marmap2.noaa_erddap_fetcher", noaa_erddap_fetch_bbox)
  windows <- noaa_erddap_request_windows(request)

  if (request$antimeridian) {
    message("Downloading NOAA ERDDAP data across the antimeridian ...")
    pieces <- lapply(windows, function(window) {
      do.call(fetcher, c(window, list(
        stride = request$stride,
        progress = request$progress,
        timeout = request$timeout,
        connect_timeout = request$connect_timeout,
        base_url = request$base_url
      )))
    })
    names(pieces) <- names(windows)
    bathy <- if (!is.null(pieces$east) && !is.null(pieces$west)) {
      collate_antimeridian_bathy(pieces$east, pieces$west)
    } else if (!is.null(pieces$east)) {
      pieces$east
    } else if (!is.null(pieces$west)) {
      pieces$west
    } else {
      stop("The antimeridian request has no longitudinal extent.", call. = FALSE)
    }
  } else {
    bathy <- do.call(fetcher, c(windows[[1]], list(
      stride = request$stride,
      progress = request$progress,
      timeout = request$timeout,
      connect_timeout = request$connect_timeout,
      base_url = request$base_url
    )))
  }

  if (keep) {
    utils::write.table(
      as_xyz(bathy),
      file = csv_file,
      sep = ",",
      quote = FALSE,
      row.names = FALSE
    )
  }

  if (identical(output_class, "tbl")) {
    return(bathy_to_tbl(bathy))
  }
  bathy
}

noaa_erddap_request_args <- function(
    lon = NULL,
    lat = NULL,
    lon1 = NULL,
    lon2 = NULL,
    lat1 = NULL,
    lat2 = NULL,
    resolution = 4,
    antimeridian = FALSE,
    path = NULL,
    progress = TRUE,
    timeout = 300,
    connect_timeout = 60,
    base_url = noaa_erddap_default_base_urls()
) {
  bounds <- resolve_lon_lat_args(lon1, lon2, lat1, lat2, lon, lat)
  lon1 <- bounds$lon1
  lon2 <- bounds$lon2
  lat1 <- bounds$lat1
  lat2 <- bounds$lat2

  if (!is.numeric(c(lon1, lon2, lat1, lat2))) {
    stop("Coordinates must be numeric.", call. = FALSE)
  }
  if (length(lon1) != 1 || length(lon2) != 1 || length(lat1) != 1 || length(lat2) != 1) {
    stop("lon1, lon2, lat1, and lat2 must be single numeric values.", call. = FALSE)
  }
  if (lon1 == lon2) {
    stop("The longitudinal range defined by lon1 and lon2 is incorrect.", call. = FALSE)
  }
  if (lat1 == lat2) {
    stop("The latitudinal range defined by lat1 and lat2 is incorrect.", call. = FALSE)
  }
  if (lat1 < -90 || lat1 > 90 || lat2 < -90 || lat2 > 90) {
    stop("Latitudes should have values between -90 and +90.", call. = FALSE)
  }
  if (lon1 < -180 || lon1 > 180 || lon2 < -180 || lon2 > 180) {
    stop("Longitudes should have values between -180 and +180.", call. = FALSE)
  }
  if (!is.numeric(resolution) || length(resolution) != 1 ||
      is.na(resolution) || !is.finite(resolution) || resolution <= 0) {
    stop("resolution must be a single positive numeric value.", call. = FALSE)
  }
  if (!is.logical(antimeridian) || length(antimeridian) != 1 || is.na(antimeridian)) {
    stop("antimeridian must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.logical(progress) || length(progress) != 1 || is.na(progress)) {
    stop("progress must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.numeric(timeout) || length(timeout) != 1 ||
      is.na(timeout) || !is.finite(timeout) || timeout <= 0) {
    stop("timeout must be a single positive numeric value.", call. = FALSE)
  }
  if (!is.numeric(connect_timeout) || length(connect_timeout) != 1 ||
      is.na(connect_timeout) || !is.finite(connect_timeout) || connect_timeout <= 0) {
    stop("connect_timeout must be a single positive numeric value.", call. = FALSE)
  }
  if (!is.character(base_url) || length(base_url) < 1 ||
      anyNA(base_url) || any(!nzchar(base_url))) {
    stop("base_url must be a non-empty character vector.", call. = FALSE)
  }
  if (is.null(path)) {
    path <- "."
  }
  if (!dir.exists(path)) {
    stop("path does not exist.", call. = FALSE)
  }

  native_resolution <- 0.25
  stride <- max(1L, as.integer(round(resolution / native_resolution)))
  effective_resolution <- stride * native_resolution

  list(
    lon1 = lon1,
    lon2 = lon2,
    lat1 = lat1,
    lat2 = lat2,
    x1 = min(lon1, lon2),
    x2 = max(lon1, lon2),
    y1 = min(lat1, lat2),
    y2 = max(lat1, lat2),
    resolution = resolution,
    stride = stride,
    effective_resolution = effective_resolution,
    antimeridian = antimeridian,
    path = path,
    progress = progress,
    timeout = timeout,
    connect_timeout = connect_timeout,
    base_url = base_url
  )
}

noaa_erddap_cache_name <- function(request) {
  paste0(
    "marmap_noaa_erddap_coord_",
    request$x1, ";", request$y1, ";", request$x2, ";", request$y2,
    "_res_", request$effective_resolution,
    if (request$antimeridian) "_anti" else "",
    ".csv"
  )
}

noaa_erddap_cache_file <- function(path, request) {
  file.path(path, noaa_erddap_cache_name(request))
}

noaa_erddap_request_windows <- function(request) {
  x1 <- request$x1
  x2 <- request$x2
  y1 <- request$y1
  y2 <- request$y2

  if (!request$antimeridian) {
    return(list(main = list(left = x1, right = x2, bottom = y1, top = y2)))
  }

  full_longitude_range <- x1 == -180 && x2 == 180
  if (full_longitude_range) {
    x1 <- 0
    x2 <- 0
  }

  windows <- list()
  if (x2 < 180) {
    windows$east <- list(left = x2, right = 180, bottom = y1, top = y2)
  }
  if (x1 > -180) {
    windows$west <- list(left = -180, right = x1, bottom = y1, top = y2)
  }
  windows
}

noaa_erddap_fmt <- function(x) {
  trimws(formatC(x, format = "fg", digits = 15))
}

noaa_erddap_url <- function(
    left,
    right,
    bottom,
    top,
    stride = 1,
    base_url = "https://coastwatch.pfeg.noaa.gov/erddap/griddap",
    dataset = "ETOPO_2022_v1_15s",
    variable = "z",
    file_type = "nc"
) {
  if (left >= right) {
    stop("Each NOAA ERDDAP subset must satisfy left < right.", call. = FALSE)
  }
  if (!is.numeric(stride) || length(stride) != 1 || is.na(stride) ||
      !is.finite(stride) || stride < 1 || stride != round(stride)) {
    stop("stride must be a positive whole number.", call. = FALSE)
  }

  base_url <- sub("/+$", "", base_url)
  query <- paste0(
    variable,
    "%5B(", noaa_erddap_fmt(bottom), "):", as.integer(stride), ":(", noaa_erddap_fmt(top), ")%5D",
    "%5B(", noaa_erddap_fmt(left), "):", as.integer(stride), ":(", noaa_erddap_fmt(right), ")%5D"
  )
  paste0(base_url, "/", dataset, ".", file_type, "?", query)
}

noaa_erddap_expected_cells <- function(left, right, bottom, top, stride) {
  native_degrees <- 0.25 / 60
  n_lon <- floor(((right - left) / native_degrees) / stride) + 1
  n_lat <- floor(((top - bottom) / native_degrees) / stride) + 1
  c(n_lon = max(0, n_lon), n_lat = max(0, n_lat))
}

noaa_erddap_fetch_bbox <- function(
    left,
    right,
    bottom,
    top,
    stride = 1,
    progress = TRUE,
    timeout = 300,
    connect_timeout = 60,
    base_url = noaa_erddap_default_base_urls()
) {
  expected <- noaa_erddap_expected_cells(left, right, bottom, top, stride)
  message(
    "Downloading NOAA ERDDAP NetCDF subset (",
    expected[["n_lon"]], " x ", expected[["n_lat"]], " cells) ..."
  )

  nc_file <- tempfile(fileext = ".nc")
  on.exit(unlink(nc_file), add = TRUE)
  download_error <- NULL
  for (endpoint in noaa_erddap_endpoint_specs(base_url)) {
    download_status <- try({
      pieces <- lapply(
        noaa_erddap_endpoint_windows(left, right, bottom, top, endpoint$lon360),
        function(window) {
          noaa_erddap_download_window(
            window = window,
            endpoint = endpoint,
            stride = stride,
            progress = progress,
            timeout = timeout,
            connect_timeout = connect_timeout
          )
        }
      )
      if (length(pieces) == 1) {
        pieces[[1]]
      } else {
        noaa_erddap_collate_lon360(pieces)
      }
    }, silent = TRUE)

    if (!inherits(download_status, "try-error")) {
      return(download_status)
    }
    download_error <- download_status
    message("NOAA ERDDAP endpoint failed: ", endpoint$base_url)
  }

  msg <- "The NOAA ERDDAP NetCDF file cannot be reached or is empty."
  if (!is.null(download_error)) {
    msg <- paste(msg, as.character(download_error))
  }
  stop(msg, call. = FALSE)
}

noaa_erddap_default_base_urls <- function() {
  c(
    "https://oceanwatch.pifsc.noaa.gov/erddap/griddap",
    "https://coastwatch.pfeg.noaa.gov/erddap/griddap"
  )
}

noaa_erddap_endpoint_specs <- function(base_url) {
  lapply(base_url, function(url) {
    list(
      base_url = url,
      dataset = "ETOPO_2022_v1_15s",
      lon360 = grepl("oceanwatch\\.pifsc\\.noaa\\.gov", url)
    )
  })
}

noaa_erddap_endpoint_windows <- function(left, right, bottom, top, lon360 = FALSE) {
  if (!isTRUE(lon360)) {
    return(list(list(left = left, right = right, bottom = bottom, top = top)))
  }

  if (left < 0 && right > 0) {
    return(list(
      list(left = left + 360, right = 360, bottom = bottom, top = top),
      list(left = 0, right = right, bottom = bottom, top = top)
    ))
  }

  if (right <= 0) {
    left <- left + 360
    right <- right + 360
  }

  list(list(left = left, right = right, bottom = bottom, top = top))
}

noaa_erddap_download_window <- function(
    window,
    endpoint,
    stride,
    progress,
    timeout,
    connect_timeout
) {
  nc_file <- tempfile(fileext = ".nc")
  on.exit(unlink(nc_file), add = TRUE)

  url <- noaa_erddap_url(
    left = window$left,
    right = window$right,
    bottom = window$bottom,
    top = window$top,
    stride = stride,
    base_url = endpoint$base_url,
    dataset = endpoint$dataset
  )
  handle <- curl::new_handle()
  curl::handle_setheaders(handle, "Accept-Encoding" = "gzip, deflate")
  curl::handle_setopt(
    handle,
    timeout = timeout,
    connecttimeout = connect_timeout
  )
  curl::curl_download(
    url = url,
    destfile = nc_file,
    quiet = !isTRUE(progress),
    mode = "wb",
    handle = handle
  )
  if (!file.exists(nc_file) || file.info(nc_file)$size == 0) {
    stop("Downloaded NOAA ERDDAP NetCDF file is empty.", call. = FALSE)
  }

  bathy <- noaa_erddap_read_netcdf(nc_file)
  if (isTRUE(endpoint$lon360)) {
    lon <- as.numeric(rownames(bathy))
    lon[lon > 180] <- lon[lon > 180] - 360
    rownames(bathy) <- lon
    bathy <- check_bathy(bathy)
    class(bathy) <- "bathy"
  }
  bathy
}

noaa_erddap_collate_lon360 <- function(pieces) {
  out <- do.call(rbind, pieces)
  out <- out[unique(rownames(out)), , drop = FALSE]
  out <- check_bathy(out)
  class(out) <- "bathy"
  out
}

noaa_erddap_read_netcdf <- function(path) {
  nc <- try(ncdf4::nc_open(path), silent = TRUE)
  if (inherits(nc, "try-error")) {
    stop("The NOAA ERDDAP NetCDF file could not be read.", call. = FALSE)
  }
  on.exit(ncdf4::nc_close(nc), add = TRUE)

  lon_name <- noaa_erddap_find_name(c("longitude", "lon"), c(names(nc$var), names(nc$dim)))
  lat_name <- noaa_erddap_find_name(c("latitude", "lat"), c(names(nc$var), names(nc$dim)))
  z_name <- noaa_erddap_find_name(c("z", "elevation"), names(nc$var))
  if (is.na(lon_name) || is.na(lat_name) || is.na(z_name)) {
    stop("The NOAA ERDDAP NetCDF file does not contain longitude/latitude/z data.", call. = FALSE)
  }

  lon <- ncdf4::ncvar_get(nc, lon_name)
  lat <- ncdf4::ncvar_get(nc, lat_name)
  z <- ncdf4::ncvar_get(nc, z_name)
  if (!is.matrix(z)) {
    stop("The NOAA ERDDAP z variable is not a two-dimensional grid.", call. = FALSE)
  }

  z_dim_names <- vapply(nc$var[[z_name]]$dim, `[[`, character(1), "name")
  z_dim_names <- tolower(z_dim_names)
  lon_key <- tolower(lon_name)
  lat_key <- tolower(lat_name)

  if (identical(z_dim_names, c(lat_key, lon_key))) {
    depth <- as.vector(t(z))
  } else if (identical(z_dim_names, c(lon_key, lat_key))) {
    depth <- as.vector(z)
  } else if (identical(dim(z), c(length(lat), length(lon)))) {
    depth <- as.vector(t(z))
  } else if (identical(dim(z), c(length(lon), length(lat)))) {
    depth <- as.vector(z)
  } else {
    stop("The NOAA ERDDAP z grid dimensions do not match longitude/latitude.", call. = FALSE)
  }

  xyz <- expand.grid(lon = lon, lat = lat)
  xyz$depth <- depth
  as_bathy(xyz)
}

noaa_erddap_find_name <- function(candidates, names) {
  lower_names <- tolower(names)
  index <- match(tolower(candidates), lower_names)
  index <- index[!is.na(index)]
  if (!length(index)) {
    return(NA_character_)
  }
  names[index[1]]
}
