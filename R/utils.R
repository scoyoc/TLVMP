#' Extract Hobo product and associated information
#'
#' @param my_file
#'
#' @return tibble
#'
#' @examples
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

#' Extract units of measurement
#'
#' @param my_file
#'
#' @return tibble
#'
#' @examples
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

# Data frame of Onset data loggers and what they measure
onset_loggers <- data.frame(
  'Product' = c("H07 Logger", "HOBO UA-003-64 Pendant Temp/Event", "H08 Logger",
                "HOBO UA-001-64 Pendant Temp", "HOBO U23-001 Temp/RH", ""),
  'Element' = c("PRCP", "PRCP", "TEMP", "TEMP", "TEMP-RH", "Unknown")
) %>%
  tibble::as_tibble()
