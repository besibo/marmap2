#' Download bathymetry from the GEBCO download service
#'
#' @description
#' Downloads a user-defined geographic subset from the official GEBCO download
#' service and returns it as a tibble or an object of class \code{bathy}.
#'
#' @details
#' \code{get_gebco} uses the workflow implemented by the official GEBCO
#' Grid Subsetting App at \url{https://download.gebco.net/}. The function submits
#' a small JSON basket to \code{/api/queue}, polls
#' \code{/api/queue/status/\{basketId\}} until the basket is ready, downloads the
#' resulting zip archive from \code{/api/queue/download/\{basketId\}}, extracts
#' the NetCDF file, reads the \code{lat}, \code{lon}, and \code{elevation}
#' variables, and converts them to the requested output class.
#'
#' The current global GEBCO grids are served by the GEBCO download service at
#' their native resolution of 15 arc-seconds, i.e. 0.25 arc-minutes or
#' 0.0041667 decimal degrees. This corresponds to approximately 463 m at the
#' equator. The \code{resolution} argument is expressed in arc-minutes for
#' consistency with \code{\link{get_noaa}}, but it is not sent to the GEBCO
#' API: the NetCDF file is downloaded at native resolution, then resampled
#' locally with nearest-neighbour selection on a regular grid if
#' \code{resolution} is larger than 0.25. Values smaller than 0.25 therefore do
#' not increase the spatial resolution and return the native grid.
#'
#' GEBCO also exposes some higher-resolution regional or experimental products
#' through the same download service, for example polar grids or beta
#' multi-resolution layers. This function intentionally targets the default
#' global longitude/latitude bathymetry layer whose NetCDF variables are named
#' \code{lon}, \code{lat}, and \code{elevation}.
#'
#' The GEBCO download service expects \code{left <= right}; areas crossing the
#' antimeridian are therefore downloaded as two geographic subsets, one from the
#' eastern longitude bound to 180 degrees and one from -180 degrees to the
#' western longitude bound. The two subsets are then stitched into a single
#' \code{bathy} object whose longitudes are expressed in the 0-360 degree range.
#' As in \code{\link{get_noaa}}, the order of \code{lon1}/\code{lon2} and
#' \code{lat1}/\code{lat2} does not matter: the function sorts the coordinate
#' bounds internally before submitting requests to GEBCO.
#'
#' @param lon Numeric vector of length 2 giving the longitude bounds in decimal
#'   degrees. This is the recommended syntax.
#' @param lat Numeric vector of length 2 giving the latitude bounds in decimal
#'   degrees. This is the recommended syntax.
#' @param lon1 First longitude bound in decimal degrees. Alternative to
#'   \code{lon}.
#' @param lon2 Second longitude bound in decimal degrees. Alternative to
#'   \code{lon}.
#' @param lat1 First latitude bound in decimal degrees. Alternative to
#'   \code{lat}.
#' @param lat2 Second latitude bound in decimal degrees. Alternative to
#'   \code{lat}.
#' @param resolution Output grid spacing in arc-minutes. Defaults to \code{1}.
#'   The GEBCO global NetCDF subset is downloaded at its native 15 arc-second
#'   resolution, then resampled locally with nearest-neighbour selection when
#'   \code{resolution > 0.25}. Values lower than \code{0.25} return the native
#'   GEBCO global grid resolution.
#' @param antimeridian Logical. If \code{TRUE}, the requested longitudinal range
#'   is interpreted as crossing the antimeridian. The function downloads two
#'   GEBCO subsets and stitches them into one \code{bathy} object. The order of
#'   \code{lon1} and \code{lon2} does not matter.
#' @param keep Logical. If \code{TRUE}, the xyz table returned as a
#'   \code{bathy} object is also written as a csv file in \code{path}.
#' @param path Directory used for cached csv files when \code{keep = TRUE}, and
#'   where \code{get_gebco} looks for an already downloaded matching csv
#'   file. Defaults to the current working directory.
#' @param class Character. Class of the returned object. Use \code{"tbl"}
#'   (default) to return a tibble with columns \code{lon}, \code{lat}, and
#'   \code{depth}; use \code{"bathy"} to return a historical matrix of class
#'   \code{bathy}.
#'
#' @return
#' A tibble by default, or an object of class \code{bathy} when
#' \code{class = "bathy"}. If \code{keep = TRUE}, a csv copy of the downloaded
#' xyz table is written to \code{path}.
#'
#' @references
#' GEBCO Compilation Group. GEBCO Grid, a continuous terrain model for oceans
#' and land at 15 arc-second intervals. \url{https://www.gebco.net/}
#'
#' @seealso
#' \code{\link{get_noaa}}, \code{\link{read_bathy}},
#' \code{\link{as_bathy}}, \code{\link{geom_bathy}}
#'
#' @examples
#' \dontrun{
#' # Download a one-degree subset from the official GEBCO service
#' b <- get_gebco(
#'   lon = c(-6, -5),
#'   lat = c(49, 50),
#'   resolution = 1
#' )
#'
#' }
#' @importFrom curl curl_fetch_memory new_handle handle_setheaders handle_setopt
#' @export
get_gebco <- function(
    lon = NULL,
    lat = NULL,
    lon1 = NULL,
    lon2 = NULL,
    lat1 = NULL,
    lat2 = NULL,
    resolution = 1,
    antimeridian = FALSE,
    keep = FALSE,
    path = NULL,
    class = c("tbl", "bathy")
) {
  base_url <- "https://download.gebco.net"
  grid_id <- 1
  data_source_id <- 1
  format_id <- 1
  poll_interval <- 2
  timeout <- 300
  quiet <- FALSE

  output_class <- match.arg(class)
  bounds <- resolve_lon_lat_args(lon1, lon2, lat1, lat2, lon, lat)
  lon1 <- bounds$lon1
  lon2 <- bounds$lon2
  lat1 <- bounds$lat1
  lat2 <- bounds$lat2

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
  if (!is.logical(antimeridian) || length(antimeridian) != 1 || is.na(antimeridian)) {
    stop("antimeridian must be TRUE or FALSE.", call. = FALSE)
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
    if (antimeridian) "_anti" else "",
    ".csv"
  )
  csv_file <- file.path(path, file)

  if (file.exists(csv_file)) {
    if (!quiet) {
      message("File already exists; loading '", file, "'")
    }
    existing_bathy <- read_bathy(csv_file, header = TRUE)
    if (identical(output_class, "tbl")) {
      return(bathy_to_tbl(existing_bathy))
    }
    return(existing_bathy)
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

  fetch_gebco_bbox <- function(left, right, bottom, top) {
    if (left >= right) {
      stop("Each GEBCO subset must satisfy left < right.", call. = FALSE)
    }

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
      '"left":', fmt(left), ",",
      '"right":', fmt(right), ",",
      '"top":', fmt(top), ",",
      '"bottom":', fmt(bottom),
      "}]}",
      sep = ""
    )

    if (!quiet) {
      message(
        "Submitting GEBCO download request for ",
        fmt(left), "/", fmt(right), "/",
        fmt(bottom), "/", fmt(top), " ..."
      )
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

    lon_axis <- regular_gebco_axis(lon, left, right, resolution)
    lat_axis <- regular_gebco_axis(lat, bottom, top, resolution)
    lon_index <- lon_axis$index
    lat_index <- lat_axis$index
    lon <- lon_axis$values
    lat <- lat_axis$values

    elevation_dim_names <- vapply(nc$var$elevation$dim, `[[`, character(1), "name")
    elevation_dim_names <- tolower(elevation_dim_names)
    elevation_orientation <- NULL

    if (identical(elevation_dim_names, c("lat", "lon"))) {
      elevation <- elevation[lat_index, lon_index, drop = FALSE]
      elevation_orientation <- "lat_lon"
    } else if (identical(elevation_dim_names, c("lon", "lat"))) {
      elevation <- elevation[lon_index, lat_index, drop = FALSE]
      elevation_orientation <- "lon_lat"
    } else if (!identical(length(original_lat), length(original_lon)) &&
        identical(dim(elevation), c(length(original_lat), length(original_lon)))) {
      elevation <- elevation[lat_index, lon_index, drop = FALSE]
      elevation_orientation <- "lat_lon"
    } else if (!identical(length(original_lat), length(original_lon)) &&
        identical(dim(elevation), c(length(original_lon), length(original_lat)))) {
      elevation <- elevation[lon_index, lat_index, drop = FALSE]
      elevation_orientation <- "lon_lat"
    } else {
      stop("The GEBCO elevation grid dimensions do not match lon/lat.", call. = FALSE)
    }

    if (identical(elevation_orientation, "lat_lon")) {
      z <- as.vector(t(elevation))
    } else if (identical(elevation_orientation, "lon_lat")) {
      z <- as.vector(elevation)
    } else {
      stop("The GEBCO elevation grid dimensions do not match lon/lat.", call. = FALSE)
    }

    xyz <- expand.grid(lon = lon, lat = lat)
    xyz$depth <- z
    as_bathy(xyz)
  }

  if (antimeridian) {
    full_longitude_range <- x1 == -180 && x2 == 180
    if (full_longitude_range) {
      x1 <- 0
      x2 <- 0
    }
    if (!quiet) {
      message("Downloading GEBCO data across the antimeridian ...")
    }
    east <- if (x2 < 180) fetch_gebco_bbox(x2, 180, y1, y2) else NULL
    west <- if (x1 > -180) fetch_gebco_bbox(-180, x1, y1, y2) else NULL
    bathy <- if (!is.null(east) && !is.null(west)) {
      collate_antimeridian_bathy(east, west)
    } else if (!is.null(east)) {
      east
    } else if (!is.null(west)) {
      west
    } else {
      stop("The antimeridian request has no longitudinal extent.", call. = FALSE)
    }
  } else {
    bathy <- fetch_gebco_bbox(x1, x2, y1, y2)
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

collate_antimeridian_bathy <- function(east, west) {
  rownames(west) <- as.numeric(rownames(west)) + 360
  collated <- rbind(east, west)
  collated <- collated[unique(rownames(collated)), , drop = FALSE]
  class(collated) <- "bathy"
  collated
}
