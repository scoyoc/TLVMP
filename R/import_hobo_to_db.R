#' Import Onset Hobo data into Access Database
#'
#' This function processes data from Onset HOBOware and exports them to a
#'     Microsoft Access Database.
#'
#' @param my_file A character string of the complete file path of your *.csv
#'     file.
#' @param my_db A connected database from \code{\link{RODBC}}.
#' @param import_table A character string of the name of the import log table.
#' @param raw_data_table A character string of the name of the raw data table.
#' @param prcp_data_table A character string of the name of the processed
#'     precipitation data table.
#' @param temp_rh_data_table A character string of the name of the processed
#'     temperature and relative humidity data table.
#' @param details_table A character string of the name of the logger details
#'     table.
#' @param verbose Logical. Default is TRUE. If FALSE, messages are suppressed.
#'
#' @return Data is written to database tables. Objects are not returned.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library("dataprocessR")
#'
#' # Connect to DB
#' my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")
#'
#' # List files
#' my_dir <- "C:/path/to/data"
#' file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
#'                         recursive = FALSE)
#' # Select file
#' my_file <- file_list[10]
#'
#' # Process file and save to database
#' import_hobo_to_db(my_file = my_file, my_db = my_db,
#'                   import_table = "tbl_import_log",
#'                   raw_data_table = "tbl_raw_data",
#'                   prcp_data_table = "tbl_prcp_data",
#'                   temp_rh_data_table = "tbl_temp_rh_data",
#'                   details_table = "tbl_logger_details")
#' }
import_hobo_to_db <- function(my_file, my_db, import_table, raw_data_table,
                              prcp_data_table, temp_rh_data_table,
                              details_table, verbose = TRUE){

  if(verbose == TRUE) message(glue::glue("Processing {basename(my_file)}"))
  #-- Process hobo file --
  dat <- suppressMessages(
    raindancer::import_wxdat(my_file) |>
      raindancer::process_hobo()
  )

  #-- Import Record --
  # Prep data
  file_info <- dat$file_info |>
    dplyr::select(FileName, PlotID, Element)
  details <- dat$details |>
    dplyr::filter(Details %in% c("Product", "Serial Number", "Launch Name",
                                 "Deployment Number", "Launch Time",
                                 "First Sample Time", "Last Sample Time")) |>
    tidyr::spread(key = "Details", value = "Value")
  names(details) <- gsub(" ", "", names(details))
  file_info <- suppressMessages(dplyr::left_join(file_info, details)) |>
    dplyr::select(FileName, PlotID, Element, Product, SerialNumber, LaunchName,
                  DeploymentNumber, LaunchTime, FirstSampleTime,
                  LastSampleTime) |>
    dplyr::mutate("ImportDate" = as.character(lubridate::today()))
  # Export to DB
  if(verbose == TRUE) message("- Writing import log to database")
  if(!import_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, file_info, tablename = import_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = FALSE, addPK = TRUE, fast = TRUE)
  } else(
    # Check if file has been processed
    if(basename(my_file) %in% RODBC::sqlFetch(my_db, import_table)$FileName){
      stop("File has already been processed.")
    } else(
      RODBC::sqlSave(my_db, file_info, tablename = import_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
      )
    )

  #-- Raw Data --
  # Prep data
  data_raw <- dat$data_raw |>
    dplyr::mutate("DateTime" = as.character(DateTime))
  # Export to DB
  if(verbose == TRUE) message("- Writing raw data to database")
  if(!raw_data_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, data_raw, tablename = raw_data_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = FALSE, addPK = TRUE, fast = TRUE)
    } else(
      RODBC::sqlSave(my_db, data_raw, tablename = raw_data_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
      )

  #-- Data --
  # Prep data
  if(verbose == TRUE) message("- Writing processed data to database")
  if(file_info$Element == "PRCP"){
    prcp_dat <- dat$data |>
      dplyr::mutate("DateTime" = as.character(DateTime,
                                              format = "%Y-%m-%d %H:%M:%S"))
    # Export to DB
    if(!prcp_data_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
      RODBC::sqlSave(my_db, prcp_dat, tablename = prcp_data_table,
                     append = FALSE, rownames = FALSE, colnames = FALSE,
                     safer = FALSE, addPK = TRUE, fast = TRUE)
      } else({
        RODBC::sqlSave(my_db, prcp_dat, tablename = prcp_data_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
        })
    } else({
      tr_dat <- dat$data |>
        dplyr::mutate("Date" = as.character(Date,
                                            format = "%Y-%m-%d %H:%M:%S"))
      # Export to DB
      if(!temp_rh_data_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
        RODBC::sqlSave(my_db, tr_dat, tablename = temp_rh_data_table,
                       append = FALSE, rownames = FALSE, colnames = FALSE,
                       safer = FALSE, addPK = TRUE, fast = TRUE)
        } else({
          RODBC::sqlSave(my_db, tr_dat, tablename = temp_rh_data_table,
                       append = TRUE, rownames = FALSE, colnames = FALSE,
                       addPK = TRUE, fast = TRUE)
          })
  })

  #-- Details --
  # Export to DB
  if(verbose == TRUE) message("- Writing logger details to database")
  if(!details_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, dat$details, tablename = details_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = FALSE, addPK = TRUE, fast = TRUE)
    } else(
      RODBC::sqlSave(my_db, dat$details, tablename = details_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
    )
  }
