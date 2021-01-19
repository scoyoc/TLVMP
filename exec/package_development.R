#' ---
#' title: "Developing an R Package to Process LTVMP Data"
#' author: "Matthew W. Van Scoyoc"
#' ---
#'
#' **Developed:** 11 January, 2021
#' **Data:** "R:/NR_VegMonitoring/SEUG LTVMP/Data (1B-Perm)"
#' **Associated directories:**
#' - "R:/NR_VegMonitoring/SEUG LTVMP/"
#' - "R:/NR_VegMonitoring/SEUG LTVMP/Workspace (1D-3)"
#' **Notes:** This script documents the development of an R package to process
#' data collected for the SEUG Long-term Vegetation Monitoring Program. These
#' data include excel spreadsheets that house the vegetation data collected in
#' the field and .csv files from the Onset temperature and precipitation data
#' loggers.

# Load packages
# install.packages("devtools", "roxygene", "testthat", "tidyverse", "fs", "knirt")
library("devtools")
# Create package
create_package("~/R/dataProcessor")
#-- Initialize a Git repository
use_git()
#-- Set license
use_mit_license("Southeast Utah Group, National Park Service, DOI")

#-- Delete NAMESPACE file and man directory
file.remove("NAMESPACE")
unlink("man", recursive = T)
#-- Create new NAMESPACE file and man directory
devtools::document()
devtools::check()
devtools::load_all()

# Import existing functions
source("./exec/import_wxdat.R")
devtools::use_r("import_file")
devtools::use_r("get_data")
devtools::use_r("get_details")
devtools::use_r("import_wxdat")
rm(list = ls())
devtools::document()

# Add packages to DESCRIPTION
sessionInfo()
# Imports:
devtools::use_package("dplyr", "Imports")
devtools::use_package("lubridate", "Imports")
devtools::use_package("stringr", "Imports")
devtools::use_package("tibble", "Imports")
devtools::use_package("tidyr", "Imports")
# Suggests:
devtools::use_package("readr", "Suggests")
devtools::use_package("stringi", "Suggests")
devtools::use_package("janitor", "Suggests")

# Document functions
devtools::document()
# Check the build
devtools::check()
# Load package to test
devtools::load_all()

#-- Delete NAMESPACE file and man directory
file.remove("NAMESPACE")
unlink("man", recursive = T)
#-- Create new NAMESPACE file and man directory
devtools::document()
devtools::check()
devtools::load_all()
