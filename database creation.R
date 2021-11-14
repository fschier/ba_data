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
#source("ba_import_functions_062019.R")
source("ba_import_functions_062017.R")
source("ba_import_functions_strukturdaten.R")
#source("ba_import_functions_strukturdaten_062019.R")
#source("ba_import_functions_strukturdaten_062017.R")


# wd for data /db:
wd <- "C:/Users/felix/Documents/Data Science/R/99_Spielwiese/00_Data/"

# sid:
sid_ba <- read_xlsx(paste0(wd, "landkreise_sid.xlsx"), col_names = c("landkreis", "sid")) %>%
  mutate(sid = str_pad(sid, width = 3, pad = 0))

# load in data from ba:

datensatz_ba <- import_ba(landkreise = sid_ba$sid, ts = "201706") #sid_ba$sid

# Transform into table for database:

ba_db <- datensatz_ba %>%
  filter(!Indikatoren %in% c(
      "Demographische Entwicklung (2019)",
      "Soziale Lage (2019)",
      "Bildungslage (2019)"
    )
  ) %>%
  pivot_longer(
    cols = 2:ncol(datensatz_ba),
    names_to = "landkreis",
    values_to = "value"
  ) %>%
  pivot_wider(names_from = "Indikatoren") %>%
  mutate(timestamp = "06.2017")

write_excel_csv(ba_db, file = paste0(wd, "bundesagentur_datensatz_062017.csv"))
write_rds(ba_db, file = paste0(wd, "bundesagentur_datensatz_062017.rds"))

#ba_db <- read_rds(paste0(wd, "bundesagentur_datensatz_122020.rds"))

#create table for Arbeitsagenturen
table_aa <- ba_db %>% 
  filter(grepl(x = landkreis, pattern = "Agentur für Arbeit"))
  
# Create table for every single region
table_lk <- ba_db %>% 
  filter(!grepl(x = landkreis, pattern = "Agentur für Arbeit")) 


# connect to / create database

con <- DBI::dbConnect(RSQLite::SQLite(),
                      dbname = paste0(wd, "arbeitsagentur_data.db"))

# Write Strukturindikatoren -----------------------------------------------
#write tables to database:
# for 'overwrite' or 'append' the argument has to be set to TRUE

DBI::dbWriteTable(
  conn = con,
  name = "Landkreis Indikatoren",
  value = table_lk, 
  append = TRUE
)

DBI::dbWriteTable(
  conn = con,
  name = "Arbeitsagenturen Indikatoren",
  value = table_aa,
  append = TRUE
)

# Write Strukturdaten -----------------------------------------------------

# load in data from ba:

datensatz_ba_struktur <- import_ba2(landkreise = sid_ba$sid, ts = "201706") #sid_ba$sid
#test <- import_ba2(landkreise = 333, ts = "Aktuell")

# Transform into table for database:
###########
ba_db_struktur <- datensatz_ba_struktur %>%
  filter(!Merkmale %in% c(
    "Überschuss im Jahresverlauf",
    "Volkswirtschaftliche Gesamtrechnungen der Länder (Jahressummen 2018) 3)",
    "Beschäftigungsstatistik (Stichtag 30.06.2019 bzw. Bruttomonatsentgelt Stichtag 31.12.2019)",
    "Arbeitsmarktstatistik (Jahresdurchschnittswerte 2019)",
    "Ausbildungsmarktstatistik (Berichtsjahr 2019/2020) 4)",
    "Grundsicherungsstatistik (Jahresdurchschnittswerte 2019)"
  )
  ) %>% 
  rowid_to_column("rowid") %>%
  mutate(Merkmale = case_when(
    rowid <= 12 ~ paste("B", Merkmale, sep = " "),
    rowid <= 14 ~ paste("V", Merkmale, sep = " "),
    rowid <= 23 ~ paste("Besch.", Merkmale, sep = " "),
    rowid <= 34 ~ paste("AM", Merkmale, sep = " "),
    rowid <= 38 ~ paste("AusM", Merkmale, sep = " "),
    rowid <= 43 ~ paste("GS", Merkmale, sep = " "),
    TRUE ~ Merkmale)
    ) %>%
  select(-1) %>%
  pivot_longer(
    cols = 2:ncol(datensatz_ba_struktur),
    names_to = "landkreis",
    values_to = "value"
  ) %>%
  pivot_wider(names_from = "Merkmale") %>%
  mutate(timestamp = "06.2017")

write_excel_csv(ba_db_struktur, file = paste0(wd, "bundesagentur_datensatz_struktur_062017.csv"))
write_rds(ba_db_struktur, file = paste0(wd, "bundesagentur_datensatz_struktur_062017.rds"))

#ba_db <- read_rds(paste0(wd, "bundesagentur_datensatz_122020.rds"))

#create table for Arbeitsagenturen
table_aa_struktur <- ba_db_struktur %>% 
  filter(grepl(x = landkreis, pattern = "Agentur für Arbeit"))

# Create table for every single region
table_lk_struktur <- ba_db_struktur %>% 
  filter(!grepl(x = landkreis, pattern = "Agentur für Arbeit")) 


DBI::dbWriteTable(
  conn = con,
  name = "Landkreis Merkmale",
  value = table_lk_struktur, 
  append = TRUE
)

DBI::dbWriteTable(
  conn = con,
  name = "Arbeitsagenturen Merkmale",
  value = table_aa_struktur,
  append = TRUE
)




# check if table is existing in database:
DBI::dbListTables(con)
DBI::dbListFields(con, "Landkreis Indikatoren")
DBI::dbReadTable(conn = con,
                 name = "Landkreis Indikatoren")

DBI::dbGetQuery(con, "select * from 'Landkreis Merkmale' where landkreis = 'Köln, Stadt' ") %>% View()

# DBI::dbRemoveTable(conn = con, 
#                    name = )
