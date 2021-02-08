# Load in Packages and functions:

library(tidyverse)
library(readxl)
library(rio)
library(janitor)
library(purrr)

source("ba_import_functions.R")
source("ba_import_functions_strukturdaten.R")


# Import data using the developed function:
import_ba(landkreise = c(347, 333, 357))
datensatz_ba <- import_ba(landkreise = c(347, 333), yearmonth = 201912)


datensatz_ba2 <- import_ba2(landkreise = c(347, 333), yearmonth = 201912)

