#' Download bathymetry from NOAA ETOPO 2022
#'
#' @description
#' Imports bathymetric and topographic data from the NOAA ETOPO 2022 image
#' service, given coordinate bounds and a requested spatial resolution.
#'
#' @details
#' \code{get_noaa()} queries the ETOPO 2022 database hosted by NOAA, using the
#' coordinates of the area of interest and the desired resolution. The function
#' uses the NOAA ArcGIS image service exposed through the same ImageServer
#' backend as the NOAA Grid Extract tool, and returns a long tibble by default,
#' or a matrix of class \code{bathy} when \code{class = "bathy"}.
#'
#' The \code{resolution} argument is expressed in arc-minutes. The function uses
#' the 15 arc-second ETOPO 2022 layer for \code{resolution = 0.25}, the
#' 30 arc-second layer for \code{resolution = 0.5}, and the 60 arc-second layer
#' for coarser resolutions. Values lower than \code{0.5} are rounded to
#' \code{0.25}; values between \code{0.5} and \code{1} are rounded to
#' \code{0.5}.
#'
#' Users can optionally write the downloaded data to disk with
#' \code{keep = TRUE}. If an identical query is performed later, using the same
#' longitudes, latitudes, resolution, and antimeridian setting, \code{get_noaa()}
#' will load the local file instead of querying the NOAA server again. This
#' behaviour should be used preferentially to reduce unnecessary queries to the
#' NOAA service and to reduce data loading time. If several identical queries
#' should be forced to download fresh data, the cached csv file must be renamed,
#' removed, or moved outside \code{path}.
#'
#' \code{get_noaa()} can download bathymetric data around the antimeridian when
#' \code{antimeridian = TRUE}. The antimeridian is the 180th meridian, located
#' in the Pacific Ocean, east of New Zealand and Fiji and west of Hawaii and
#' Tonga. For a pair of longitude values such as \code{-150} and \code{150},
#' two different areas can be requested: the 60 degree-wide area centered on the
#' antimeridian when \code{antimeridian = TRUE}, or the 300 degree-wide area
#' centered on the prime meridian when \code{antimeridian = FALSE}. Data around
#' the antimeridian require two distinct NOAA queries, so \code{keep = TRUE} can
#' be especially useful in this case.
#'
#' Internally, \code{get_noaa()} downloads temporary GeoTIFF subsets using the
#' official ETOPO 2022 layer names used by the NOAA Grid Extract tool. The
#' temporary files are written to R's temporary directory and removed as soon as
#' they have been converted to \code{bathy}/tibble data.
#'
#' The order of longitude and latitude bounds does not matter: \code{get_noaa()}
#' sorts the coordinate bounds internally before querying NOAA. Longitude and
#' latitude bounds should preferably be supplied with the vector syntax
#' \code{lon = c(lon1, lon2)} and \code{lat = c(lat1, lat2)}. The explicit
#' \code{lon1}, \code{lon2}, \code{lat1}, and \code{lat2} arguments remain
#' available for compatibility with older code.
#'
#' @rdname get_noaa
#' @param lon Numeric vector of length 2 giving the longitude bounds in decimal
#'   degrees. This is the recommended syntax.
#' @param lat Numeric vector of length 2 giving the latitude bounds in decimal
#'   degrees. This is the recommended syntax.
#' @param lon1 First longitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees. Alternative to \code{lon}.
#' @param lon2 Second longitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees. Alternative to \code{lon}.
#' @param lat1 First latitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees. Alternative to \code{lat}.
#' @param lat2 Second latitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees. Alternative to \code{lat}.
#' @param resolution Requested grid resolution in arc-minutes. Defaults to
#'   \code{4}.
#' @param antimeridian Logical. Whether the requested region crosses the
#'   antimeridian, longitude 180 or -180.
#' @param keep Logical. Whether to write the downloaded xyz table to disk.
#'   Defaults to \code{FALSE}.
#' @param path Directory used for cached csv files when \code{keep = TRUE}, and
#'   where \code{get_noaa()} looks for already downloaded matching data. Defaults
#'   to the current working directory.
#' @param class Character. Class of the returned object. Use \code{"tbl"}
#'   (default) to return a tibble with columns \code{lon}, \code{lat}, and
#'   \code{depth}; use \code{"bathy"} to return a historical matrix of class
#'   \code{bathy}.
#'
#' @return
#' A tibble by default, or an object of class \code{bathy} when
#' \code{class = "bathy"}. If \code{keep = TRUE}, a csv file containing the
#' downloaded xyz table is written to \code{path}. This file is named using the
#' format \code{marmap_coord_COORDINATES_res_RESOLUTION.csv}, with coordinates
#' separated by semicolons; antimeridian requests add the \code{_anti} suffix.
#'
#' @references
#' NOAA National Centers for Environmental Information. 2022: ETOPO 2022
#' 15 Arc-Second Global Relief Model. NOAA National Centers for Environmental
#' Information. \doi{10.25921/fd45-gt74}
#'
#' @seealso
#' \code{\link{get_gebco}}, \code{\link{read_bathy}},
#' \code{\link{bathy_to_tbl}}, \code{\link{tbl_to_bathy}},
#' \code{\link{geom_bathy}}
#'
#' @examples
#' \dontrun{
#' # Query NOAA ETOPO 2022 for the North Atlantic at 10 arc-minutes.
#' atl <- get_noaa(
#'   lon = c(-20, -90),
#'   lat = c(50, 20),
#'   resolution = 10
#' )
#'
#' # Same query using explicit lon1/lon2/lat1/lat2 arguments.
#' atl_tbl <- get_noaa(
#'   lon1 = -20, lon2 = -90,
#'   lat1 = 50, lat2 = 20,
#'   resolution = 10
#' )
#'
#' # Download speed for a 10 x 10 degree area at 30 arc-minutes.
#' system.time(get_noaa(lon = c(0, 10), lat = c(0, 10), resolution = 30))
#'
#' # Antimeridian request around the Aleutian Islands.
#' aleu <- get_noaa(
#'   lon = c(165, -145),
#'   lat = c(50, 65),
#'   resolution = 5,
#'   antimeridian = TRUE
#' )
#' }
#' @export
get_noaa <-
  function(
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
    class = c("tbl", "bathy")
  ) {
    output_class <- match.arg(class)
    request <- noaa_request_args(
      lon = lon,
      lat = lat,
      lon1 = lon1,
      lon2 = lon2,
      lat1 = lat1,
      lat2 = lat2,
      resolution = resolution,
      antimeridian = antimeridian,
      path = path
    )

    file <- noaa_cache_name(request)
    csv_file <- noaa_cache_file(request$path, request)
    if (file.exists(csv_file)) {
      message("File already exists; loading '", file, "'")
      existing_bathy <- read_bathy(csv_file, header = TRUE)
      if (identical(output_class, "tbl")) {
        return(bathy_to_tbl(existing_bathy))
      }
      return(existing_bathy)
    }

    fetcher <- getOption("marmap2.noaa_fetcher", noaa_fetch_bbox)
    windows <- noaa_request_windows(request)

    message("Querying NOAA database ...")
    message("This may take seconds to minutes, depending on grid size\n")
    if (request$antimeridian) {
      pieces <- noaa_fetch_windows(windows, fetcher, request$layer)
      bathy <- collate_antimeridian_bathy(pieces$east, pieces$west)
    } else {
      bathy <- noaa_fetch_windows(windows, fetcher, request$layer)[[1]]
    }

    message("Building bathy matrix ...")
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

noaa_request_args <- function(
    lon = NULL,
    lat = NULL,
    lon1 = NULL,
    lon2 = NULL,
    lat1 = NULL,
    lat2 = NULL,
    resolution = 4,
    antimeridian = FALSE,
    path = NULL
) {
  bounds <- resolve_lon_lat_args(lon1, lon2, lat1, lat2, lon, lat)
  lon1 <- bounds$lon1
  lon2 <- bounds$lon2
  lat1 <- bounds$lat1
  lat2 <- bounds$lat2

  if (!is.numeric(c(lon1, lon2, lat1, lat2, resolution))) {
    stop("Coordinates and resolution must be numeric.", call. = FALSE)
  }
  if (length(lon1) != 1 || length(lon2) != 1 || length(lat1) != 1 || length(lat2) != 1) {
    stop("lon1, lon2, lat1, and lat2 must be single numeric values.", call. = FALSE)
  }
  if (length(resolution) != 1 || !is.finite(resolution) || resolution <= 0) {
    stop("resolution must be a single positive number.", call. = FALSE)
  }
  if (!is.logical(antimeridian) || length(antimeridian) != 1 || is.na(antimeridian)) {
    stop("antimeridian must be TRUE or FALSE.", call. = FALSE)
  }
  if (lon1 == lon2) {
    stop("The longitudinal range defined by lon1 and lon2 is incorrect.", call. = FALSE)
  }
  if (lat1 == lat2) {
    stop("The latitudinal range defined by lat1 and lat2 is incorrect.", call. = FALSE)
  }
  if (lat1 > 90 || lat1 < -90 || lat2 > 90 || lat2 < -90) {
    stop("Latitudes should have values between -90 and +90.", call. = FALSE)
  }
  if (lon1 < -180 || lon1 > 180 || lon2 < -180 || lon2 > 180) {
    stop("Longitudes should have values between -180 and +180.", call. = FALSE)
  }

  if (is.null(path)) {
    path <- "."
  }
  if (!is.character(path) || length(path) != 1 || is.na(path) || !dir.exists(path)) {
    stop("path must be an existing directory.", call. = FALSE)
  }

  resolution <- noaa_effective_resolution(resolution)
  layer <- noaa_layer_name(resolution)
  x1 <- min(lon1, lon2)
  x2 <- max(lon1, lon2)
  y1 <- min(lat1, lat2)
  y2 <- max(lat1, lat2)

  request <- list(
    x1 = x1,
    x2 = x2,
    y1 = y1,
    y2 = y2,
    resolution = resolution,
    layer = layer,
    antimeridian = antimeridian,
    path = path
  )

  windows <- noaa_request_windows(request)
  n_lon <- sum(vapply(windows, `[[`, numeric(1), "ncol"))
  n_lat <- windows[[1]]$nrow
  noaa_validate_grid_size(n_lon, n_lat)
  request
}

noaa_effective_resolution <- function(resolution) {
  if (resolution < 0.5) {
    return(0.25)
  }
  if (resolution < 1) {
    return(0.5)
  }
  resolution
}

noaa_layer_name <- function(resolution) {
  if (identical(resolution, 0.25)) {
    return("ETOPO_2022_v1_15s_bed_elev")
  }
  if (identical(resolution, 0.5)) {
    return("ETOPO_2022_v1_30s_bed")
  }
  "ETOPO_2022_v1_60s_bed"
}

noaa_request_windows <- function(request) {
  if (request$antimeridian) {
    if (request$x1 == -180 && request$x2 == 180) {
      request$x1 <- 0
      request$x2 <- 0
    }
    return(list(
      east = noaa_window(request$x2, 180, request$y1, request$y2, request$resolution),
      west = noaa_window(-180, request$x1, request$y1, request$y2, request$resolution)
    ))
  }

  list(main = noaa_window(request$x1, request$x2, request$y1, request$y2, request$resolution))
}

noaa_window <- function(left, right, bottom, top, resolution) {
  ncol <- floor((right - left) * 60 / resolution)
  nrow <- floor((top - bottom) * 60 / resolution)
  list(
    left = left,
    right = right,
    bottom = bottom,
    top = top,
    ncol = ncol,
    nrow = nrow
  )
}

noaa_validate_grid_size <- function(ncol, nrow) {
  if (ncol < 2 && nrow < 2) {
    stop(
      "It's impossible to fetch an area with less than one cell. Either increase the longitudinal and latitudinal ranges or use a smaller resolution value.",
      call. = FALSE
    )
  }
  if (ncol < 2) {
    stop(
      "It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or use a smaller resolution value.",
      call. = FALSE
    )
  }
  if (nrow < 2) {
    stop(
      "It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or use a smaller resolution value.",
      call. = FALSE
    )
  }
  if (ncol > 10000 || nrow > 10000) {
    stop(
      "The requested grid is too large for the NOAA image service. Increase resolution or reduce the geographic extent.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

noaa_cache_name <- function(request) {
  suffix <- if (request$antimeridian) "_anti" else ""
  paste0(
    "marmap_coord_",
    request$x1,
    ";",
    request$y1,
    ";",
    request$x2,
    ";",
    request$y2,
    "_res_",
    request$resolution,
    suffix,
    ".csv"
  )
}

noaa_cache_file <- function(path, request) {
  file.path(path, noaa_cache_name(request))
}

noaa_fetch_windows <- function(windows, fetcher, layer) {
  all_chunks <- unlist(lapply(windows, noaa_window_chunks), recursive = FALSE)
  total_cells <- sum(vapply(all_chunks, noaa_window_cells, numeric(1)))

  downloaded <- 0
  message(
    "Downloading NOAA GeoTIFF subset (",
    noaa_format_cell_count(total_cells),
    " cells) ..."
  )
  pb <- utils::txtProgressBar(min = 0, max = total_cells, style = 3)
  on.exit(close(pb), add = TRUE)

  pieces <- vector("list", length(windows))
  names(pieces) <- names(windows)
  for (i in seq_along(windows)) {
    chunks <- noaa_window_chunks(windows[[i]])
    chunk_bathy <- vector("list", length(chunks))
    for (j in seq_along(chunks)) {
      chunk_bathy[[j]] <- do.call(fetcher, c(chunks[[j]], list(layer = layer)))
      downloaded <- downloaded + noaa_window_cells(chunks[[j]])
      utils::setTxtProgressBar(pb, downloaded)
    }
    pieces[[i]] <- noaa_combine_latitude_chunks(chunk_bathy)
  }

  pieces
}

noaa_window_chunks <- function(window, max_cells = 250000) {
  total <- noaa_window_cells(window)
  if (total <= max_cells || window$nrow <= 2 || window$ncol <= 0) {
    return(list(window))
  }

  rows_per_chunk <- max(2L, floor(max_cells / window$ncol))
  if (rows_per_chunk >= window$nrow) {
    return(list(window))
  }

  starts <- seq(1L, window$nrow, by = rows_per_chunk)
  ends <- pmin(starts + rows_per_chunk - 1L, window$nrow)
  if (length(ends) > 1 && (ends[length(ends)] - starts[length(starts)] + 1L) == 1L) {
    ends[length(ends) - 1L] <- ends[length(ends)]
    starts <- starts[-length(starts)]
    ends <- ends[-length(ends)]
  }

  dy <- (window$top - window$bottom) / window$nrow
  Map(function(start, end) {
    chunk <- window
    chunk$bottom <- window$bottom + (start - 1L) * dy
    chunk$top <- window$bottom + end * dy
    chunk$nrow <- end - start + 1L
    chunk
  }, starts, ends)
}

noaa_window_cells <- function(window) {
  as.numeric(window$ncol) * as.numeric(window$nrow)
}

noaa_combine_latitude_chunks <- function(chunks) {
  if (length(chunks) == 1L) {
    return(chunks[[1]])
  }
  out <- do.call(cbind, chunks)
  out <- out[, unique(colnames(out)), drop = FALSE]
  out <- check_bathy(out)
  class(out) <- "bathy"
  out
}

noaa_format_cell_count <- function(x) {
  format(x, big.mark = " ", scientific = FALSE, trim = TRUE)
}

noaa_fetch_bbox <- function(left, right, bottom, top, ncol, nrow, layer) {
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("Package 'terra' is required.", call. = FALSE)
  }

  url <- noaa_export_image_url(
    left = left,
    right = right,
    bottom = bottom,
    top = top,
    ncol = ncol,
    nrow = nrow,
    layer = layer
  )
  tmp <- tempfile(fileext = ".tif")
  on.exit(unlink(tmp), add = TRUE)

  ok <- try(
    curl::curl_download(
      url = url,
      destfile = tmp,
      mode = "wb",
      quiet = TRUE
    ),
    silent = TRUE
  )
  if (inherits(ok, "try-error") || !file.exists(tmp) || file.info(tmp)$size == 0) {
    stop("The NOAA server cannot be reached.", call. = FALSE)
  }

  raster <- suppressWarnings(try(terra::rast(tmp), silent = TRUE))
  if (inherits(raster, "try-error")) {
    stop("The NOAA GeoTIFF cannot be read.", call. = FALSE)
  }

  noaa_spatraster_to_bathy(raster)
}

noaa_spatraster_to_bathy <- function(x) {
  xyz <- terra::as.data.frame(x, xy = TRUE, na.rm = FALSE)
  if (ncol(xyz) < 3) {
    stop("The NOAA GeoTIFF does not contain depth values.", call. = FALSE)
  }
  xyz <- data.frame(
    lon = xyz[[1]],
    lat = xyz[[2]],
    depth = xyz[[3]]
  )
  as_bathy(xyz)
}

noaa_export_image_url <- function(left, right, bottom, top, ncol, nrow, layer) {
  rendering_rule <- utils::URLencode('{"rasterFunction":"none"}', reserved = TRUE)
  mosaic_rule <- utils::URLencode(
    paste0('{"where":"Name=\'', layer, '\'"}'),
    reserved = TRUE
  )
  paste0(
    "https://gis.ngdc.noaa.gov/arcgis/rest/services/DEM_mosaics/DEM_all/ImageServer/exportImage",
    "?bbox=", noaa_fmt(left), ",", noaa_fmt(bottom), ",", noaa_fmt(right), ",", noaa_fmt(top),
    "&bboxSR=4326",
    "&size=", as.integer(ncol), ",", as.integer(nrow),
    "&imageSR=4326",
    "&format=tiff",
    "&pixelType=F32",
    "&interpolation=+RSP_NearestNeighbor",
    "&compression=LZ77",
    "&renderingRule=", rendering_rule,
    "&mosaicRule=", mosaic_rule,
    "&f=image"
  )
}

noaa_fmt <- function(x) {
  format(x, scientific = FALSE, trim = TRUE, digits = 15)
}
