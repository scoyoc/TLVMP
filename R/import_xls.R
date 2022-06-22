#' Import LTVMP monitoring data (Excel workbooks) in R
#'
#' This function imports SEUG long-term vegetation monitoring data from
#'     Microsoft Excel workbooks into R.
#'
#' @param my_xls A character string of the complete file path of the *.xls
#'     file.
#'
#' @details This function pulls information and data from the "SiteInfo" and
#'     "Data" sheets of the SEUG LTVMP Excel workbook and mungesthem from wide
#'     to long format.
#'
#' @return A list with three (3) objects.
#' \describe{
#'     \item{\strong{file_info}}{ This component is a vector that contains the
#'         file name, today's date, plot ID, and year the plot was sampled.}
#'     \item{\strong{sampling_event}}{ This component is a vector that contains
#'         the year the plot was sampled, the plot ID, the sample date, and the
#'         names of the observers.}
#'     \item{\strong{data}}{ This component is a data frame in long format.}
#' }
#'
#' @export
#'
#' @seealso \code{\link[readxl]{read_excel}}
#'
#' @examples
#' \dontrun{
#' library("dataprocessR")
#'
#' # List files
#' my_dir <- "C:/path/to/data"
#' file_list <- list.files(my_dir, pattern = ".xls", full.names = TRUE,
#'                         recursive = FALSE)
#'
#' # Import Excel workbook into R
#' import_xls(my_xls = file_list[1])
#' }
import_xls <- function(my_xls){
  # Testing: my_xls <- veg_files[1]

  site_info <- readxl::read_excel(path = my_xls, sheet = "SiteInfo",
                                  range = "B2:C105", trim_ws = TRUE,
                                  col_names = c("Var", "Value"))
  plot_id <- stringr::str_sub(dplyr::filter(site_info,
                                            Var == "TranName")$Value, 0, 3)
  sample_date <- as.Date(as.numeric(dplyr::filter(site_info,
                                                  Var == "Date")$Value),
                        origin = "1900-01-01")-2
  sample_year <- lubridate::year(sample_date)
  observers <- site_info |> dplyr::filter(stringr::str_detect(Var, "Observer"))
  spp_list <- dplyr::filter(site_info,
                            stringr::str_detect(Var,
                                                "Unknown|Listed|QuadSpp")) |>
    dplyr::filter(Value != "NA")

  #-- Raw data
  xls_index <- paste0("A4:GS", nrow(spp_list) + 14)
  raw_dat <- readxl::read_excel(path = my_xls, sheet = "Data",
                                range = xls_index, trim_ws = T,
                                col_names = c("SppCode",
                                              paste0(c("F", "C"),
                                                     rep(seq(1, 100),
                                                         each = 2)))) |>
    dplyr::mutate(SppCode = toupper(SppCode))
  raw_dat[raw_dat$SppCode %in% "CYAN (DARK)", "SppCode"] <- "CYANO"
  raw_dat[raw_dat$SppCode %in% "LICH", "SppCode"] <- "TOTLCHN"
  raw_dat[raw_dat$SppCode %in% "OTHER LICH", "SppCode"] <- "LICHENSPP"
  raw_dat[raw_dat$SppCode %in% "GRAV", "SppCode"] <- "GRAVEL"
  raw_dat[raw_dat$SppCode %in% "LITT", "SppCode"] <- "LITTER"
  raw_dat[raw_dat$SppCode %in% "LOOSE SAND", "SppCode"] <- "SAND"

  #-- Sampling information
  sampling_event <- data.frame(SampleYear = as.integer(sample_year),
                               PlotID = plot_id,
                               SampleDate = as.character(sample_date),
                               Observers = paste(observers$Value,
                                                 collapse = ";"),
                               stringsAsFactors = FALSE)
  #-- Import record
  file_info <- data.frame(DataFile = basename(my_xls),
                          ImportDate = as.character(lubridate::today()),
                          PlotID = plot_id,
                          SampleYear = as.integer(sample_year),
                          stringsAsFactors = FALSE)

  #-- Processed data
  dat <- raw_dat |>
    dplyr::select(SppCode, tidyselect::starts_with("F")) |>
    tidyr::gather("Quad", "F", "F1":"F100", na.rm = FALSE) |>
    dplyr::mutate(SampleYear = as.integer(sample_year),
                  PlotID = plot_id,
                  Quad = as.integer(stringr::str_sub(Quad, 2, 4)),
                  F = as.integer(F),
                  Key = paste(SampleYear, PlotID, Quad, SppCode, sep = ".")) |>
    dplyr::full_join(dplyr::select(raw_dat, SppCode,
                                   tidyselect::starts_with("C")) |>
                       tidyr::gather("Quad", "C", "C1":"C100", na.rm = FALSE) |>
                       dplyr::mutate(SampleYear = as.integer(sample_year),
                                     PlotID = plot_id,
                                     Quad = as.integer(stringr::str_sub(Quad,
                                                                        2, 4)),
                                     C = as.integer(C),
                                     Key = paste(SampleYear, PlotID, Quad,
                                                 SppCode, sep = ".")) |>
                       dplyr::select(Key, C), by = c("Key" = "Key")) |>
    dplyr::arrange(Quad) |>
    dplyr::mutate(NAs = ifelse(is.na(F) & is.na(C), 1, 0)) |>
    dplyr::filter(NAs == 0) |>
    dplyr::select(Key, SampleYear, PlotID, Quad, SppCode, F, C)

  # Return list
  return(list(file_info = file_info,
              sampling_event = sampling_event,
              data = dat))
}
