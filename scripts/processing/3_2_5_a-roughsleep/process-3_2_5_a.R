#'[Script]#'*process-3_2_5.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*10/12/2024*
#'[Description]#'*This blah *
#'[____________________________________________________________________________]


scrape_and_write_chain_data <- function(url, release_year) {
  
  #' @description 
  #' Scrapes latest Apprenticeships data from DFE site and writes to file
  #' 
  #' @details  
  #' 
  #' @param url String URL to DFE Apprenticeships data page. Defined in global `UPDATE__URL`
  #' @param release_year String data release year (e.g. 2022_23). Defined in global `UPDATE__RELEASE`
  #'
  #' @noRd
  print(paste0("Scraping CHAIN (rough sleeping) data for ", release_year))
  #url <- 'https://data.london.gov.uk/dataset/chain-reports'
  #release_year <- '2023_24'
  
  # Load HTML page
  page <- rvest::read_html(url)
  # Scrape link to data download
  link <- page %>%
    html_nodes("a") %>%               # find all links
    html_attr("href") %>%             # find all urls
    str_subset("CHAIN%20annual") %>%    # find the api download link
    str_subset("https") %>%
    str_subset(paste0(str_sub(release_year, -2, -1),'.ods'))
  
  # Download and write to file
  temp <- tempfile()
  download.file(url=link, temp, mode = "wb")
  df <- read_ods(temp, sheet='P1')
  if (dir.exists(paste0('data/raw-data/3_2_5_a-roughleep/', release_year))) {
    user_confirm <- readline("Directory for data update already exists. Are you sure you want to overwrite the existing directory? (y/n)")
    if (user_confirm=='y') {
      write_csv(df, paste0('data/raw-data/3_2_5_a-roughsleep/', release_year,'/CHAIN_rough_sleeping.csv'))
      unlink(temp)
    }
    else {
      stop(
        'Aborting update: user does does not want to overwrite existing directory'
      )
    }
  } 
  else {
  #if (!dir.exists(paste0('data/raw-data/3_2_5-homelessness/', release_year))) {
    dir.create(paste0('data/raw-data/3_2_5_a-roughsleep/', release_year))
    write_csv(df, paste0('data/raw-data/3_2_5_a-roughsleep/', release_year,'/CHAIN_roughsleep.csv'))
    unlink(temp)
  }
  
}


# Load and clean raw apprenticeships data
#===============================================================================
load_and_clean_raw_chain_data <- function(raw_path, data_year) {
  
  #' @description 
  #' Processes raw apprenticeships data downloaded from DfE.
  #' 
  #' @details 
  #' Raw apprenticeships data is loaded; columns renamed; regional filter applied and redundant variable dropped
  #'
  #' @param raw_path description
  #' @param data_year description
  #'
  #' @return `df_app_processed` Cleaned dataframe
  #' 
  #' @noRd
  
  raw_path <- paste0(UPDATE__RAW_PATH,'/', UPDATE__RELEASE_YEAR)
  data_year <- UPDATE__YEAR
  print(paste0("Loading and cleaning raw CHAIN (rough sleeping) data for ", data_year-1,"/",data_year-2000))
  
  # Find geography-population file path (where path is not full CSV path e.g. in the UPDATE__RAW_PATH global)
  raw_file <- paste0(raw_path,'/',list.files(raw_path)[grepl('CHAIN', list.files(raw_path))])
  
  # # Declare first row as colnames if first row of Excel sheet contains superfluous 'Table' description
  # Leave this in case needed for future releases: not too sure whether Table descriptio will stay or not!
  # if (any(grepl('Table', names(df_processed)))) {
  #   colnames(df) <- df[1,]
  # }
  
  # Load and process
  df_processed <- read_csv(raw_file, show_col_types=FALSE, skip=1) %>%
    filter(if_any(matches("area", ignore.case=T),  ~.x == 'Greater London Authority')) %>%
    select(matches("[[:digit:]]")) %>%
    pivot_longer(cols=everything(),names_to='time_period', values_to='num_roughsleep') %>%
    mutate(data_year = as.numeric(UPDATE__YEAR)) %>%
    relocate(data_year, .after='time_period')
  return(df_processed)

}

  
  
  
 

