\name{mar_get_NOAA}
\alias{mar_get_NOAA}
\title{Download bathymetry from NOAA ETOPO 2022}
\usage{
mar_get_NOAA(lon1, lon2, lat1, lat2, resolution = 4, keep = FALSE,
  antimeridian = FALSE, path = NULL)
}
\arguments{
\item{lon1, lon2}{Longitude bounds in decimal degrees.}
\item{lat1, lat2}{Latitude bounds in decimal degrees.}
\item{resolution}{Requested grid resolution in arc-minutes.}
\item{keep}{Whether to write the downloaded xyz table to disk.}
\item{antimeridian}{Whether the requested region crosses the antimeridian.}
\item{path}{Directory used for cached csv files when \code{keep = TRUE}.}
}
\value{
An object of class \code{bathy}.
}
\description{
Prototype replacement for \code{getNOAA.bathy()} using the NOAA ArcGIS
ETOPO 2022 image service.
}
