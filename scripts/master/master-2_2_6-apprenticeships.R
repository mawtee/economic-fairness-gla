#'[Script]#'*master-2_2_6-apprenticeships.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*02/10/2024*
#'[Description]#'*Master script* 
#'[Libraries]
rm(list=ls())
gc()
library(tidyverse)
library(readxl)
library(rvest)
library(DatawRappr)
library(openxlsx)
#'[Source Paths]
source('scripts/helpers.R')
source('scripts/processing/2_2_6-apprenticeships/process-2_2_6.R')
#'[Global Options]
#' Backseries inputs 
#' Note. Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
BACKSERIES <- T
if (BACKSERIES==TRUE) {
  source('scripts/processing/2_2_6-apprenticeships/process-backseries-2_2_6.R')
  BACKSERIES__APP_0516_NAMES <- c('z-2_2_6-backseries-starts-0516.csv', 'z-2_2_6-backseries-achievements-0516.csv')
  BACKSERIES__POP_0516_NAME <- 'z-population-data-la-nomis-0516.xlsx'
  BACKSERIES__CURR_YEAR <- as.numeric(format(Sys.time(),"%Y")) -1 
  BACKSERIES__17toCURR_DIRS <- list.dirs(paste0('data/raw-data/2_2_6-apprenticeships'), recursive=F)
  BACKSERIES__PROCESSED_PATH <- paste0('data/processed-data/2_2_6-apprenticeships/',BACKSERIES__CURR_YEAR-1,'_',substr(BACKSERIES__CURR_YEAR ,3,4))
  BACKSERIES__PROCESSED_SUFFIX <- '' 
}
#' Update series inputs
UPDATE <- TRUE
  if (UPDATE==T) {
    source('scripts/indicators/2_2_6-apprenticeships/indicators-2_2_6.R')
    UPDATE__URL <- 'https://explore-education-statistics.service.gov.uk/find-statistics/apprenticeships'
    UPDATE__YEAR <- as.numeric(format(Sys.time(),"%Y"))
    UPDATE__RELEASE_YEAR <- paste0(UPDATE__YEAR-1,'_', substr(UPDATE__YEAR, 3,4))
    UPDATE__CURR_RELEASE_YEAR <- paste0(UPDATE__YEAR-2,'_', substr(UPDATE__YEAR-1, 3,4))
    UPDATE__RAW_PATH <- "data/raw-data/2_2_6-apprenticeships"
    UPDATE__PROCESSED_PATH <- "data/processed-data/2_2_6-apprenticeships"
    UPDATE__SERIES_PATH <- paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__RELEASE_YEAR)
    UPDATE__DW_A <- T
    UPDATE__DW_A_ID <- 'ZbznR'
    UPDATE__DW_B <- T
    UPDATE__DW_B_ID <- 'EnQ4V'
}

#'[____________________________________________________________________________]


# Reprocess backseries
#===============================================================================

#'* Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
#'* Even if you do have a good reason, it is recommended that you define global* `BACKSERIES__PROCESSED_SUFFIX` *with some string*
#'* In this way, you will not overwrite existing backseries. *
#'* Additionally, reprocessing procedure will break if you execute it AFTER scraping and writing latest data via scrape_and_write_app_data() *
#'* In the above scenario, remove the*`-1`* condition from global*`BACKSERIES__CURR_YEAR`* and then reprocessing will run successfully, with the latest data included*

