# required Packages:

# library(tidyverse)
# library(readxl)
# library(rio)
# library(janitor)
# library(purrr)

# Initial function to return data (without indikator) for the specified sid and yearmonth:

import_ba_data <- function(sid = 611, yearmonth = "Aktuell"){
  datensatz <- rio::import(
    file = paste0("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201706/iiia4/zdf-sdi/sdi-",
                  sid,
                  "-0-201706-xls.xls?__blob=publicationFile&v=1"),
    format = "xls" ,
    which = 5
  )
  Sys.sleep(2)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-c(2:5)) %>%
    fill(1:2) %>%
    slice(4, 4:40) %>%
    janitor::row_to_names(1) %>%
    slice(4:38) %>%
    select(-1)
  
  return(datensatz)
}


# setup for final functions needs indicator column:

import_ba_data_indicator <- function(sid = 611, yearmonth = "Aktuell"){
  datensatz <- rio::import(
    file = paste0("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/",
                  yearmonth,
                  "/iiia4/zdf-sdi/sdi-",
                  sid, 
                  "-0-",
                  ifelse(yearmonth == "Aktuell", "", paste0(yearmonth, "-")),
                  "xlsx.xlsx?__blob=publicationFile&v=1"),
    format = "xlsx" ,
    which = 5
  )
  Sys.sleep(2)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-c(2:5)) %>%
    fill(1:2) %>%
    slice(4, 4:40) %>%
    janitor::row_to_names(1) %>%
    slice(4:38) %>%
    select(1)
  
  return(datensatz)
}


# final function:

import_ba <- function(landkreise = 611, ts = "Aktuell"){
  output <- rbind(import_ba_data_indicator(sid = 357), "SID_Wert") 
  for(i in landkreise){
    datensatz <- import_ba_data(sid = i, yearmonth = ts)
    datensatz <- rbind(datensatz, i)
    output <- cbind(output, datensatz)
  }
  return(output)
}
