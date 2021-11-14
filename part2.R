# https://blog.az.sg/posts/reading-pdfs-in-r/#pdftools-to-the-rescue
# Since data from pre 2017 is in pdf this needs more adjustment!

# Method 1 via tabulizer package works decent, although not perfect
library(tabulizer)
library(janitor)
site <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201606/iiia4/zdf-sdi/sdi-347-0-201606-pdf.pdf?__blob=publicationFile&v=1"

df_results <- extract_tables(
    site,
    output = "data.frame",
    header = TRUE,
    pages = 5,
    encoding = "UTF-8",
  )

test <- df_results[[1]]

extract_areas(site, pages = 5)
locate_areas(site, pages = 5) # result: 111.33715  29.99579 529.29047 811.92450

df_results <- extract_tables(
    site,
    output = "data.frame",
    guess = FALSE,
    header = TRUE,
    pages = 5,
    encoding = "UTF-8",
    area = list(c(111.33715, 29.99579, 529.29047, 811.92450))
  )

site <- "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201606/iiia4/zdf-sdi/sdi-337-0-201606-pdf.pdf?__blob=publicationFile&v=1"

# extract data:
df_results <- extract_tables(
  site,
  output = "data.frame",
  guess = FALSE,
  header = TRUE,
  pages = 5,
  encoding = "UTF-8",
  area = list(c(142.0690, 246.1244, 529.2905, 811.9245))
)
test_data <- df_results[[1]]

test_n <- test_data %>%
  janitor::remove_empty(which = "cols")

#extract names:
#probably from data in database 2017 - 2020? 

# Method 2 via pdftools
library(pdftools)

test2 <- pdf_text(pdf = "https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201606/iiia4/zdf-sdi/sdi-337-0-201606-pdf.pdf?__blob=publicationFile&v=1")

cat(test2[5])
