#' Extract sampling details from import_file() output
#'
#' @param my_file a list produced from import_file()
#' @param my_dat a data frame produced from get_data()
#'
#' @details
#' This function produces a data frame of details about the sampling event.
#' Some of these details are scraped from the Details column of the *.csv produced by HOBOware.
#' Other's are scraped from the file name, and some are calculated form the data.
#'
#' @return tibble
#' @export
#'
#' @examples
#' library(dataProcessor)
#' file.list <- list.files(path = "./inst/raw_data", pattern = ".csv", full.names = T, recursive = F)
#' my_file <- import_file(file.list[1])
#' my_data <- get_data(my_file)
#' get_details(my_file, my_data)
#'
get_details <- function(my_file, my_dat){
  # DESCRIPTION
  # This function pulls details from the raw file. It uses the list produced
  # from import_file().

  # Pull logger type, element, and units from Details
  my_logger = get_product(my_file)

  # Strip Details from raw_file
  details = my_file$raw_file %>%
    dplyr::select('Details') %>%
    # Reduce column and remove white space
    dplyr::distinct() %>%
    tidyr::separate('Details', into = c("Var", "Value"), sep = ":", remove = T,
                    extra = "merge", fill = "right") %>%
    dplyr::filter(Value != "") %>%
    dplyr::filter(!Var %in% c("Version Number", "Manufacturer", "Header Created",
                              "Launch GMT Offset", "Max", "Min", "Avg",
                              "Std Dev (Ïƒ)")) %>%
    dplyr::mutate('Value' = trimws(Value, "both")) %>%
    tidyr::spread(key = Var, value = Value, fill = NA) %>%
    dplyr::mutate('Import Date' = as.character(lubridate::today()),
                  'Plot ID' = my_file$file_info$plotid,
                  'Element' = my_logger$Element,
                  'Units' = my_logger$Units,
                  'DateTime (min)' = as.character(min(my_dat$DateTime, na.rm = T)),
                  'DateTime (max)' = as.character(max(my_dat$DateTime, na.rm = T)),
                  'Records (n)' = nrow(my_dat),
                  'ConvertFtoC' = ifelse(Element == "TEMP" && str_detect(units, "F"),
                                         "Yes", "No")) %>%
    tidyr::gather(key = 'Details', value = 'Value') %>%
    dplyr::mutate("FileName" = basename(my_file$file_info$filename)) %>%
    dplyr::select('FileName', 'Details', 'Value') %>%
    dplyr::arrange('Details')
  return(details)
}
