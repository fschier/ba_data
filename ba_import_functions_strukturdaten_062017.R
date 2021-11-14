# required Packages:

# library(tidyverse)
# library(readxl)
# library(rio)
# library(janitor)
# library(purrr)

# Initial function to return data (without Merkmale) for the specified sid and yearmonth:

import_ba_strukturdaten <- function(sid = 611, yearmonth = "Aktuell"){
  datensatz <- rio::import(
    file = paste0("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201706/iiia4/zdf-sdi/sdi-",
                  sid,
                  "-0-201706-xls.xls?__blob=publicationFile&v=1"),
    format = "xls",
    which = 4
  )
  Sys.sleep(2)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-2) %>%
    fill(1:2) %>%
    slice(4, 8:56) %>%
    janitor::row_to_names(1) %>%
    select(-1)
  
  return(datensatz)
}

519
# Function for setup using "Merkmale"

import_ba_merkmal <- function(sid = 611, yearmonth = "Aktuell"){
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
  Sys.sleep(2)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-2) %>%
    fill(1:2) %>%
    slice(4, 8:56) %>%
    janitor::row_to_names(1) %>%
    select(1)
  
  return(datensatz)
}


# final function:

import_ba2 <- function(landkreise = 611, ts = "Aktuell"){
  output <- rbind(import_ba_merkmal(sid = 357), "SID_Wert")
  for(i in landkreise){
    datensatz <- import_ba_strukturdaten(sid = i, yearmonth = ts)
    datensatz <- rbind(datensatz, i)
    output <- cbind(output, datensatz)
  }
  return(output)
}