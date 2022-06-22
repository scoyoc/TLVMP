#' Export Onset Hobo data to Access Database
#'
#' This function uses the [raindancer](https://github.com/scoyoc/raindancer)
#'     package to processes data from Onset HOBO loggers used in the SEUG LTMVP
#'     from 2020-present. It then exports the data to a Microsoft Access
#'     database.
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
#' @param verbose Optional. Prints messages to the console showing function
#'     progress. Default is TRUE. If FALSE, messages are suppressed.
#' @param view Optional. Prints data to console before writing them to the
#'     database. Default is TRUE. If FALSE, data are not printed and there is no
#'     prompt before writing data to the database.
#'
#' @details This function uses two functions from the raindacer package.
#'     \code{\link[raindancer]{import_hobo}} is usec to read Hobo data in into
#'     R, and then \code{\link[raindancer]{process_hobo}} is used to
#'     summarize the data. The processed data are then exported to a connected
#'     Microsoft Access database.
#'
#' @return Data is written to database tables. Objects are not returned.
#'
#' @export
#'
#' @seealso [raindancer](https://github.com/scoyoc/raindancer),
#'     \code{\link[raindancer]{import_hobo}},
#'     \code{\link[raindancer]{raindance}}, \code{\link[raindancer]{sundance}},
#'     \code{\link[raindancer]{process_hobo}}, \code{\link{RODBC}},
#'     \code{\link[RODBC]{sqlSave}}, \code{\link[RODBC]{odbcConnectAccess2007}}
#'
#' @examples
#' \dontrun{
#' library("raindancer")
#' library("dataprocessR")
#'
#' # Connect to DB
#' my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")
#'
#' # List files
#' my_dir <- "C:/path/to/data"
#' file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
#'                         recursive = FALSE)
#'
#' # Process file and save to database
#' export_hobo(my_file = file_list[1], my_db = my_db,
#'             import_table = "tblWxImportLog",
#'             raw_data_table = "tblWxData_raw",
#'             prcp_data_table = "tblWxData_PRCP",
#'             temp_rh_data_table = "tblWxData_TEMP_RH",
#'             details_table = "tblWxLoggerDetails")
#' }
export_hobo <- function(my_file, my_db, import_table, raw_data_table,
                              prcp_data_table, temp_rh_data_table,
                              details_table, verbose = TRUE, view = TRUE){

  # my_file = file_list[2]

  # Check if file has been processed
  if(import_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
     if(basename(my_file) %in% RODBC::sqlFetch(my_db, import_table)$FileName){
       stop("File has already been processed.")
       }
  }

  if(verbose == TRUE) message(glue::glue("Processing {basename(my_file)}"))
  #-- Process hobo file --
  dat <- raindancer::import_hobo(my_file) |> raindancer::process_hobo()
  if(view == TRUE){
    print(dat)
    readline(prompt = "Press [enter] to export data to database.")
  }

  #-- Import Record --
  # Prep data
  file_info <- dat$file_info |>
    dplyr::mutate("ImportDate" = as.character(lubridate::today()))

  #-- Raw Data --
  # Prep data
  data_raw <- dat$data_raw |>
    dplyr::mutate("DateTime" = as.character(DateTime))
  # Export to DB
  if(verbose == TRUE) message("- Writing raw data to database")
  export_table(my_db, my_df = data_raw, my_table = raw_data_table)

  #-- Data --
  # Prep data
  if(verbose == TRUE) message("- Writing processed data to database")
  if(TRUE %in% (file_info$Element == "PRCP")){
    if(nrow(file_info) == 1){
    prcp_dat <- dat$data |>
      dplyr::mutate("DateTime" = as.character(DateTime,
                                              format = "%Y-%m-%d %H:%M:%S"))
    # Export to DB
    export_table(my_db, my_df = prcp_dat, my_table = prcp_data_table)

    } else({
      # PRCP Data
      prcp_dat <- dat$data$prcp_dat |>
        dplyr::mutate("DateTime" = as.character(DateTime,
                                                format = "%Y-%m-%d %H:%M:%S"))
      # Export to DB
      export_table(my_db, my_df = prcp_dat, my_table = prcp_data_table)

      # TEMP Data
        temp_dat <- dat$data$temp_dat |>
          dplyr::mutate("Date" = as.character(Date,
                                              format = "%Y-%m-%d %H:%M:%S"))
        # Export to DB
        export_table(my_db, my_df = temp_dat, my_table = temp_rh_data_table)

        })
    } else({
        tr_dat <- dat$data |>
          dplyr::mutate("Date" = as.character(Date,
                                              format = "%Y-%m-%d %H:%M:%S"))
        # Export to DB
        export_table(my_db, my_df = tr_dat, my_table = temp_rh_data_table)
        })

  #-- Details --
  # Export to DB
  if(verbose == TRUE) message("- Writing logger details to database")
  export_table(my_db, my_df = dat$details, my_table = details_table)

  # Export Import Record to DB
  if(verbose == TRUE) message("- Writing import log to database")
  export_table(my_db, my_df = file_info, my_table = import_table)
}
