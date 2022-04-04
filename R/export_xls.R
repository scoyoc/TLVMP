#' Export LTVMP data to database
#'
#' @param my_xls A character string of the complete file path of the *.xls
#'     file.
#' @param my_db A connected database from \code{\link{RODBC}}.
#' @param data_table A character string of the name of the frequency and cover
#'     data table.
#' @param sampling_event_table A character string of the name of the sampling
#'     event table.
#' @param import_table A character string of the name of the import log.
#' @param verbose Logical. Show messages showing progress. Default is TRUE. If
#'     FALSE, messages are suppressed.
#' @param view Logical. Prints data to console before writing them to the
#'     database. Default is TRUE. If FALSE, data are not printed and there is no
#'     prompt before writing data to the database.
#'
#' @details This function uses \code{\link{import_xls}} to import LTVMP data
#'     into R and then export it to a conected Microsoft Access database.
#'
#' @return Data is written to database tables. Objects are not returned.
#'
#' @export
#'
#' @seealso \code{\link{import_xls}}, \code{\link{RODBC}},
#'     \code{\link[RODBC]{sqlSave}}, \code{\link[RODBC]{odbcConnectAccess2007}}
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
#' file_list <- list.files(my_dir, pattern = ".xls", full.names = TRUE,
#'                         recursive = FALSE)
#'
#' # Process file and save to database
#' export_xls(my_xls = file_list[1], my_db = my_db,
#'             data_table = "tblData_FreqCov",
#'             sampling_event_table = "tblSamplingEvent",
#'             import_table = "tblImportRecord")
#' }
export_xls <- function(my_xls, my_db, data_table, sampling_event_table,
                       import_table, verbose = TRUE, view = TRUE){
  # Check if file has been processed
  if(import_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    if(basename(my_xls) %in% RODBC::sqlFetch(my_db, import_table)$DataFile){
      stop("File has already been processed.")
    }
  }

  if(verbose == TRUE) message(glue::glue("Processing {basename(my_xls)}"))
  #-- Process hobo file --
  dat <- import_xls(my_xls)
  if(view == TRUE){
    print(dat)
    readline(prompt = "Press [enter] to export data to database.")
  }

  if(verbose == TRUE) message("- Writing data to database")
  export_table(my_db, my_df = dat$data, my_table = data_table)

  if(verbose == TRUE) message("- Writing sampling event to database")
  export_table(my_db, my_df = dat$sampling_event, my_table = sampling_event_table)

  if(verbose == TRUE) message("- Writing import log to database")
  export_table(my_db, my_df = dat$file_info, my_table = import_table)

}
