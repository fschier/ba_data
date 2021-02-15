# Load in Packages and functions:

library(tidyverse)
library(readxl)
library(rio)
library(janitor)
library(purrr)

# for database
library(DBI)
library(dbplyr)
library(RSQLite)

source("ba_import_functions.R")
source("ba_import_functions_strukturdaten.R")

# load in data from ba:

datensatz_ba <- import_ba(landkreise = c(347, 333, 357))

# Transform into table for database:

ba_db <- datensatz_ba %>%
  na.omit() %>%
  pivot_longer(
    cols = 2:ncol(datensatz_ba),
    names_to = "landkreis",
    values_to = "value"
  ) %>%
  pivot_wider(names_from = "Indikatoren") %>%
  mutate(timestamp = "12.2020")

#create table for Arbeitsagenturen
table_aa <- ba_db %>% 
  filter(grepl(x = landkreis, pattern = "Agentur für Arbeit"))
  
# Create table for every single region
table_lk <- ba_db %>% 
  filter(!grepl(x = landkreis, pattern = "Agentur für Arbeit")) 


# connect to / create database

wd <- "C:/Users/felix/Documents/Data Science/R/99_Spielwiese/00_Data/"

con <- DBI::dbConnect(RSQLite::SQLite(),
                      dbname = paste0(wd, "arbeitsagentur_data.db"))

# probably backup files as .RDS in case db fails?
#saveRDS()

#write tables to database:
# for 'overwrite' or 'append' the argument has to be set to TRUE

copy_to(dest = con,
        df =  table_lk, 
        name = "Landkreis Indikatoren",
        temporary = FALSE)

# as copy_to isnt ideal, DBI::dbWriteTable() is suggested

DBI::dbWriteTable(
  conn = con,
  name = "Landkreis Indikatoren",
  value = table_lk
)

DBI::dbWriteTable(
  conn = con,
  name = "Arbeitsagenturen Indikatoren",
  value = table_aa,
  overwrite = TRUE
)

# check if table is existing in database:
DBI::dbListTables(con)
DBI::dbReadTable(conn = con,
                 name = "Landkreis Indikatoren",)

DBI::dbRemoveTable(conn = con, 
                   name = )