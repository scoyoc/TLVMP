#' Obtain metadata and data from *.csv file created by Onset HOBOware
#'
#' Imports data from comma delimited (*.csv) files created by Onset HOBOware
#' software. These data contain temperature, RH, and precipitation data
#' collected at the SEUG long-term vegetation monitoring plots. This function
#' returns a list containg details about the file in 'file_info', details about
#' the data logger and sampling event in 'details', and the data in 'dat'.
#'
#' @param this_file a character string with the file name, can include directory path.
#' @param datestamp_loc a number for the location of the date stamp (an index). Default is 1.
#' @param plotid_loc a number for the location of the Plot ID (an index). Default is 2.
#' @param plotid_s a number for the beginning of the Plot ID (an index). Default is 1.
#' @param plotid_e a number for the end of the Plot ID (an index). Default is 3.
#'
#' @return Returns a list.
#'
#' @details
#' This function pulls information from the Details column of the csv
#' file about the type of data logger and launch date and time, it also
#' calculates variables from the data including first and last samples, number of
#' records, and sampling duration. Lastly is conducts some simple quality control
#' routines.
#'
#' Definitions of variables returned:
#' *FileName:* the name of the file being processed.
#' *ImportDate:* the date the file was processed. Derived from lubridate::today().
#' *PlotID:* Plot ID; scraped from the file name.
#' *Product:* the product name of the data logger; listed in Details.
#' *Element:* the type of data collected. Precipitation (PRCP), temperature (TEMP), or temperature and relative humidity (TEMP-RH).
#' *Unit:* the units of data. Event for PRCP, °C for TEMP, and °C-%RH for TEMP-RH
#' *LaunchDateTime:* the date and time the logger was launched; listed in Details.
#' *FirstSampleDateTime:* the date and time of the first sampling event; listed in Details.
#' *LastSampleDateTime:* the date and time of the last sampling event; listed in Details.
#' *DateTime_min:* the minimum date/time value from the raw data.
#' *DateTime_max:* the maximum date/time value from the raw data.
#' *Records_n:* the number of record of raw data.
#' *DateTime_NA:* number of missing DateTime values in raw data.
#' *Data_NA*: number of missing data values in raw data.
#'
#' @export
#' @examples
#' library(LTVMProcessor)
#'
library("tidyverse")

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

# Data frame of Onset data loggers and what they measure
onset_loggers <- data.frame(
  'Product' = c("H07 Logger", "HOBO UA-003-64 Pendant Temp/Event", "H08 Logger",
                "HOBO UA-001-64 Pendant Temp", "HOBO U23-001 Temp/RH", ""),
  'Element' = c("PRCP", "PRCP", "TEMP", "TEMP", "TEMP-RH", "Unknown")
) %>%
  tibble::as_tibble()

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
                  'Records (n)' = nrow(dat),
                  'ConvertFtoC' = ifelse(Element == "TEMP" && str_detect(units, "F"),
                                         "Yes", "No")) %>%
    tidyr::gather(key = 'Details', value = 'Value') %>%
    dplyr::mutate("FileName" = basename(my_file$file_info$filename)) %>%
    dplyr::select('FileName', 'Details', 'Value') %>%
    dplyr::arrange('Details')
  return(details)
}

get_product <- function(my_file){
  # DESCRIPTION
  # This function extracts the Onset product name from the Details column of the
  # raw file. It uses the list produced from import_file().
  my_logger = my_file$raw_file %>%
    dplyr::select('Details') %>%
    tidyr::separate('Details', into = c("Var", "Product"), sep = ":", remove = T,
                    extra = "merge", fill = "right") %>%
    dplyr::filter(Var == "Product") %>%
    dplyr::distinct() %>%
    dplyr::mutate('Product' = trimws(Product, 'left'),
                  'Units' = suppressWarnings(get_units(my_file))) %>%
    dplyr::left_join(onset_loggers)
  return(my_logger)
}

get_units <- function(my_file){
  # DESCRIPTION
  # This function extracts the units of measurement out of the Details or Units
  # column of the raw file. It uses the list produced form import_file().

  # Strip units from raw_file
  units = if(my_file$file_info$col_n == 4){
    dplyr::select(my_file$raw_file, 'Details') %>%
      tidyr::separate('Details', into = c("Var", "Val"), sep = ":") %>%
      dplyr::filter(Var == "Series") %>%
      tibble::deframe()
  } else(
    dplyr::select(my_file$raw_file, 'Units') %>%
      dplyr::filter(Units != "") %>%
      tibble::deframe() %>%
      dplyr::first()
  )

  units = if(stringr::str_detect(units, "Event")) {"Event"
  } else if(stringr::str_detect(units, "F")) {"F"
      } else if(stringr::str_detect(units, "C")) {"C"
        } else("Unknown")
  return(units)
}


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
