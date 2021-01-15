#' Wrapper for import_file(), get_data() and get_details()
#'
#' This function combines all three HOBOware functions and produces a list
#' containing the details of the sampling event from get_details() and the
#' standardized data frame from get_data().
#'
#' @param this_file a character string with the file name, can include directory path.
#' @param ... Other arguments to pass to import_wxdat(). These might include the indeces for the
#' date stamp or plot ID.
#'
#' @return list
#' @details
#' Something, something...
#' @seealso import_file(), get_data()
#' @export
#'
#' @examples
#' library(dataProcessor)
#' file.list <- list.files(path = "./inst/raw_data", pattern = ".csv", full.names = T, recursive = F)
#' import_wxdat(file.list[1])
#'
import_wxdat <- function(this_file, ...){
  #-- Import file
  my_file = import_file(this_file, datestamp_loc, plotid_loc, plotid_s,
                        plotid_e)
  #-- Extract data
  my_data = suppressMessages(suppressWarnings(get_data(my_file)))
  #-- Extract details
  my_details = suppressMessages(get_details(my_file, my_data))
  # Return list of objects
  return(list('file_info' = my_file$file_info,
              'details' = my_details,
              "data" = my_data))
}
