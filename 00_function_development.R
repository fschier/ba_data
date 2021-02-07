library(tidyverse)
library(readxl)
library(rio)
library(janitor)
library(purrr)


# Aalen
url <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-611-0-xlsx.xlsx?__blob=publicationFile&v=1"
aalen = rio::import(file = url, format = "xlsx" , which = 5)

# Köln
url_2 <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-357-0-xlsx.xlsx?__blob=publicationFile&v=1"
datensatz <- rio::import(file = url_2, format = "xlsx" , which = 5) 

## Funktion für Köln

datensatz_clean <- datensatz %>%
  select(-ncol(datensatz)) %>%
  select(-c(2:5)) %>%
  fill(1:2) %>%
  slice(4, 4:40) %>%
  janitor::row_to_names(1) %>%
  slice(5:38)

## Übertragbarkeit auf Aalen?
# Scheint gegeben, trotz mehr Gebieten (Landkreisen) für die AA Aalen

datensatz_clean_allen <- aalen %>%
  select(-ncol(aalen)) %>%
  select(-c(2:5)) %>%
  fill(1:2) %>%
  slice(4, 4:40) %>%
  janitor::row_to_names(1) %>%
  slice(5:38)

# Simple Function for converting loaded dataset into tidy data

clean_ba_data <- function(datensatz){
  datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-c(2:5)) %>%
    fill(1:2) %>%
    slice(4, 4:40) %>%
    janitor::row_to_names(1) %>%
    slice(5:38)
}

clean_ba_data(datensatz = aalen)

# adding the import into the function to call within a for loop

url_start <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-"
# url_mid <- "611"
url_end <- "-0-xlsx.xlsx?__blob=publicationFile&v=1"


import_ba_data <- function(sid = 611){
  datensatz <- rio::import(
    file = paste0(url_start, sid , url_end),
    format = "xlsx" ,
    which = 5
  )
  Sys.sleep(5)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-c(2:5)) %>%
    fill(1:2) %>%
    slice(4, 4:40) %>%
    janitor::row_to_names(1) %>%
    slice(5:38)
}

test1 <- import_ba_data()


## purrr approach to leading the data

# 357 has 4 entries (difficult to handle in an unnest)
landkreise <- c(611, 131, 361)
finaler_datensatz <- tibble(sid = landkreise)


test_purrr <- finaler_datensatz %>%
  mutate(ba_daten = purrr::map(.x = sid, .f = import_ba_data))
  
test_purrr_final <- test_purrr %>%
  unnest(ba_daten)

# purrr approach does work, but leaves us with a datasaet containing a list column which is not ideal in our case
# another approach using an iteration via for loop seems more appropriate


# Alternative via a for loop, and appending the dataset together
# This will require some adjustment on the import_ba_data() function as we wont need every dataset to include the "Indikator" column

import_ba_data_for_loop <- function(sid = 611){
  datensatz <- rio::import(
    file = paste0(url_start, sid , url_end),
    format = "xlsx" ,
    which = 5
  )
  Sys.sleep(5)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-c(2:5)) %>%
    fill(1:2) %>%
    slice(4, 4:40) %>%
    janitor::row_to_names(1) %>%
    slice(5:38) %>%
    select(-1)
}

# Set initial "Indikator" column to bind datasets to:
test1 <- import_ba_data()
for_loop_data <- test1 %>%
  select(1)


landkreise <- c(611, 131, 361, 357, 075)


# Run the for loop for selected Arbeitsagentur sid

landkreise <- c(347, 333, 357)


for(i in landkreise){
  datensatz_ba <- import_ba_data_for_loop(sid = i)
  for_loop_data <- cbind(for_loop_data, datensatz_ba)
  
}



# Adjusting the function for archived datasets (just needs adjustment in the url)

# https://statistik.arbeitsagentur.de/Statistikdaten/Detail/202006/iiia4/zdf-sdi/sdi-347-0-202006-xlsx.xlsx?__blob=publicationFile&v=1
# https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-357-0-xlsx.xlsx?__blob=publicationFile&v=1
# 
url_start <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/Aktuell/iiia4/zdf-sdi/sdi-"
# url_mid <- "611"
url_end <- "-0-xlsx.xlsx?__blob=publicationFile&v=1"


import_ba_data_for_loop_new <- function(sid = 611, yearmonth = "Aktuell"){
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
  Sys.sleep(5)
  datensatz <- datensatz %>%
    select(-ncol(datensatz)) %>%
    select(-c(2:5)) %>%
    fill(1:2) %>%
    slice(4, 4:40) %>%
    janitor::row_to_names(1) %>%
    slice(5:38) %>%
    select(-1)
  
  return(datensatz)
}

import_ba_data_for_loop_new(sid = 357, yearmonth = "202006")
