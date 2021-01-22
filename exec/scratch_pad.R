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
library("dataProcessor")
file_list <- list.files(path = system.file("extdata", package = "dataProcessor"),
                        pattern = ".csv", full.names = TRUE, recursive = FALSE)
my_file <- import_file(file_list[1]); my_file
my_data <- get_data(my_file); my_data
my_details <- get_details(my_file, my_data); my_details
import_wxdat(file_list[1])

lapply(file_list, function(this_file){
  x = import_wxdat(this_file)
  print(x$file_info)
})






