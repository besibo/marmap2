#' Import bathymetric data from the NOAA server
#'
#' @description
#' Imports bathymetric data from the NOAA server, given coordinate bounds and resolution.
#'
#' @rdname mar_get_noaa_bathy
#' @usage
#' mar_get_noaa_bathy(lon1, lon2, lat1, lat2, resolution = 4,
#'               keep = FALSE, antimeridian = FALSE, path = NULL)
#' @param lon1 first longitude of the area for which bathymetric data will be downloaded
#' @param lon2 second longitude of the area for which bathymetric data will be downloaded
#' @param lat1 first latitude of the area for which bathymetric data will be downloaded
#' @param lat2 second latitude of the area for which bathymetric data will be downloaded
#' @param resolution resolution of the grid, in minutes (default is 4)
#' @param keep whether to write the data downloaded from NOAA into a file (default is FALSE)
#' @param antimeridian whether the area should include the antimeridian (longitude 180 or -180). See details.
#' @param path Where should bathymetric data be downloaded to if \code{keep = TRUE}? Where should \code{mar_get_noaa_bathy()} look up for bathymetric data already downloaded? Defaults to the current working directory.
#'
#' @details
#' \code{mar_get_noaa_bathy} queries the ETOPO 2022 database hosted on the NOAA website, given the coordinates of the area of interest and desired resolution. Users have the option of directly writing the downloaded data into a file (\code{keep = TRUE} argument ; see below). If an identical query is performed (i.e. using identical lat-long and resolution), \code{mar_get_noaa_bathy} will load data from the file previously written to the disk instead of querying the NOAA database. This behavior should be used preferentially (1) to reduce the number of uncessary queries to the NOAA website, and (2) to reduce data load time. If the user wants to make multiple, identical queries to the NOAA website without loading the data written to disk, the data file name must be modified by the user. Alternatively, the data file can be moved outside of the present working directory.
#'
#' \code{mar_get_noaa_bathy} allows users to download bathymetric data in the antimeridian region when \code{antimeridian=TRUE}. The antimeridian is the 180th meridian and is located about in the middle of the Pacific Ocean, east of New Zealand and Fidji, west of Hawaii and Tonga. For a given pair of longitude values, e.g. -150 (150 degrees West) and 150 (degrees East), you have the possibility to get data for 2 distinct regions: the area centered on the antimeridian (60 degrees wide, when \code{antimeridian = TRUE}) or the area centered on the prime meridian (300 degrees wide, when \code{antimeridian = FALSE}). It is recommended to use \code{keep = TRUE} in combination with \code{antimeridian = TRUE} since gathering data for an area around the antimeridian requires two distinct queries to NOAA servers.
#'
#' @return
#' The output of \code{mar_get_noaa_bathy} is a matrix of class \code{bathy}, which dimensions depends on the resolution of the grid uploaded from the NOAA server. The class \code{bathy} has its own methods for summarizing and plotting the data. If \code{keep=TRUE}, a csv file containing the downloaded data is produced. This file is named using the following format: 'marmap_coord_COORDINATES_res_RESOLUTION.csv' (COORDINATES separated by semicolons, and the RESOLUTION in degrees).
#'
#' @references
#' NOAA National Centers for Environmental Information. 2022: ETOPO 2022 15 Arc-Second Global Relief Model. NOAA National Centers for Environmental Information. \doi{https://doi.org/10.25921/fd45-gt74}
#'
#' @author
#' Eric Pante and Benoit Simon-Bouhet
#'
#' @seealso
#' \code{\link{mar_read_bathy}}, \code{\link{mar_read_gebco_bathy}}, \code{\link{mar_plot_bathy}}
#'
#' @examples
#' \dontrun{
#' # you must have an internet connection. This line queries the NOAA ETOPO 2022 database
#' # for data from North Atlantic, for a resolution of 10 minutes.
#'
#' mar_get_noaa_bathy(lon1=-20,lon2=-90,lat1=50,lat2=20, resolution=10) -> a
#' plot(a, image=TRUE, deep=-6000, shallow=0, step=1000)
#'
#' # download speed for a matrix of 10 degrees x 10 degrees x 30 minutes
#' system.time(mar_get_noaa_bathy(lon1=0,lon2=10,lat1=0,lat2=10, resolution=30))
#' }
#' @export
#' @aliases getNOAA.bathy
mar_get_noaa_bathy <-
  function(lon1, lon2, lat1, lat2, resolution = 4, keep = FALSE, antimeridian = FALSE, path = NULL){

    if (lon1 == lon2) stop("The longitudinal range defined by lon1 and lon2 is incorrect")
    if (lat1 == lat2) stop("The latitudinal range defined by lat1 and lat2 is incorrect")
    if (lat1 > 90 | lat1 < -90 | lat2 > 90 | lat2 < -90) stop("Latitudes should have values between -90 and +90")
    if (lon1 < -180 | lon1 > 180 | lon2 < -180 | lon2 > 180) stop("Longitudes should have values between -180 and +180")
    if (resolution < 0) stop("The resolution must be greater than 0")

    # if (resolution < 1) resolution <- round(resolution/0.25) * 0.25

    if (resolution < 0.5) {
      resolution <- 0.25
    } else {
      if (resolution < 1) {
        resolution <- 0.5
      }
    }
    if (resolution == 0.25) database <- "27ETOPO_2022_v1_15s_bed_elev"
    if (resolution == 0.50) database <- "27ETOPO_2022_v1_30s_bed"
    if (resolution  > 0.50) database <- "27ETOPO_2022_v1_60s_bed"

    if (is.null(path)) path <- "."
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

      if ((ncell.lon.left + ncell.lon.right) < 2 & ncell.lat < 2) stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal and longitudinal ranges or the resolution (i.e. use a smaller res value)")
      if ((ncell.lon.left + ncell.lon.right) < 2) stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or the resolution (i.e. use a smaller resolution value)")
      if (ncell.lat < 2) stop("It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or the resolution (i.e. use a smaller resolution value)")

    } else {

      ncell.lon <- (x2 - x1) * 60 / resolution
      ncell.lat <- (y2 - y1) * 60 / resolution

      if (ncell.lon < 2 & ncell.lat < 2) stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal and longitudinal ranges or the resolution (i.e. use a smaller res value)")
      if (ncell.lon < 2) stop("It's impossible to fetch an area with less than one cell. Either increase the longitudinal range or the resolution (i.e. use a smaller resolution value)")
      if (ncell.lat < 2) stop("It's impossible to fetch an area with less than one cell. Either increase the latitudinal range or the resolution (i.e. use a smaller resolution value)")
    }

    fetch <- function(x1, y1, x2, y2, ncell.lon, ncell.lat) {
      ncell.lon <- floor(ncell.lon)
      ncell.lat <- floor(ncell.lat)
      x1 <- round(x1, 1)
      x2 <- round(x2, 1)
      y1 <- round(y1, 1)
      y2 <- round(y2, 1)
      WEB.REQUEST <- paste0("https://gis.ngdc.noaa.gov/arcgis/rest/services/DEM_mosaics/DEM_all/ImageServer/exportImage?bbox=", x1, ",", y1, ",", x2, ",", y2, "&bboxSR=4326&size=", ncell.lon, ",", ncell.lat,"&imageSR=4326&format=tiff&pixelType=F32&interpolation=+RSP_NearestNeighbor&compression=LZ77&renderingRule={%22rasterFunction%22:%22none%22}&mosaicRule={%22where%22:%22Name=%", database, "%27%22}&f=image")
      download.file(url = WEB.REQUEST, destfile = "tmp.tif", mode = "wb")
      dat <- suppressWarnings(try(raster::raster("tmp.tif"), silent = TRUE))
      dat <- mar_as_xyz(mar_as_bathy(dat))
      file.remove("tmp.tif")
      return(dat)
    }

    # Naming the file
    if (antimeridian) {
      FILE <- paste0("marmap_coord_", x1, ";", y1, ";", x2, ";", y2, "_res_", resolution, "_anti", ".csv")
    } else {
      FILE <- paste0("marmap_coord_", x1, ";", y1, ";", x2, ";", y2, "_res_", resolution, ".csv")
    }

    # If file exists in PATH, load it,
    if(FILE %in% list.files(path = path) ) {
      message("File already exists ; loading \'", FILE, "\'", sep = "")
      exisiting.bathy <- mar_read_bathy(paste0(path, "/", FILE), header = TRUE)
      return(exisiting.bathy)
    } else { # otherwise, fetch it on NOAA server

      if (antimeridian) {

        message("Querying NOAA database ...")
        message("This may take seconds to minutes, depending on grid size\n")
        left  <- fetch(l1, y1, l2, y2, ncell.lon.left, ncell.lat)
        right <- fetch(l3, y1, l4, y2, ncell.lon.right, ncell.lat)

        if (is(left, "try-error") | is(right, "try-error")) {
          stop("The NOAA server cannot be reached\n")
        } else {
          message("Building bathy matrix ...\n")
          left <- mar_as_bathy(left)
          left <- left[-nrow(left),]
          right <- mar_as_bathy(right)
          rownames(right) <- as.numeric(rownames(right)) + 360
          bath2 <- rbind(left, right)
          class(bath2) <- "bathy"
          bath <- mar_as_xyz(bath2)
        }

      } else {

        message("Querying NOAA database ...")
        message("This may take seconds to minutes, depending on grid size\n")
        bath <- fetch(x1, y1, x2, y2, ncell.lon, ncell.lat)
        if (is(bath,"try-error")) {
          stop("The NOAA server cannot be reached\n")
        } else {
          message("Building bathy matrix ...")
          bath2 <- mar_as_bathy(bath)
        }
      }

      if (keep) {
        write.table(bath, file = paste0(path,"/",FILE), sep = ",", quote = FALSE, row.names = FALSE)
      }

      return(bath2)
    }
  }

#' @rdname mar_get_noaa_bathy
#' @export
getNOAA.bathy <- mar_get_noaa_bathy
