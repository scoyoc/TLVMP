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
document()
check()

# Import existing functions
source("./exec/import_wxdat.R")
use_r("import_file")
use_r("get_data")
use_r("get_details")
use_r("import_wxdat")
rm(list = ls())
document()

# Add packages to DESCRIPTION
sessionInfo()
use_package("stringr", "Imports")
use_package("tibble", "Imports")
use_package("tidyr", "Imports")
use_package("dplyr", "Imports")
use_package("lubridate", "Imports")
use_package("readr", "Suggests")
use_package("stringi", "Suggests")
use_package("janitor", "Suggests")
document()
check()
load_all()

#-- Delete NAMESPACE file and man directory
file.remove("NAMESPACE")
unlink("man", recursive = T)
#-- Create new NAMESPACE file and man directory
document()
check()
load_all()
