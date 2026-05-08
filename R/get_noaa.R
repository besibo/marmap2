#' Download bathymetry from NOAA ETOPO 2022
#'
#' @description
#' Prototype replacement for \code{get_noaa()} using the NOAA ArcGIS
#' ETOPO 2022 image service.
#'
#' @rdname get_noaa
#' @param lon1 Western or first longitude bound in decimal degrees.
#' @param lon2 Eastern or second longitude bound in decimal degrees.
#' @param lat1 Southern or first latitude bound in decimal degrees.
#' @param lat2 Northern or second latitude bound in decimal degrees.
#' @param lon Numeric vector of length 2 giving the longitude bounds. This is an
#'   alternative to \code{lon1} and \code{lon2}.
#' @param lat Numeric vector of length 2 giving the latitude bounds. This is an
#'   alternative to \code{lat1} and \code{lat2}.
#' @param resolution Requested grid resolution in arc-minutes.
#' @param class Character. Class of the returned object. Use \code{"tbl"}
#'   (default) to return a tibble with columns \code{lon}, \code{lat}, and
#'   \code{depth}; use \code{"bathy"} to return a historical matrix of class
#'   \code{bathy}.
#' @param keep Whether to write the downloaded xyz table to disk.
#' @param antimeridian Whether the requested region crosses the antimeridian.
#' @param path Directory used for cached csv files when \code{keep = TRUE}.
#'
#' @return
#' A tibble by default, or an object of class \code{bathy} when
#' \code{class = "bathy"}.
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
