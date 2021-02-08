#Function development for sheet 4 "Strukturdaten"
#Needs some adjustment of the simble import_ba function as the sheet is somewhat build differently

library(tidyverse)
library(readxl)
library(rio)
library(janitor)
library(purrr)

url_2 <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-357-0-xlsx.xlsx?__blob=publicationFile&v=1"
datensatz <- rio::import(file = url_2, format = "xlsx" , which = 4) 


datensatz_clean <- datensatz %>%
  select(-ncol(datensatz)) %>%
  select(-2) %>%
  fill(1:2) %>%
  slice(4, 3:40) %>%
  janitor::row_to_names(1) %>%
  slice(6:39)

# Übertragbarkeit auf Aalen:

url <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-611-0-xlsx.xlsx?__blob=publicationFile&v=1"
datensatz <- rio::import(file = url, format = "xlsx" , which = 4) 


datensatz_clean <- datensatz %>%
  select(-ncol(datensatz)) %>%
  select(-2) %>%
  fill(1:2) %>%
  slice(4, 3:40) %>%
  janitor::row_to_names(1) %>%
  slice(6:39)


# final function:

import_ba_strukturdaten <- function(sid = 611, yearmonth = "Aktuell"){
  datensatz <- rio::import(
    file = paste0("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/",
                  yearmonth,
                  "/iiia4/zdf-sdi/sdi-",
                  sid, 
                  "-0-",
                  ifelse(yearmonth == "Aktuell", "", paste0(yearmonth, "-")),
                  "xlsx.xlsx?__blob=publicationFile&v=1"),
    format = "xlsx" ,
    which = 4
  )
  Sys.sleep(5)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-2) %>%
    fill(1:2) %>%
    slice(4, 3:40) %>%
    janitor::row_to_names(1) %>%
    slice(6:39)
  
  return(datensatz)
}

import_ba_strukturdaten(sid = 357, yearmonth = "202006")
