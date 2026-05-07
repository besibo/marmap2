\name{bathy_to_spatraster}
\alias{bathy_to_spatraster}
\alias{as_terra_bathy}
\title{Convert a bathy object to a terra SpatRaster}
\usage{
bathy_to_spatraster(x, crs = "EPSG:4326")

as_terra_bathy(x, crs = "EPSG:4326")
}
\arguments{
\item{x}{An object inheriting from class \code{bathy}.}
\item{crs}{Coordinate reference system assigned to the returned raster.}
}
\value{
A \code{terra::SpatRaster} object.
}
\description{
Converts the historical \code{bathy} matrix representation to a modern
\code{terra::SpatRaster} while preserving grid extent and orientation.
}
\examples{
if (requireNamespace("terra", quietly = TRUE)) {
  data(hawaii)
  r <- bathy_to_spatraster(hawaii)
}
}