if (BACKSERIES==T) {
  
  
  # Reprocess original backseries (2005/6-2016/17)
  df_0516 <- process_app_backseries_0516(BACKSERIES__APP_0516_NAMES, BACKSERIES__POP_0516_NAME)
  
  # Reprocess backseries (from 2017/18-BACKSERIES__CURR_YEAR)
  df_17toCURR <- process_app_backseries_17toCURR(BACKSERIES__17toCURR_DIRS, BACKSERIES__CURR_YEAR)
  
  # Append into single series 
  df_backseries <- bind_rows(df_0516, df_17toCURR)
  
  # Save if series has no gaps (and user provides permission)
  if (length(unique(df_backseries$time_period))*length(unique(df_backseries$region_name)) == nrow(df_backseries)) {
    print('Series has no gaps, and all additional QA checks have been satisfied.')
    
    user_confirm <- readline(paste0(
      str_trim("Are you sure you want to write reprocssed data to file?"),"\n",
      str_trim("It is recommended that you define BACKSERIES__PROCESSED_SUFFIX so as not to overwrite existing backseries until you have checked that everything is in order."),"\n",
      str_trim("(y/n)"),"\n"
    ))
    if (user_confirm=='y') {
      print("Writing backseries to file.")
      if (dir.exists(BACKSERIES__PROCESSED_PATH)) {
        write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/2_2_6-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
      }
      else {
        dir.create(BACKSERIES__PROCESSED_PATH)
        write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/2_2_6-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
      }
    }
    else {
      stop(
        "Aborting reprocessing procedure - user does does not want to write reprocessed data to file"
      )
    }
  }
  else {
    stop(paste0(
      str_trim("Series contains gaps."),"\n",
      str_trim("Investigate source of series gaps/break before continuing, noting that one possibility is genuine gaps in the most recent data."),"\n"
    ))
  }
  
  
}


# Update series with latest data 
#===============================================================================

if (UPDATE==T) {
  

  # Scrape and save latest data
  scrape_and_write_app_data(UPDATE__URL, UPDATE__RELEASE_YEAR)

  # Process/clean latest data
  df_update <- load_and_clean_raw_app_data(paste0(UPDATE__RAW_PATH,'/', UPDATE__RELEASE_YEAR), UPDATE__YEAR)

  # Add latest data to existing series (and overwrite series where applicable)
  df_update_series <- add_update_to_series(paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__CURR_RELEASE_YEAR), df_update)

  # QA report of series provenance
  for (period in sort(unique(df_update_series$time_period))) {
    if (period == sort(unique(df_update_series$time_period))[1]) {
      cat(paste0(
        str_trim("Use the following output to conduct a review of the update process."),"\n",
        str_trim("A successul update should result in the last 6 years using data from the update year ("),UPDATE__YEAR,")","\n",
        str_trim("Divergence from this standard may mean that DfE publication has been amended to include a longer or shorter time series."),"\n",
        str_trim("This program should be able to deal with such change, but nevertheless a thorough QA check is advised in the above scenario."),"\n",
        str_trim("Also, note that the below output for 2016/17 and before is largely meaningless; what matters is the data provenance from 2017/18 onward"),"\n"
      ))
    }
    data_year <- unique(df_update_series$data_year[df_update_series$time_period==period])
    print(paste0('  Data for time period ',period,' is from the data year ', data_year))
  }
  user_confirm <- readline('Confirm that you have review and are satisfied with the data provenance of the full series.(y/n)')
  # Proceed to writing new series to file
  if (user_confirm=='y') {
    if (length(unique(df_update_series$time_period))*length(unique(df_update_series$region_name)) == nrow(df_update_series)) {
      cat(paste0(
        str_trim("Series has no gaps, and all additional QA checks have been satisfied."),"\n",
        str_trim("Creating new directory and writing updated series to file.")
      ))
      if (!dir.exists(UPDATE__SERIES_PATH)) {
        dir.create(UPDATE__SERIES_PATH)
      }
      write_csv(df_update_series, paste0(UPDATE__SERIES_PATH,'/2_2_6-processed.csv'))
    }
    else {
      stop(paste0(
        str_trim("Series contains gaps."),"\n",
        str_trim("Investigate source of series gaps/break before continuing, noting that one possibility is genuine gaps in the most recent data.")
      ))
    }
  }
  if (user_confirm=='n') {
  stop(
    'Aborting update procedure: You have confirmed that you are satisfied with the data provenance of the series. A thorough QA check is advised! '
  )
  }
  
  # Generate indicators
  generate_indicator_226a(UPDATE__SERIES_PATH, UPDATE__RELEASE_YEAR, UPDATE__DW_A, UPDATE__DW_A_ID)
  generate_indicator_226b(UPDATE__SERIES_PATH, UPDATE__RELEASE_YEAR, UPDATE__DW_B, UPDATE__DW_B_ID)

  
}





