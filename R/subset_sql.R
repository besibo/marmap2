#' Creating and querying local SQL database for bathymetric data
#'
#' @description
#' \code{subset_sql} queries the local SQL database created with \code{set_sql} to extract smaller data subsets.
#'
#' @rdname subset_sql
#' @usage
#' set_sql(bathy, header = TRUE, sep = ",", db.name = "bathy_db")
#' subset_sql(min_lon, max_lon, min_lat, max_lat, db.name = "bathy_db")
#' @param bathy A text file containing a comma-separated, three-column table with longitude, latitude and depth data (no default)
#' @param header does the xyz file contains a row of column names (default = TRUE)
#' @param sep character separating columns in the xyz file, (default=",")
#' @param min_lon minimum longitude of the data to be extracted from the local SQL database
#' @param max_lon maximum longitude of the data to be extracted from the local SQL database
#' @param min_lat minimum latitude of the data to be extracted from the local SQL database
#' @param max_lat maximum latitude of the data to be extracted from the local SQL database
#' @param db.name The name of (or path to) the SQL database to be created on disk by \code{set_sql} or from which \code{subset_sql} will extract data ("bathy_db" by default)
#'
#' @details
#' Functions \code{set_sql} and \code{subset_sql} were built to work together. \code{set_sql} builds an SQL database and saves it on disk. \code{subset_sql} queries that local database and the fields \code{min_lon}, \code{max_lon}, etc, are used to extract a subset of the database. The functions were built as two entities so that multiple queries can be done multiple times, without re-building the database each time. These functions were designed to access the very large (>5Go) ETOPO 2022 file that can be downloaded from the NOAA website (\url{https://www.ncei.noaa.gov/products/etopo-global-relief-model})
#'
#' @return
#' \code{set_sql} returns \code{TRUE} if the database was successfully created. \code{subset_sql} returns a matrix of class \code{bathy} that can directly be used with \code{plot_bathy}.
#'
#' @references
#' NOAA National Centers for Environmental Information. 2022: ETOPO 2022 15 Arc-Second Global Relief Model. NOAA National Centers for Environmental Information. \doi{https://doi.org/10.25921/fd45-gt74}
#'
#' @author
#' Eric Pante
#'
#' @examples
#' \dontrun{
#' # load NW Atlantic data
#' data(nw.atlantic)
#'
#' # write data to disk as a comma-separated text file
#' write.table(nw.atlantic, "NW_Atlantic.csv", sep=",", quote=FALSE, row.names=FALSE)
#'
#' # prepare SQL database
#' set_sql(bathy="NW_Atlantic.csv")
#'
#' # uses data from the newly-created SQL database:
#' subset_sql(min_lon=-70,max_lon=-50,
#'              min_lat=35, max_lat=41) -> test
#'
#' # visualize the results (of class bathy)
#' summary(test)
#'
#' # remove temporary database and CSV files
#' system("rm bathy_db") # remove file, for unix-like systems
#' system("rm NW_Atlantic.csv") # remove file, for unix-like systems
#' }
#' @export
subset_sql = function(min_lon, max_lon, min_lat, max_lat, db.name="bathy_db"){

	# prepare ("connect") SQL database
	con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db.name)

	cn <- DBI::dbListFields(con,"bathy_db")

	# build SQL request: 
    paste("SELECT * from bathy_db where ", cn[1], " >", min_lon,
    	  "and ", cn[1], " <", max_lon," and ", cn[2], " >",min_lat," and ", cn[2], " <",max_lat) -> REQUEST
    
    # send request and retrieve results
    res <- DBI::dbSendQuery(con, REQUEST)
    data <- DBI::fetch(res, n = -1)
	DBI::dbClearResult(res)
	DBI::dbDisconnect(con)
	if (!is.numeric(data[,3])) data[,3] <- suppressWarnings(as.numeric(data[,3]))
    return(as_bathy(data))
}

