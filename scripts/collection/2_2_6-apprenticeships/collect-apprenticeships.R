#'[Script]#'*collect_apprenticeships.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*02/10/2024*
#'[Description]#'*This script scrapes and saves the latest apprenticeship data* 
#'*from DfE data site. It is advised to run this script within the the master* 
#'*indicator script (master-apprenticeships-2_2_6.r)*
#'[Libraries]
#'library(tidyverse)
#'library(rvest)
#'[Global Options]
#'URL <- 'https://explore-education-statistics.service.gov.uk/find-statistics/apprenticeships'
#'PUBLICATION_YEAR <- format(Sys.time(),"%Y") #2023
#'DATA_RELEASE <- paste0(as.numeric(PUBLICATION_YEAR)-1,'_',as.numeric(PUBLICATION_YEAR))
#'RAW_PATH <- paste0('raw-data/2_2_6-apprenticeships/batch-datyr',DATA_RELEASE,'-pubyr',PUBLICATION_YEAR)
#'[____________________________________________________________________________]

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
unzip(zipfile=temp, exdir=RAW_PATH, overwrite=TRUE)
unlink(temp)
           