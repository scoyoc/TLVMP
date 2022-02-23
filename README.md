# dataprocessR

This package standardizes raw data collected in the field and uploads them to the Southeast Utah Group (SEUG) Long-term Vegetation Monitoing Program (LTVMP) database. 
Plant and ground cover data are collected in the field using paper datasheets, then transcribed into Excel workbooks. 
Onset data loggers collect temperature, relative humidity, and precipitation data that are exported to comma delimited files (*.csv) using the HOBOware application from Onset. 
This package imports the workbooks and *.csv files into R, than standardizes the data before exporting them to the database.

Currently, the weather data process is developed for the *.csv files from Hoboware.
Excel workbook processing is under development.

Version: 0.0.1

Depends: R (>= 4.0)

Imports: dplyr, glue, lubridate, dataprocessR, RODBC, stringr, tibble, tidyr

Author: Matthew Van Scoyoc

Maintainer: Matthew Van Scoyoc

Issues: [https://github.com/scoyoc/dataprocessR/issues](https://github.com/scoyoc/dataprocessR/issues)

License: MIT + file [LICENSE](https://github.com/scoyoc/dataprocessR/blob/master/LICENSE.md)

URL: [https://github.com/scoyoc/dataprocessR](https://github.com/scoyoc/dataprocessR)

Documentation: Help pages for now. A Vignette is planned for future releases.

## Installation

``` r
devtools::install_github("scoyoc/dataprocessR")
```

## Examples
``` r
# Testing weather data functions
library("dataprocessR")

# Connect to DB
my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")

# List files
my_dir <- "C:/path/to/data"
file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
                        recursive = FALSE)
# Select file
my_file <- file_list[10]

# Process file and save to database
import_hobo_to_db(my_file = my_file, my_db = my_db,
                  import_table = "tbl_import_table",
                  raw_data_table = "tbl_raw_data",
                  data_table = "tbl_data",
                  details_table = "tbl_details")

#-- Batch Processing --
lapply(file_list[1:5], function(this_file){
  import_hobo_to_db(this_file, my_db = my_db,
                    import_table = "tbl_import_table",
                    raw_data_table = "tbl_raw_data",
                    data_table = "tbl_data",
                    details_table = "tbl_details")
})

# Close database
RODBC::odbcClose(my_db); rm(my_db)
```

