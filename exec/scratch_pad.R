#-- Delete NAMESPACE file and man directory
file.remove("NAMESPACE")
unlink("man", recursive = T)
#-- Create new NAMESPACE file and man directory
devtools::document()
devtools::check()
devtools::load_all()

# Testing weather data functions
library("raindancer")

my_dir <- "L:/LTVMP/Data/Weather Data/2008"
file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
                        recursive = FALSE)
lapply(file_list, function(this_file){
  x = raindancer::import_wxdat(this_file) |>
    raindancer::process_hobo()
  print(x)
})
