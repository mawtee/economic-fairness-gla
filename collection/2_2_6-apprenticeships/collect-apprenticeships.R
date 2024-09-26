library(tidyverse)
library(rvest)

# Global Options
URL <- 'https://explore-education-statistics.service.gov.uk/find-statistics/apprenticeships-and-traineeships'
PUBLICATION_YEAR <- format(Sys.time(),"%Y") #2023
DATA_RELEASE <- paste0(as.numeric(PUBLICATION_YEAR)-1,'_',as.numeric(PUBLICATION_YEAR))
DESTINATION_PATH <- paste0('raw-data/2_2_6-apprenticeships/batch-datyr',DATA_RELEASE,'-pubyr',PUBLICATION_YEAR)

#===============================================================================

# Load HTML page
page <- rvest::read_html(URL)

# Scrape link to data download
link <- page %>%
  html_nodes("a") %>%               # find all links
  html_attr("href") %>%             # find all urls
  str_subset("api/releases") %>%    # find the api download link
  .[[1]]  

# Download and unzip
temp <- tempfile()
download.file(url=link, temp, mode = "wb")
unzip(zipfile=temp, exdir=DESTINATION_PATH, overwrite=TRUE)
unlink(temp)
           