#-- Delete NAMESPACE file and man directory
file.remove("NAMESPACE")
unlink("man", recursive = T)
#-- Create new NAMESPACE file and man directory
devtools::document()
devtools::check()
devtools::load_all()

# Testing weather data functions
library("dataprocessR")

# Connect to DB
# RODBC::odbcClose(my_db); rm(my_db)
my_db <- RODBC::odbcConnectAccess2007("VegTest.accdb")

# List files
my_dir <- "L:/LTVMP/Data/Weather Data/2008"
file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
                        recursive = FALSE)
# Select file and process data
my_file <- file_list[10]

import_hobo_to_db(my_file = my_file, my_db = my_db,
                  import_table = "tbl_import_table",
                  raw_data_table = "tbl_raw_data",
                  data_table = "tbl_data",
                  details_table = "tbl_details")

#-- Batch Processing --
lapply(file_list[1:5], function(this_file){
  import_hobo_to_db(this_file, my_db = my_db,
                    import_table = "import_table",
                    raw_data_table = "raw_data",
                    data_table = "data",
                    details_table = "details")
})
