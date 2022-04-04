# dataprocessR

This package processes data collected in the field and exports them to the Southeast Utah Group (SEUG) Long-term Vegetation Monitoring Program (LTVMP) database. 
Plant and ground cover data are collected in the field using paper datasheets, then transcribed into Excel workbooks. 
This package imports the workbook files into R, restructures the data from wide to long format, then exports them to the database.
Onset data loggers collect temperature, relative humidity, and precipitation data that are exported to comma delimited files (*.csv) using the HOBOware application from Onset. 
The [raindancer](https://github.com/scoyoc/raindancer) package is used to import data from the Onset data loggers into R and summarize them; this package then exports the processed data to the database.

Version: 0.2.0

Depends: R (>= 4.0)

Imports: dplyr, glue, lubridate, raindancer, RODBC, stringr, tibble, tidyr

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
library("dataprocessR")

# Connect to DB
my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")

#-- Process weather data
# List files
my_dir <- "C:/path/to/data"
file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
                        recursive = FALSE)

# Process file and save to database
export_hobo(my_file = file_list[1], my_db = my_db,
            import_table = "tbl_import_log",
            raw_data_table = "tbl_raw_data",
            prcp_data_table = "tbl_prcp_data",
            temp_rh_data_table = "tbl_temp_rh_data",
            details_table = "tbl_logger_details")

# Batch processing several files
lapply(file_list[2:5], function(this_file){
  export_hobo(this_file, my_db = my_db,
              import_table = "tbl_import_log",
              raw_data_table = "tbl_raw_data",
              prcp_data_table = "tbl_prcp_data",
              temp_rh_data_table = "tbl_temp_rh_data",
              details_table = "tbl_logger_details",
              view = FALSE)
})

# Close database
RODBC::odbcClose(my_db); rm(my_db)
```

