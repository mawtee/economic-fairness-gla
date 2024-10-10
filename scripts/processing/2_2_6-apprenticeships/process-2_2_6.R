#'[Script]#'*process-2_2_2_6.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*02/10/2024*
#'[Description]#'*This blah *
#'[____________________________________________________________________________]




# Scrape and write apprenticeships data to file
#===============================================================================
scrape_and_write_app_data <- function(url, release_year) {
  
  #' @description 
  #' Scrapes latest Apprenticeships data from DFE site and writes to file
  #' 
  #' @details  
  #' 
  #' @param url String URL to DFE Apprenticeships data page. Defined in global `UPDATE__URL`
  #' @param release_year String data release year (e.g. 2022_23). Defined in global `UPDATE__RELEASE`
  #'
  #' @noRd
  
  
  # Load HTML page
  page <- rvest::read_html(url)
  # Scrape link to data download
  link <- page %>%
    html_nodes("a") %>%               # find all links
    html_attr("href") %>%             # find all urls
    str_subset("api/releases") %>%    # find the api download link
    .[[1]]  
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


# Load and clean raw apprenticeships data
#===============================================================================
load_and_clean_raw_app_data <- function(raw_path, data_year) {
  
  #' @description 
  #' Processes raw apprenticeships data downloaded from DfE.
  #' 
  #' @details 
  #' Raw apprenticeships data is loaded; columns renamed; regional filter applied and redundant variable dropped
  #'
  #' @param path description
  #' @param data_year description
  #'
  #' @return `df_app_processed` Cleaned dataframe
  #' 
  #' @noRd
  
  # Find geography-population CSV path (where path is not full CSV path e.g. in the UPDATE__RAW_PATH global)
  
  if (str_sub(raw_path, -4, -1)!='.csv') {
    raw_path <- paste0(raw_path, '/data/', list.files(paste0(raw_path, '/data'))[grepl('geography-population', list.files(paste0(raw_path, '/data')))])
  }
  
  
  df_app_processed <- read_csv(raw_path) %>%
    rename_with(~str_extract(.x, 'population'), matches('population_')) %>%
    rename_with(~str_extract(.x, 'age'), matches('age_')) %>%
    rename_with(~gsub('apps', 'app', .x), matches('apps')) %>%
    filter(
      app_level=='Total',
      age=='Total',
      geographic_level=='Regional',
      !str_detect(region_name, 'Outside')
    ) %>%
    mutate(
      `data_year` = data_year,
      time_period = paste(substr(as.character(time_period), 1,4), substr(as.character(time_period), 5,6), sep="/"),
      population = as.numeric(as.character(population))
    ) %>%
    select(time_period, data_year, region_name, population, starts, achievements, starts_rate_per_100000_population,  achievements_rate_per_100000_population) %>%
    mutate(across(c(starts, achievements, contains('rate')), ~as.numeric(as.character(.x))))
  return(df_app_processed) 
}


# Add apprenticeships update to existing series
#===============================================================================
add_update_to_series <- function(processed_path, df_update) {
  
  # Load current series 
  df_series <- read_csv(paste0(processed_path,'/2_2_6-processed.csv'))
  
  # Append update to backseries
  df <- bind_rows(df_series, df_update)
  
  # Loop through each value of time_period and keep most recent record of time_period 
  # Note. This results in the elimination of duplicates
  df_clean_list <- lapply(
    sort(unique(df$time_period)), function(y) {
      last_occurence <- max(df$data_year[which(df$time_period==y)])
      df_year <- df %>% filter(time_period==y & data_year==last_occurence)
      return(df_year)
    }
  )
  # Append into dataframe
  df_clean <- bind_rows(df_clean_list)
  
  return(df_clean)
  
}






# # Load ata
# #-----------------
# process_raw_app_data <- function(year, path) {
#   
#   df_app_processed <- read_csv(path) %>%
#     rename_with(~str_extract(.x, 'population'), matches('population_')) %>%
#     rename_with(~str_extract(.x, 'age'), matches('age_')) %>%
#     rename_with(~gsub('apps', 'app', .x), matches('apps')) %>%
#     filter(
#       app_level=='Total',
#       age=='Total',
#       geographic_level=='Regional',
#       !str_detect(region_name, 'Outside')
#     ) %>%
#     mutate(`year` = year) %>%
#     select(time_period, year, geographic_level, country_name, region_name, population, starts, achievements, achievements_rate_per_100000_population,  achievements_rate_per_100000_population) %>%
#     mutate(across(c(starts, achievements, contains('rate')), ~as.numeric(as.character(.x))))
#   
# }


# 
# 
# # Starts London versus Rest of England (2_2_6_a)
# #--------------------------------------------
# 
# # Load existing data table
# df__2_2_6_a <- read_csv(paste0(PROCESSED_PATH,'/2_2_6_a/2_2_6_a-processed-pub',as.numeric(format(Sys.time(),"%Y"))-1,'.csv'))
# # Create data table with data for latest year
# df__2_2_6_a__update <- df %>%
#   filter(geographic_level=='Regional' & region_name=='London') %>%
#   mutate(year_numeric = as.numeric(substr(time_period, 1, 4))) %>%
#   filter(year_numeric == max(year_numeric)) %>%
#   select(Year=time_period, `Total starts`=starts, `Total achievements`=achievements) 
# # Append data for latest year and save (if year does not exist in existing table)
# if (df__2_2_6_a$Year[nrow(df__2_2_6_a)] != df__2_2_6_a__update$Year[1]) {
#   print(paste0('Adding data from latest release (',PUBLICATION_YEAR,') to existing data table'))
#   df__2_2_6_a <- df__2_2_6_a %>% bind_rows(df__2_2_6_a__update)
#   write_csv(df__2_2_6_a, paste0(OUTPUT_PATH,'/2_2_6_a/2_2_6_a-processed-pub',PUBLICATION_YEAR,'.csv'))
# }
# if (df__2_2_6_a$Year[nrow(df__2_2_6_a)] == df__2_2_6_a__update$Year[1]) {
#   cat(paste0('Error: Data from latest release (',PUBLICATION_YEAR,') already exists in existing data!
#              \n  Update for ',PUBLICATION_YEAR,' has already been conducted.
#              \n  Or data for ',PUBLICATION_YEAR,' has not been released.'))
# }
#   
# 
#  
# 
# 
# 
# 
# 
# 
# 
#  
# # Starts and Completions England (2_2_6_b)
# df %>%
#   filter(geographic_level=='National') %>%
#   mutate(year_numeric = as.numeric(substr(time_period, 1, 4))) %>%
#   filter(year_numeric == max(year_numeric)) %>%
#   select(Year=time_period, `Total Starts`=starts, `Total Achievements`=achievements) %>%
#   write_csv(paste0(OUTPUT_PATH,'2_2_6_b-processed.csv'))
# 
# # Completion rate London versus England (2_2_6_c)
# df3 <- df %>%
#   filter(geographic_level=='Regional' & region_name=='London'|geographic_level=='National') %>%
#   select(-c(country_name, region_name, starts, achievements)) %>%
#   mutate(geographic_level = case_when(geographic_level=='National'~ 'England', T~'London')) %>%
#   write_csv(paste0(OUTPUT_PATH,'2_2_6_c-processed.csv'))
# 
