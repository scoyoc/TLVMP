## ----true_setup, eval=TRUE, echo=FALSE, message=FALSE, warning=FALSE----------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library("raindancer")
library("dataprocessR")

## ----setup, eval=FALSE, echo = TRUE, results='markup'-------------------------
#  # Install the devtools package
#  if (!"devtools" %in% installed.packages()[, "Package"]) {
#    # install.packages("devtools")
#  }
#  
#  # Install dataprocessR
#  devtools::install_github("scoyoc/dataprocessR")
#  library("dataprocessR")
#  
#  # Install raindancer
#  devtools::install_github("scoyoc/raindancer")
#  library("raindancer")

## ----connect_db, eval=FALSE, echo=TRUE, results='markup'----------------------
#  dat_dir <- system.file("extdata", package = "dataprocessR")
#  db_name <- "example_db.accdb"
#  my_db <- RODBC::odbcConnectAccess2007(paste(dat_dir, db_name, sep = "/"))

## ----internal_DB, eval=TRUE, echo=FALSE, warning=FALSE, message=FALSE---------
dat_dir <- system.file("extdata", package = "dataprocessR")
db_dir <- "C:/Users/mvanscoyoc/Documents/R/dataprocessR/exec"
db_name <- "example_db.accdb"
my_db <- RODBC::odbcConnectAccess2007(paste(db_dir, db_name, sep = "/"))

## ----veg_files, eval=TRUE, echo=TRUE, results='markup'------------------------
veg_files <- list.files(path = dat_dir, pattern = ".xls", full.names = TRUE, 
                        recursive = FALSE)
print(basename(veg_files))

## ----import_example, eval=FALSE, echo=TRUE------------------------------------
#  dat <- import_xls("C:/path/to/data")

## ----import_xls, eval=TRUE, echo=TRUE, results='markup'-----------------------
dat <- import_xls(veg_files[1])
paste("class = ", class(dat)); paste("length = ", length(dat)); names(dat)

## ----file_info, eval=TRUE, echo=TRUE, results='markup'------------------------
str(dat$file_info)

## ----sampling_event, eval=TRUE, echo=TRUE, results='markup'-------------------
str(dat$sampling_event)

## ----data_raw, eval=TRUE, echo=TRUE, results='markup'-------------------------
str(dat$data)

## ----veg_tables, eval=TRUE, echo=TRUE, results='markup'-----------------------
veg_data_table = "tblData"
veg_sampling_event_table = "tblSamplingEvent"
veg_import_table = "tblImportRecord"

## ----export_xls, eval=TRUE, echo=TRUE, results='markup'-----------------------
export_xls(veg_files[1], 
           my_db = my_db,
           data_table = veg_data_table,
           sampling_event_table = veg_sampling_event_table,
           import_table = veg_import_table, 
           verbose = TRUE, view = FALSE)

## ----process_veg_dir, eval=TRUE, echo=TRUE, results='markup'------------------
lapply(veg_files[2:length(veg_files)], function(this_xls){
  export_xls(my_xls = this_xls, 
             my_db = my_db,
             data_table = veg_data_table,
             sampling_event_table = veg_sampling_event_table,
             import_table = veg_import_table, 
             verbose = TRUE, view = FALSE)
})

## ----veg_import_table, eval=TRUE, echo=TRUE, results='markup'-----------------
dplyr::glimpse(RODBC::sqlFetch(my_db, veg_import_table, 
                               stringsAsFactors = F))

## ----veg_sample_event_table, eval=TRUE, echo=TRUE, results='markup'-----------
dplyr::glimpse(RODBC::sqlFetch(my_db, veg_sampling_event_table,
                               stringsAsFactors = F))

## ----veg_data_table, eval=TRUE, echo=TRUE, results='markup'-------------------
head(RODBC::sqlFetch(my_db, veg_data_table, stringsAsFactors = F))

## ----wx_files, eval=TRUE, echo=TRUE, results='markup'-------------------------
wx_files <- list.files(path = dat_dir, pattern = ".csv", full.names = TRUE,
                       recursive = FALSE)
print(basename(wx_files))

