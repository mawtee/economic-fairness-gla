#'[Script]#'*process-1_2_4_c.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*19/12/2024*
#'[Description]#'*This blah *
#'[____________________________________________________________________________]


scrape_and_write_zerohourage_data <- function(url, release_year) {
  
  #' @description 
  #' Scrapes latest zero hours contracts data from DFE site and writes to file
  #' 
  #' @details  
  #' 
  #' @param url String URL to DFE Apprenticeships data page. Defined in global `UPDATE__URL`
  #' @param release_year String data release year (e.g. 2022_23). Defined in global `UPDATE__RELEASE`
  #'
  #' @noRd
 
  
  # print(paste0("Scraping zero hour (geography cut) data for ", release_year))
  # url <- UPDATE__URL
  # release_year <- UPDATE__RELEASE_YEAR
  # 
  # # Load HTML page
  # page <- rvest::read_html(url)
  # # Scrape link to data download
  # link <- page %>%
  #   html_nodes("a") %>%               # find all links
  #   html_attr("href") %>%             # find all urls
  #   str_subset(".xlsx")               # find the api download link
  # link <- paste0('https://www.ons.gov.uk', link)
  # 
  # # Download load
  # temp <- tempfile()
  # download.file(url=link, temp, mode = "wb")
  # df <- read_excel(temp, sheet='4')
  # if (dir.exists(paste0('data/raw-data/1_2_4_c-zerohour/', release_year))) {
  #   user_confirm <- readline("Directory for data update already exists. Are you sure you want to overwrite the existing directory? (y/n)")
  #   if (user_confirm=='y') {
  #     write_csv(df, paste0('data/raw-data/1_2_4_c-zerohour/', release_year,'/ons_zerohour_geography.csv'))
  #     unlink(temp)
  #   }
  #   else {
  #     stop(
  #       'Aborting update: user does does not want to overwrite existing directory'
  #     )
  #   }
  # } 
  # else {
  #   #if (!dir.exists(paste0('data/raw-data/3_2_5-homelessness/', release_year))) {
  #   dir.create(paste0('data/raw-data/1_2_4_b-zerohour/', release_year))
  #   write_csv(df, paste0('data/raw-data/1_2_4_b-zerohour/', release_year,'/ons_zerohour_geography.csv'))
  #   unlink(temp)
  # }
  # 
}