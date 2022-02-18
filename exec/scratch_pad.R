#-- Delete NAMESPACE file and man directory
file.remove("NAMESPACE")
unlink("man", recursive = T)
#-- Create new NAMESPACE file and man directory
devtools::document()
devtools::check()
devtools::load_all()

# Testing weather data functions
library("raindancer")
