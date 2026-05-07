# Creating and querying local SQL database for bathymetric data

`subset_sql` queries the local SQL database created with `set_sql` to
extract smaller data subsets.

## Usage

``` r
set_sql(bathy, header = TRUE, sep = ",", db.name = "bathy_db")

set_sql(bathy, header = TRUE, sep = ",", db.name = "bathy_db")
subset_sql(min_lon, max_lon, min_lat, max_lat, db.name = "bathy_db")
```

## Arguments

  - bathy:
    
    A text file containing a comma-separated, three-column table with
    longitude, latitude and depth data (no default)

  - header:
    
    does the xyz file contains a row of column names (default = TRUE)

  - sep:
    
    character separating columns in the xyz file, (default=",")

  - db.name:
    
    The name of (or path to) the SQL database to be created on disk by
    `set_sql` or from which `subset_sql` will extract data ("bathy\_db"
    by default)

  - min\_lon:
    
    minimum longitude of the data to be extracted from the local SQL
    database

  - max\_lon:
    
    maximum longitude of the data to be extracted from the local SQL
    database

  - min\_lat:
    
    minimum latitude of the data to be extracted from the local SQL
    database

  - max\_lat:
    
    maximum latitude of the data to be extracted from the local SQL
    database

## Value

`set_sql` returns `TRUE` if the database was successfully created.
`subset_sql` returns a matrix of class `bathy` that can directly be used
with `plot_bathy`.

## Details

Functions `set_sql` and `subset_sql` were built to work together.
`set_sql` builds an SQL database and saves it on disk. `subset_sql`
queries that local database and the fields `min_lon`, `max_lon`, etc,
are used to extract a subset of the database. The functions were built
as two entities so that multiple queries can be done multiple times,
without re-building the database each time. These functions were
designed to access the very large (\>5Go) ETOPO 2022 file that can be
downloaded from the NOAA website
(<https://www.ncei.noaa.gov/products/etopo-global-relief-model>)

## References

NOAA National Centers for Environmental Information. 2022: ETOPO 2022 15
Arc-Second Global Relief Model. NOAA National Centers for Environmental
Information.
[doi:10.25921/fd45-gt74](https://doi.org/10.25921/fd45-gt74)

## Author

Eric Pante

## Examples

``` r
if (FALSE) { # \dontrun{
# load NW Atlantic data
data(nw.atlantic)

# write data to disk as a comma-separated text file
write.table(nw.atlantic, "NW_Atlantic.csv", sep=",", quote=FALSE, row.names=FALSE)

# prepare SQL database
set_sql(bathy="NW_Atlantic.csv")

# uses data from the newly-created SQL database:
subset_sql(min_lon=-70,max_lon=-50,
             min_lat=35, max_lat=41) -> test

# visualize the results (of class bathy)
summary(test)

# remove temporary database and CSV files
system("rm bathy_db") # remove file, for unix-like systems
system("rm NW_Atlantic.csv") # remove file, for unix-like systems
} # }
```