## ----wx_tables, eval=TRUE, echo=TRUE, results='markup'------------------------
# Set table names
wx_import_table = "tblWxImportLog"
wx_raw_data_table = "tblWxData_raw"
wx_prcp_data_table = "tblWxData_PRCP"
wx_temp_rh_data_table = "tblWxData_TEMP_RH"
wx_details_table = "tblWxLoggerDetails"

## ----export_hobo, eval=TRUE, echo=TRUE, results='markup'----------------------
export_hobo(wx_files[1], 
            my_db = my_db,
            import_table = wx_import_table,
            raw_data_table = wx_raw_data_table,
            prcp_data_table = wx_prcp_data_table,
            temp_rh_data_table = wx_temp_rh_data_table,
            details_table = wx_details_table,
            verbose = TRUE, 
            view = FALSE)

## ----process_wx_dir, eval=TRUE, echo=TRUE, results='markup'-------------------
lapply(wx_files[2:length(wx_files)], function(this_file){
  export_hobo(this_file, 
              my_db = my_db,
              import_table = wx_import_table,
              raw_data_table = wx_raw_data_table,
              prcp_data_table = wx_prcp_data_table,
              temp_rh_data_table = wx_temp_rh_data_table,
              details_table = wx_details_table,
              verbose = TRUE, 
              view = FALSE)
})

## ----wx_import_table, eval=TRUE, echo=TRUE, results='markup'------------------
dplyr::glimpse(RODBC::sqlFetch(my_db, wx_import_table, 
                               stringsAsFactors = F))

## ----wx_sample_event_table, eval=TRUE, echo=TRUE, results='markup'------------
head(RODBC::sqlFetch(my_db, wx_details_table, stringsAsFactors = F))

## ----wx_prcp_data, eval=TRUE, echo=TRUE, results='markup'---------------------
head(RODBC::sqlFetch(my_db, wx_prcp_data_table, stringsAsFactors = F))

## ----wx_temp_data, eval=TRUE, echo=TRUE, results='markup'---------------------
head(RODBC::sqlFetch(my_db, wx_temp_rh_data_table, stringsAsFactors = F))

## ----wx_raw_data, eval=TRUE, echo=TRUE, results='markup'----------------------
head(RODBC::sqlFetch(my_db, wx_raw_data_table, stringsAsFactors = F))

## ----troubleshooting, eval=FALSE, echo=TRUE-----------------------------------
#  #-- Isolate file and begin troubleshooting
#  file_index <- 11                        # Index number of the trouble file. This number will change.
#  file_list[file_index]                   # Prints name of trouble file.
#  my_file <- file_list[file_index]        # Assigns file path to R object.
#  raindancer::import_hobo(my_file)   # Test raindancer function for error.
#  
#  #-- Problems with parsing date-time
#  read.table(my_file, sep = ",", skip = 1) |> # skip argument may differ
#    tibble::tibble() |>
#    dplyr::rename("DateTime" = V2) |> # Variable name (V2) may differ
#    dplyr::mutate("DateTime" = lubridate::parse_date_time(DateTime,
#                                                          orders = "%m/%d/%y hh:mm"))
#  
#  #-- Problems with csv file headers
#  # Play around with skip argument until csv read into R correctly
#  read.csv(my_file, skip = 1)  |> tibble::tibble()
#  readr::read_csv(my_file, skip = 1, show_col_types = FALSE)  |> tibble::tibble()
#  
#  #-- Testing data summary functions
#  raindancer::import_hobo(my_file) |> raindancer::raindance(dat)
#  raindancer::import_hobo(my_file) |> raindancer::sundance(dat)
#  
#  raindancer::import_hobo(file_list[file_index]) |> raindancer::process_hobo()
#  
#  # Continue processing files in directory after an invalid file breaks the
#  #    lapply() is sorted out.
#  # After troubleshooting the file that caused export_hobo() to  crash.
#  # Change the number to the index of the next file and continue to process the
#  #    rest of the files in the directory.
#  lapply(file_list[file_index:length(file_list)], function(this_file){
#    export_hobo(this_file, my_db = my_db,
#                import_table = import_table,
#                raw_data_table = raw_data_table,
#                prcp_data_table = prcp_data_table,
#                temp_rh_data_table = temp_rh_data_table,
#                details_table = details_table,
#                view = FALSE)
#  })

