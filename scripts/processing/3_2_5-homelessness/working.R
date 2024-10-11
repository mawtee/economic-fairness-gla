scrape_chain_data <- function(url, release_year) {
  
  #' @description 
  #' Scrapes latest Apprenticeships data from DFE site and writes to file
  #' 
  #' @details  
  #' 
  #' @param url String URL to DFE Apprenticeships data page. Defined in global `UPDATE__URL`
  #' @param release_year String data release year (e.g. 2022_23). Defined in global `UPDATE__RELEASE`
  #'
  #' @noRd
  print(paste0("Scraping chain data for ", release_year))
  url <- 'https://data.london.gov.uk/dataset/chain-reports'
  release_year <- '2023/24'
  
  # Load HTML page
  page <- rvest::read_html(url)
  # Scrape link to data download
  link <- page %>%
    html_nodes("a") %>%               # find all links
    html_attr("href") %>%             # find all urls
    str_subset("CHAIN%20annual") %>%    # find the api download link
    str_subset("https") %>%
    str_subset(paste0(str_sub(release_year, -2, -1),'.ods'))
  
  # Download and unzip
  temp <- tempfile()
  download.file(url=link, temp, mode = "wb")
  if (dir.exists(paste0('data/raw-data/2_2_6-apprenticeships/batch-', release_year))) {
    user_confirm <- readline("Directory for data update already exists. Are you sure you want to overwrite the existing directory? (y/n)")
    if (user_confirm=='y') {
      unzip(zipfile=temp, exdir=paste0('data/raw-data/2_2_6-apprenticeships/batch-', release_year), overwrite=TRUE)
      unlink(temp)
    }
    else {
      stop(
        'Aborting update: user does does not want to overwrite existing directory'
      )
    }
  }
  else {
    unzip(zipfile=temp, exdir=paste0('data/raw-data/2_2_6-apprenticeships/', release_year), overwrite=TRUE)
    unlink(temp)
  }
  
}
