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

#-- Testing import_file() --
file.list <- list.files(path = "./inst/raw_data", pattern = ".csv",
                        full.names = T, recursive = F)
import_file(this_file = file.list[1], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[2], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[3], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[4], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[5], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[6], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[7], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[8], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[9], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[10], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[11], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[12], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[13], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[14], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[15], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
import_file(this_file = file.list[16], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)


#-- Testing get_units()
# PRCP, 4 cols
my_file = import_file(this_file = file.list[1], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
# Temp, 4 cols
my_file = import_file(this_file = file.list[2], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
# Temp, 5 cols
my_file = import_file(this_file = file.list[4], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
my_file = import_file(this_file = file.list[16], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
my_file = import_file(this_file = file.list[15], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
my_file = import_file(this_file = file.list[9], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)
my_file = import_file(this_file = file.list[12], datestamp_loc = 1, plotid_loc = 2, plotid_s = 1, plotid_e = 3)

file.list <- list.files(path = "./inst/raw_data", pattern = ".csv",
                        full.names = T, recursive = F)
my_file <- import_file(file.list[1])
get_product(my_file)
my_data <- get_data(my_file)
my_details <- get_details(my_file, my_data)
import_wxdat(file.list[1])




lapply(file.list, function(thisFile){
  # Read file information and data
  file_info = suppressWarnings(file_type(thisFile))
  print(file_info)
  suppressMessages(import_wxdat(thisFile))
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
