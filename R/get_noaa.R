#' Download bathymetry from NOAA ETOPO 2022
#'
#' @description
#' Imports bathymetric and topographic data from the NOAA ETOPO 2022 image
#' service, given coordinate bounds and a requested spatial resolution.
#'
#' @details
#' \code{get_noaa()} queries the ETOPO 2022 database hosted by NOAA, using the
#' coordinates of the area of interest and the desired resolution. The function
#' uses the NOAA ArcGIS image service and returns a long tibble by default, or a
#' matrix of class \code{bathy} when \code{class = "bathy"}.
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
#' The order of longitude and latitude bounds does not matter: \code{get_noaa()}
#' sorts the coordinate bounds internally before querying NOAA. Longitude and
#' latitude bounds can be supplied either as \code{lon1}, \code{lon2},
#' \code{lat1}, \code{lat2}, or with the shorter vector syntax
#' \code{lon = c(lon1, lon2)} and \code{lat = c(lat1, lat2)}.
#'
#' @rdname get_noaa
#' @param lon1 First longitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees.
#' @param lon2 Second longitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees.
#' @param lat1 First latitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees.
#' @param lat2 Second latitude bound of the area for which bathymetric data will
#'   be downloaded, in decimal degrees.
#' @param lon Numeric vector of length 2 giving the longitude bounds. This is an
#'   alternative to \code{lon1} and \code{lon2}.
#' @param lat Numeric vector of length 2 giving the latitude bounds. This is an
#'   alternative to \code{lat1} and \code{lat2}.
#' @param resolution Requested grid resolution in arc-minutes. Defaults to
#'   \code{4}.
#' @param class Character. Class of the returned object. Use \code{"tbl"}
#'   (default) to return a tibble with columns \code{lon}, \code{lat}, and
#'   \code{depth}; use \code{"bathy"} to return a historical matrix of class
#'   \code{bathy}.
#' @param keep Logical. Whether to write the downloaded xyz table to disk.
#'   Defaults to \code{FALSE}.
#' @param antimeridian Logical. Whether the requested region crosses the
#'   antimeridian, longitude 180 or -180.
#' @param path Directory used for cached csv files when \code{keep = TRUE}, and
#'   where \code{get_noaa()} looks for already downloaded matching data. Defaults
#'   to the current working directory.
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
#'   resolution = 10,
#'   class = "tbl"
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
#'   antimeridian = TRUE,
#'   class = "tbl",
#'   keep = TRUE
#' )
#' }
#' @export
get_noaa <-
  function(
    lon1 = NULL,
    lon2 = NULL,
    lat1 = NULL,
    lat2 = NULL,
    resolution = 4,
    class = c("tbl", "bathy"),
    keep = FALSE,
    antimeridian = FALSE,
    path = NULL,
    lon = NULL,
    lat = NULL
  ) {
    output_class <- match.arg(class)
    bounds <- resolve_lon_lat_args(lon1, lon2, lat1, lat2, lon, lat)
    lon1 <- bounds$lon1
    lon2 <- bounds$lon2
    lat1 <- bounds$lat1
    lat2 <- bounds$lat2

    if (lon1 == lon2) {
      stop("The longitudinal range defined by lon1 and lon2 is incorrect")
    }
    if (lat1 == lat2) {
      stop("The latitudinal range defined by lat1 and lat2 is incorrect")
    }
    if (lat1 > 90 | lat1 < -90 | lat2 > 90 | lat2 < -90) {
      stop("Latitudes should have values between -90 and +90")
    }
    if (lon1 < -180 | lon1 > 180 | lon2 < -180 | lon2 > 180) {
      stop("Longitudes should have values between -180 and +180")
    }
    if (resolution < 0) {
      stop("The resolution must be greater than 0")
    }

    # if (resolution < 1) resolution <- round(resolution/0.25) * 0.25

    if (resolution < 0.5) {
      resolution <- 0.25
    } else {
      if (resolution < 1) {
        resolution <- 0.5
      }
    }
    if (resolution == 0.25) {
      database <- "27ETOPO_2022_v1_15s_bed_elev"
    }
    if (resolution == 0.50) {
      database <- "27ETOPO_2022_v1_30s_bed"
    }
    if (resolution > 0.50) {
      database <- "27ETOPO_2022_v1_60s_bed"
    }

    if (is.null(path)) {
      path <- "."
    }
    x1 = x2 = y1 = y2 = NULL

    if (lon1 < lon2) {
      x1 <- lon1
      x2 <- lon2
    } else {
      x2 <- lon1
      x1 <- lon2
    }

    if (lat1 < lat2) {
      y1 <- lat1
      y2 <- lat2
    } else {
      y2 <- lat1
      y1 <- lat2
    }

    if (antimeridian) {
      if (x1 == -180 & x2 == 180) {
        x1 <- 0
        x2 <- 0
      }

      l1 <- x2
      l2 <- 180
      l3 <- -180
      l4 <- x1

      ncell.lon.left <- (l2 - l1) * 60 / resolution
      ncell.lon.right <- (l4 - l3) * 60 / resolution
      ncell.lat <- (y2 - y1) * 60 / resolution

      if ((ncell.lon.left + ncell.lon.right) < 2 & ncell.lat < 2) {
        stop(
          "It's impossible to fetch an area with less than one cell. Either increase the longitudinal and longitudinal ranges or the resolution (i.e. use a smaller res value)"
        )
      }
      if ((ncell.lon.left + ncell.lon.right) < 2) {
        stop(
          "It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or the resolution (i.e. use a smaller resolution value)"
        )
      }
      if (ncell.lat < 2) {
        stop(
          "It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or the resolution (i.e. use a smaller resolution value)"
        )
      }
    } else {
      ncell.lon <- (x2 - x1) * 60 / resolution
      ncell.lat <- (y2 - y1) * 60 / resolution

      if (ncell.lon < 2 & ncell.lat < 2) {
        stop(
          "It's impossible to fetch an area with less than one cell. Either increase the longitudinal and longitudinal ranges or the resolution (i.e. use a smaller res value)"
        )
      }
      if (ncell.lon < 2) {
        stop(
          "It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or the resolution (i.e. use a smaller resolution value)"
        )
      }
      if (ncell.lat < 2) {
        stop(
          "It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or the resolution (i.e. use a smaller resolution value)"
        )
      }
    }

    fetch <- function(x1, y1, x2, y2, ncell.lon, ncell.lat) {
      ncell.lon <- floor(ncell.lon)
      ncell.lat <- floor(ncell.lat)
      x1 <- round(x1, 1)
      x2 <- round(x2, 1)
      y1 <- round(y1, 1)
      y2 <- round(y2, 1)
      WEB.REQUEST <- paste0(
        "https://gis.ngdc.noaa.gov/arcgis/rest/services/DEM_mosaics/DEM_all/ImageServer/exportImage?bbox=",
        x1,
        ",",
        y1,
        ",",
        x2,
        ",",
        y2,
        "&bboxSR=4326&size=",
        ncell.lon,
        ",",
        ncell.lat,
        "&imageSR=4326&format=tiff&pixelType=F32&interpolation=+RSP_NearestNeighbor&compression=LZ77&renderingRule={%22rasterFunction%22:%22none%22}&mosaicRule={%22where%22:%22Name=%",
        database,
        "%27%22}&f=image"
      )
      download.file(url = WEB.REQUEST, destfile = "tmp.tif", mode = "wb")
      dat <- suppressWarnings(try(raster::raster("tmp.tif"), silent = TRUE))
      dat <- as_xyz(as_bathy(dat))
      file.remove("tmp.tif")
      return(dat)
    }

    # Naming the file
    if (antimeridian) {
      FILE <- paste0(
        "marmap_coord_",
        x1,
        ";",
        y1,
        ";",
        x2,
        ";",
        y2,
        "_res_",
        resolution,
        "_anti",
        ".csv"
      )
    } else {
      FILE <- paste0(
        "marmap_coord_",
        x1,
        ";",
        y1,
        ";",
        x2,
        ";",
        y2,
        "_res_",
        resolution,
        ".csv"
      )
    }

    # If file exists in PATH, load it,
    if (FILE %in% list.files(path = path)) {
      message("File already exists ; loading \'", FILE, "\'", sep = "")
      existing_bathy <- read_bathy(paste0(path, "/", FILE), header = TRUE)
      if (identical(output_class, "tbl")) {
        return(bathy_to_tbl(existing_bathy))
      }
      return(existing_bathy)
    } else {
      # otherwise, fetch it on NOAA server

      if (antimeridian) {
        message("Querying NOAA database ...")
        message("This may take seconds to minutes, depending on grid size\n")
        left <- fetch(l1, y1, l2, y2, ncell.lon.left, ncell.lat)
        right <- fetch(l3, y1, l4, y2, ncell.lon.right, ncell.lat)

        if (is(left, "try-error") | is(right, "try-error")) {
          stop("The NOAA server cannot be reached\n")
        } else {
          message("Building bathy matrix ...\n")
          left <- as_bathy(left)
          left <- left[-nrow(left), ]
          right <- as_bathy(right)
          rownames(right) <- as.numeric(rownames(right)) + 360
          bath2 <- rbind(left, right)
          class(bath2) <- "bathy"
          bath <- as_xyz(bath2)
        }
      } else {
        message("Querying NOAA database ...")
        message("This may take seconds to minutes, depending on grid size\n")
        bath <- fetch(x1, y1, x2, y2, ncell.lon, ncell.lat)
        if (is(bath, "try-error")) {
          stop("The NOAA server cannot be reached\n")
        } else {
          message("Building bathy matrix ...")
          bath2 <- as_bathy(bath)
        }
      }

      if (keep) {
        write.table(
          bath,
          file = paste0(path, "/", FILE),
          sep = ",",
          quote = FALSE,
          row.names = FALSE
        )
      }

      if (identical(output_class, "tbl")) {
        return(bathy_to_tbl(bath2))
      }
      return(bath2)
    }
  }
