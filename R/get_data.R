#' Extract data from import_file() output
#'
#' @param my_file a list produced from import_file()
#'
#' @return tibble
#' @details
#' This function extracts the data from the list produced by import_file().
#' The dataframe is standardized and includes six columns.
#'
#' RID: unique record indetification string
#'
#' FileName: the name of the file the data were imported from
#'
#' PlotID: the unique plot identification srting
#'
#' DateTime: the date and time of the measurement
#'
#' Element: the measurement type
#'
#' Value: the measurement.
#'
#' @export
#' @examples
#' library(dataProcessor)
#' file.list <- list.files(path = "./inst/raw_data", pattern = ".csv", full.names = T, recursive = F)
#' my_file <- import_file(file.list[1])
#' get_data(my_file)
#'
get_data <- function(my_file){
  # DESCRIPTION
  # Extracts data from the raw file. It uses the list produced in
  # import_file().

  #-- Pull logger type, element, and units from Details
  my_logger = get_product(my_file)

  if(my_file$file_info$col_n != 10){
    dat = my_file$raw_file %>%
      dplyr::select('RID', 'DateTime', 'Value') %>%
      dplyr::mutate('DateTime' = lubridate::mdy_hms(DateTime,
                                                    tz = "America/Denver"),
                    'FileName' = basename(my_file$file_info$filename),
                    'PlotID' = my_file$file_info$plotid,
                    'Element' = my_logger$Element,
                    'RID' = paste(as.numeric(DateTime), PlotID, Element, sep = "."),
                    'Value' = ifelse(Element == "TEMP" && str_detect(units, "F"),
                                     Value - 32 * 5/9,
                                     Value)) %>%
      dplyr::select('RID', 'FileName', 'PlotID', 'DateTime', 'Element', 'Value')

  } else if(my_file$file_info$col_n == 10){
    dat = my_file$raw_file %>%
      dplyr::select('RID', 'DateTime', 'Temp', 'RH') %>%
      dplyr::rename('TEMP' = Temp) %>%
      tidyr::gather(key = 'Element', value = 'Value', TEMP:RH) %>%
      dplyr::mutate('DateTime' = lubridate::mdy_hms(DateTime,
                                                    tz = "America/Denver"),
                    'FileName' = basename(my_file$file_info$filename),
                    'PlotID' = my_file$file_info$plotid,
                    'RID' = paste(as.numeric(DateTime), PlotID, Element,
                                  sep = ".")) %>%
      dplyr::select('RID', 'FileName', 'PlotID', 'DateTime', 'Element', 'Value')

  } else(message(paste0("Something is wrong. Check file: ",
                        basename(my_file$file_info$filename),
                        "; ncol = ", my_file$file_info$col_n)))
  return(dat)
}
