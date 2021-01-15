#' Imports *.csv file produced by Onset HOBOware
#'
#' This function produces a list that will be used in get_data() and get_details().
#'
#' @param this_file a character string with the file name, can include directory path.
#' @param datestamp_loc a number for the location of the date stamp (an index). Default is 1.
#' @param plotid_loc a number for the location of the Plot ID (an index). Default is 2.
#' @param plotid_s a number for the beginning of the Plot ID (an index). Default is 1.
#' @param plotid_e a number for the end of the Plot ID (an index). Default is 3.
#'
#' @return list
#' @details
#' This function finds variables in the file name and the text file to properly
#' import the *.csv into R.
#'
#' It returns a list with two components.
#'
#' The first component is named file_info.
#' It is a vector that contains the file name, the date stamp on the file name,
#' the plot ID from the file name, and the number of rows to skip to properly
#' import the data.
#'
#' The second component is is a data frame consisting of all the raw data and
#' metadata.
#'
#' @export
#' @examples
#' file.list <- list.files(path = "./inst/raw_data", pattern = ".csv", full.names = T, recursive = F)
#' import_file(file.list[1])
#'
import_file <- function(this_file, datestamp_loc = 1, plotid_loc = 2,
                        plotid_s = 1, plotid_e = 3){
  #-- DESCRIPTION --
  # This function pulls data from the file in order to properly import it.

  #-- Pull elements from file
  file_info = data.frame(
    # The file name
    filename = basename(this_file),
    # Strip time stamp from file name
    datestamp = stringr::str_split(basename(this_file), "_")[[1]][datestamp_loc],
    # Strip Plot ID from file name
    plotid = toupper(stringr::str_sub(strsplit(basename(this_file), "_")[[1]][plotid_loc],
                                      plotid_s, plotid_e)),
    # Determine if the first row is to be skipped
    skip = ifelse(str_detect(suppressWarnings(
      read.table(this_file, sep = ",", header = F, nrows = 1, fill = T))['V1'],
      "Plot"),
      2, 1)
  ) %>%
    # Count the number of columns of data
    dplyr::mutate(col_n = ncol(suppressWarnings(read.table(this_file, sep = ",",
                                                           header = F, fill = T,
                                                           skip = skip))))

  #-- Import raw file
  if(file_info$col_n == 4){
    raw_file =  suppressWarnings(
      read.table(this_file, sep = ",", header = F, fill = T, skip = file_info$skip,
                 col.names = c("RID", "DateTime", "Value", "Details"))) %>%
      tidyr::drop_na() %>%
      tibble::as_tibble()

  } else if(file_info$col_n == 5){
    raw_file =  suppressWarnings(
      read.table(this_file, sep = ",", header = F, fill = T, skip = file_info$skip,
                 col.names = c("RID", "DateTime", "Value", "Details", "Units"))) %>%
      tidyr::drop_na() %>%
      tibble::as_tibble()

  } else if(file_info$col_n == 6){
    raw_file =  suppressWarnings(
      read.table(this_file, sep = ",", header = F, fill = T, skip = file_info$skip,
                 col.names = c("RID", "DateTime", "Value", "EndOfFile",
                               "Details", "Units"))) %>%
      tidyr::drop_na() %>%
      tibble::as_tibble()

  } else if(file_info$col_n == 7){
    raw_file =  suppressWarnings(
      read.table(this_file, sep = ",", header = F, fill = T, skip = file_info$skip,
                 col.names = c("RID", "DateTime", "Value", "BadBattery",
                               "EndOfFile", "Details", "Units"))) %>%
      tidyr::drop_na() %>%
      tibble::as_tibble()

  } else if(file_info$col_n == 9){
    raw_file =  suppressWarnings(
      read.table(this_file, sep = ",", header = F, fill = T, skip = file_info$skip,
                 col.names = c("RID", "DateTime", "Value", "Detatched",
                               "Attached", "Connected","EndFile", "Details",
                               "Units"))) %>%
      tidyr::drop_na() %>%
      tibble::as_tibble()

  } else if(file_info$col_n == 10){
    raw_file =  suppressWarnings(
      read.table(this_file, sep = ",", header = F, fill = T, skip = file_info$skip,
                 col.names = c("RID", "DateTime", "Temp", "RH",
                               "Detatched", "Attached", "Connected",
                               "EndFile", "Details","Units"))) %>%
      na.omit() %>%
      as_tibble()

  } else(message(paste0("Something is wrong. Check file: ", basename(this_file),
                        "; ncol = ", file_info$col_n)))

  return(list("file_info" = file_info, "raw_file" = raw_file))
}
