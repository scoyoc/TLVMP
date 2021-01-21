library("tidyverse")
# Imports:
library("dplyr")
library("lubridate")
library("stringr")
library("tibble")
library("tidyr")
# Suggests:
library("readr")
library("stringi")
library("janitor")

# Testing weather data functions
file_list <- list.files(path = system.file("extdata", package = "dataProcessor"),
                        pattern = ".csv", full.names = TRUE, recursive = FALSE)
my_file <- import_file(file_list[4]); my_file
my_data <- get_data(my_file); my_data
my_details <- get_details(my_file, my_data); my_details
import_wxdat(file_list[1])

lapply(file_list, function(this_file){
  x = import_wxdat(this_file)
  print(x$file_info)
})





,
'QFLAG' = ifelse(Element == "Unknown", 1, ""),
'QFLAG' = ifelse(Units == "Unknown", paste(QFLAG, 2, sep = ";"),
                 QFLAG),
'QFLAG' = ifelse('Samples' != 'Records (n)',
                 paste(QFLAG, 3, sep = ";"), QFLAG)),
'QFLAG' = ifelse(sum(is.na(dat$DateTime)) > 0,
                 paste(QFLAG, 4, sep = ";"), QFLAG),
'QFLAG' = ifelse(sum(is.na(dat$Value)) > 0,
                 paste(QFLAG, 5, sep = ";"), QFLAG)
