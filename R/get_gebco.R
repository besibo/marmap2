#' Download bathymetry from the GEBCO download service
#'
#' @description
#' Downloads a user-defined geographic subset from the official GEBCO download
#' service and returns it as an object of class \code{bathy}.
#'
#' @details
#' \code{get_gebco} uses the workflow implemented by the official GEBCO
#' Grid Subsetting App at \url{https://download.gebco.net/}. The function submits
#' a small JSON basket to \code{/api/queue}, polls
#' \code{/api/queue/status/\{basketId\}} until the basket is ready, downloads the
#' resulting zip archive from \code{/api/queue/download/\{basketId\}}, extracts
#' the NetCDF file, reads the \code{lat}, \code{lon}, and \code{elevation}
#' variables, and converts them to a \code{bathy} object.
#'
#' The current global GEBCO grids are served by the GEBCO download service at
#' their native resolution of 15 arc-seconds, i.e. 0.25 arc-minutes or
#' 0.0041667 decimal degrees. This corresponds to approximately 463 m at the
#' equator. The \code{resolution} argument is expressed in arc-minutes for
#' consistency with \code{\link{get_noaa}}, but it is not sent to the GEBCO
#' API: the NetCDF file is downloaded at native resolution, then thinned locally
#' if \code{resolution} is larger than 0.25. Values smaller than 0.25 therefore
#' do not increase the spatial resolution and return the native grid.
#'
#' GEBCO also exposes some higher-resolution regional or experimental products
#' through the same download service, for example polar grids or beta
#' multi-resolution layers. Those products are selected with \code{grid_id} and
#' \code{data_source_id}; their native resolution and coordinate reference
#' system may differ from the global longitude/latitude grid. This function is
#' currently designed for global longitude/latitude bathymetry layers whose
#' NetCDF variables are named \code{lon}, \code{lat}, and \code{elevation}.
#'
#' The GEBCO download service expects \code{left <= right}; areas crossing the
#' antimeridian are therefore not handled by this importer. Split such requests
#' into two calls, one on each side of the antimeridian.
#'
#' @param lon1 Western or first longitude bound in decimal degrees.
#' @param lon2 Eastern or second longitude bound in decimal degrees.
#' @param lat1 Southern or first latitude bound in decimal degrees.
#' @param lat2 Northern or second latitude bound in decimal degrees.
#' @param resolution Output grid spacing in arc-minutes. Defaults to \code{1}.
#'   The GEBCO global NetCDF subset is downloaded at its native 15 arc-second
#'   resolution, then thinned locally when \code{resolution > 0.25}. Values lower
#'   than \code{0.25} return the native GEBCO global grid resolution.
#' @param keep Logical. If \code{TRUE}, the xyz table returned as a
#'   \code{bathy} object is also written as a csv file in \code{path}.
#' @param path Directory used for cached csv files when \code{keep = TRUE}, and
#'   where \code{get_gebco} looks for an already downloaded matching csv
#'   file. Defaults to the current working directory.
#' @param base_url Base URL of the official GEBCO download service.
#' @param grid_id Numeric GEBCO grid identifier used by the download service.
#'   The default, \code{1}, corresponds to the first grid returned by
#'   \code{/api/grids}; at the time this function was written, this was the
#'   latest global GEBCO grid.
#' @param data_source_id Numeric GEBCO data-source identifier. The default,
#'   \code{1}, corresponds to the first bathymetry layer returned by
#'   \code{/api/grids}; at the time this function was written, this was
#'   bathymetry from the latest global GEBCO grid.
#' @param format_id Numeric GEBCO output-format identifier. The default,
#'   \code{1}, corresponds to NetCDF.
#' @param poll_interval Number of seconds between two status checks.
#' @param timeout Maximum number of seconds to wait for the GEBCO basket to be
#'   processed.
#' @param quiet Logical. If \code{FALSE}, progress messages are displayed.
#'
#' @return
#' An object of class \code{bathy}. If \code{keep = TRUE}, a csv copy of the
#' downloaded xyz table is written to \code{path}.
#'
#' @references
#' GEBCO Compilation Group. GEBCO Grid, a continuous terrain model for oceans
#' and land at 15 arc-second intervals. \url{https://www.gebco.net/}
#'
#' @seealso
#' \code{\link{get_noaa}}, \code{\link{read_gebco_bathy}},
#' \code{\link{read_bathy}}, \code{\link{as_bathy}}
#'
#' @examples
#' \dontrun{
#' # Download a one-degree subset from the official GEBCO service
#' b <- get_gebco(
#'   lon1 = -6, lon2 = -5,
#'   lat1 = 49, lat2 = 50,
#'   resolution = 1
#' )
#'
#' plot(b, image = TRUE, land = TRUE)
#' }
#' @importFrom curl curl_fetch_memory new_handle handle_setheaders handle_setopt
#' @export
get_gebco <- function(
    lon1,
    lon2,
    lat1,
    lat2,
    resolution = 1,
    keep = FALSE,
    path = NULL,
    base_url = "https://download.gebco.net",
    grid_id = 1,
    data_source_id = 1,
    format_id = 1,
    poll_interval = 2,
    timeout = 300,
    quiet = FALSE
) {
  if (!requireNamespace("ncdf4", quietly = TRUE)) {
    stop("Package 'ncdf4' is required.", call. = FALSE)
  }
  if (!requireNamespace("curl", quietly = TRUE)) {
    stop("Package 'curl' is required.", call. = FALSE)
  }

  if (!is.numeric(c(lon1, lon2, lat1, lat2, resolution, grid_id, data_source_id, format_id))) {
    stop("Coordinates, resolution, grid_id, data_source_id, and format_id must be numeric.", call. = FALSE)
  }
  if (length(lon1) != 1 || length(lon2) != 1 || length(lat1) != 1 || length(lat2) != 1) {
    stop("lon1, lon2, lat1, and lat2 must be single numeric values.", call. = FALSE)
  }
  if (length(grid_id) != 1 || length(data_source_id) != 1 || length(format_id) != 1) {
    stop("grid_id, data_source_id, and format_id must be single numeric values.", call. = FALSE)
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
  if (!is.finite(resolution) || resolution <= 0) {
    stop("resolution must be a positive numeric value.", call. = FALSE)
  }
  if (!is.numeric(poll_interval) || length(poll_interval) != 1 ||
      !is.finite(poll_interval) || poll_interval <= 0) {
    stop("poll_interval must be a positive numeric value.", call. = FALSE)
  }
  if (!is.numeric(timeout) || length(timeout) != 1 || !is.finite(timeout) || timeout <= 0) {
    stop("timeout must be a positive numeric value.", call. = FALSE)
  }

  if (is.null(path)) {
    path <- "."
  }
  if (!dir.exists(path)) {
    stop("path does not exist.", call. = FALSE)
  }

  x1 <- min(lon1, lon2)
  x2 <- max(lon1, lon2)
  y1 <- min(lat1, lat2)
  y2 <- max(lat1, lat2)
  resolution <- max(resolution, 0.25)

  file <- paste0(
    "marmap_gebco_coord_",
    x1, ";", y1, ";", x2, ";", y2,
    "_res_", resolution,
    ".csv"
  )
  csv_file <- file.path(path, file)

  if (file.exists(csv_file)) {
    if (!quiet) {
      message("File already exists; loading '", file, "'")
    }
    return(read_bathy(csv_file, header = TRUE))
  }

  fmt <- function(x) {
    trimws(formatC(x, format = "fg", digits = 15))
  }

  extract_json_value <- function(json, key) {
    pattern <- paste0('"', key, '"[[:space:]]*:[[:space:]]*"([^"]*)"')
    value <- sub(pattern, "\\1", regmatches(json, regexpr(pattern, json)))
    if (length(value) == 0 || identical(value, character(0))) {
      return(NA_character_)
    }
    value
  }

  post_json <- function(url, body) {
    handle <- curl::new_handle()
    curl::handle_setheaders(handle, "Content-Type" = "application/json")
    curl::handle_setopt(handle, postfields = charToRaw(body))
    response <- curl::curl_fetch_memory(url, handle = handle)
    list(
      status_code = response$status_code,
      content = rawToChar(response$content)
    )
  }

  get_json <- function(url) {
    response <- curl::curl_fetch_memory(url)
    list(
      status_code = response$status_code,
      content = rawToChar(response$content)
    )
  }

  base_url <- sub("/+$", "", base_url)
  queue_url <- paste0(base_url, "/api/queue")
  status_url <- paste0(base_url, "/api/queue/status/")
  download_url <- paste0(base_url, "/api/queue/download/")

  body <- paste0(
    '{"id":"0",',
    '"email":"",',
    '"submission_date":"', format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6"), '",',
    '"processing_status":"new",',
    '"items":[{',
    '"id":0,',
    '"grid_id":', as.integer(grid_id), ",",
    '"data_source_ids":[', as.integer(data_source_id), "],",
    '"formats":[', as.integer(format_id), "],",
    '"left":', fmt(x1), ",",
    '"right":', fmt(x2), ",",
    '"top":', fmt(y2), ",",
    '"bottom":', fmt(y1),
    "}]}",
    sep = ""
  )

  if (!quiet) {
    message("Submitting GEBCO download request ...")
  }

  queue_response <- try(post_json(queue_url, body), silent = TRUE)
  if (inherits(queue_response, "try-error") || queue_response$status_code >= 400) {
    stop("The GEBCO download service rejected the request.", call. = FALSE)
  }

  basket_id <- extract_json_value(queue_response$content, "basketId")
  if (is.na(basket_id) || !nzchar(basket_id)) {
    stop("The GEBCO download service did not return a basket identifier.", call. = FALSE)
  }

  if (!quiet) {
    message("GEBCO basket id: ", basket_id)
    message("Waiting for GEBCO to process the basket ...")
  }

  started <- Sys.time()
  status <- NA_character_
  repeat {
    status_response <- try(get_json(paste0(status_url, basket_id)), silent = TRUE)
    if (!inherits(status_response, "try-error") && status_response$status_code < 400) {
      status <- extract_json_value(status_response$content, "status")
    }
    if (identical(status, "finished")) {
      break
    }
    if (!is.na(status) && !status %in% c("new", "processing")) {
      stop("The GEBCO basket failed with status: ", status, call. = FALSE)
    }
    if (as.numeric(difftime(Sys.time(), started, units = "secs")) > timeout) {
      stop("Timed out while waiting for the GEBCO basket to be processed.", call. = FALSE)
    }
    Sys.sleep(poll_interval)
  }

  zip_file <- tempfile(fileext = ".zip")
  extract_dir <- tempfile("gebco_")
  dir.create(extract_dir)
  on.exit(unlink(c(zip_file, extract_dir), recursive = TRUE), add = TRUE)

  if (!quiet) {
    message("Downloading GEBCO NetCDF archive ...")
  }

  download_status <- try(
    utils::download.file(
      paste0(download_url, basket_id),
      destfile = zip_file,
      mode = "wb",
      quiet = quiet
    ),
    silent = TRUE
  )
  if (inherits(download_status, "try-error") ||
      !file.exists(zip_file) || file.info(zip_file)$size == 0) {
    stop("The GEBCO download archive cannot be reached or is empty.", call. = FALSE)
  }

  extracted <- try(utils::unzip(zip_file, exdir = extract_dir), silent = TRUE)
  if (inherits(extracted, "try-error")) {
    stop("The GEBCO download archive could not be extracted.", call. = FALSE)
  }
  nc_files <- extracted[grepl("\\.nc$", extracted, ignore.case = TRUE)]
  if (length(nc_files) == 0) {
    stop("The GEBCO download archive does not contain a NetCDF file.", call. = FALSE)
  }

  nc <- try(ncdf4::nc_open(nc_files[1]), silent = TRUE)
  if (inherits(nc, "try-error")) {
    stop("The GEBCO NetCDF file could not be read.", call. = FALSE)
  }
  on.exit(ncdf4::nc_close(nc), add = TRUE)

  if (!"elevation" %in% names(nc$var) ||
      !"lat" %in% c(names(nc$var), names(nc$dim)) ||
      !"lon" %in% c(names(nc$var), names(nc$dim))) {
    stop("The GEBCO NetCDF file does not contain lat/lon/elevation data.", call. = FALSE)
  }

  lat <- ncdf4::ncvar_get(nc, "lat")
  lon <- ncdf4::ncvar_get(nc, "lon")
  elevation <- ncdf4::ncvar_get(nc, "elevation")
  original_lat <- lat
  original_lon <- lon

  if (!is.matrix(elevation)) {
    stop("The GEBCO elevation variable is not a two-dimensional grid.", call. = FALSE)
  }

  thin_index <- function(x, resolution) {
    if (length(x) <= 2 || resolution <= 0.25) {
      return(seq_along(x))
    }
    step <- median(abs(diff(sort(unique(x)))), na.rm = TRUE) * 60
    if (!is.finite(step) || step <= 0) {
      return(seq_along(x))
    }
    by <- max(1, round(resolution / step))
    unique(c(seq(1, length(x), by = by), length(x)))
  }

  lon_index <- thin_index(lon, resolution)
  lat_index <- thin_index(lat, resolution)
  lon <- lon[lon_index]
  lat <- lat[lat_index]

  if (identical(dim(elevation), c(length(original_lat), length(original_lon)))) {
    elevation <- elevation[lat_index, lon_index, drop = FALSE]
  } else if (identical(dim(elevation), c(length(original_lon), length(original_lat)))) {
    elevation <- elevation[lon_index, lat_index, drop = FALSE]
  } else {
    stop("The GEBCO elevation grid dimensions do not match lon/lat.", call. = FALSE)
  }

  if (identical(dim(elevation), c(length(lat), length(lon)))) {
    z <- as.vector(t(elevation))
  } else if (identical(dim(elevation), c(length(lon), length(lat)))) {
    z <- as.vector(elevation)
  } else {
    stop("The GEBCO elevation grid dimensions do not match lon/lat.", call. = FALSE)
  }

  xyz <- expand.grid(lon = lon, lat = lat)
  xyz$depth <- z
  bathy <- as_bathy(xyz)

  if (keep) {
    utils::write.table(
      as_xyz(bathy),
      file = csv_file,
      sep = ",",
      quote = FALSE,
      row.names = FALSE
    )
  }

  bathy
}
