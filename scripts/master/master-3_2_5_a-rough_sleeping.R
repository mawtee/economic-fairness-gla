#'[Script]#'*master-3_2_5_a-apprenticeships.R*
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
library(openxlsx)
library(DatawRappr)
#'[Source Paths]
source('scripts/helpers.R')
#source('scripts/processing/2_2_6-apprenticeships/process-2_2_6.R')
#'[Global Options]
#' Backseries inputs 
#' Note. Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
BACKSERIES <- T
if (BACKSERIES==TRUE) {
  source('scripts/processing/3_2_5_a-rough_sleeping/process-backseries-3_2_5_a.R')
  BACKSERIES__0522_NAME <- 'z-3_2_5_a-backseries.csv'
#   BACKSERIES__POP_0516_NAME <- 'z-population-data-la-nomis-0516.xlsx'
  BACKSERIES__CURR_YEAR <- as.numeric(format(Sys.time(),"%Y")) -1 
#   BACKSERIES__17toCURR_DIRS <- list.dirs(paste0('data/raw-data/2_2_6-apprenticeships'), recursive=F)
  BACKSERIES__PROCESSED_PATH <- paste0('data/processed-data/3_2_5_a-rough_sleeping/',BACKSERIES__CURR_YEAR-1,'_',substr(BACKSERIES__CURR_YEAR ,3,4))
  BACKSERIES__PROCESSED_SUFFIX <- '' 
}
#' Update series inputs
UPDATE <- TRUE
if (UPDATE==T) {
  #source('scripts/indicators/2_2_6-apprenticeships/indicators-2_2_6.R')
  UPDATE__URL <- "https://data.london.gov.uk/dataset/chain-reports"
  UPDATE__YEAR <- as.numeric(format(Sys.time(),"%Y"))
  UPDATE__RELEASE_YEAR <- paste0(UPDATE__YEAR-1,'_', substr(UPDATE__YEAR, 3,4))
  UPDATE__CURR_RELEASE_YEAR <- paste0(UPDATE__YEAR-2,'_', substr(UPDATE__YEAR-1, 3,4)) # year of previous release (i.e. year before update)
  UPDATE__RAW_PATH <- "data/raw-data/3_2_5_a-rough_sleeping"
  UPDATE__PROCESSED_PATH <- "data/processed-data/3_2_5_a-rough_sleeping"
  UPDATE__SERIES_PATH <- paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__RELEASE_YEAR)
  # UPDATE__DW_A <- T
  # UPDATE__DW_A_ID <- 'ZbznR'
  # UPDATE__DW_B <- T
  # UPDATE__DW_B_ID <- 'EnQ4V'
}



# Reprocess backseries
#===============================================================================

#'* Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
#'* Even if you do have a good reason, it is recommended that you define global* `BACKSERIES__PROCESSED_SUFFIX` *with some string*
#'* In this way, you will not overwrite existing backseries. *
#'* Additionally, reprocessing procedure will break if you execute it AFTER scraping and writing latest data via scrape_and_write_app_data() *
#'* In the above scenario, remove the*`-1`* condition from global*`BACKSERIES__CURR_YEAR`* and then reprocessing will run successfully, with the latest data included*

if (BACKSERIES==T) {
  
  # Reprocess original backseries (2005/06-2022/23)
  df_0522 <- process_backseries_0522(BACKSERIES__0522_NAME)
  
  # Add recent backseries (for now skip!!)
  df_backseries <- df_0522
  
  
  # Save if series has no gaps (and user provides permission)
  #if (length(unique(df_backseries$time_period)) == length()) {
    print('Series has no gaps, and all additional QA checks have been satisfied.')
    
    user_confirm <- readline(paste0(
      str_trim("Are you sure you want to write reprocssed data to file?"),"\n",
      str_trim("It is recommended that you define BACKSERIES__PROCESSED_SUFFIX so as not to overwrite existing backseries until you have checked that everything is in order."),"\n",
      str_trim("(y/n)"),"\n"
    ))
    if (user_confirm=='y') {
      print("Writing backseries to file.")
      if (dir.exists(BACKSERIES__PROCESSED_PATH)) {
        write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/3_2_5_a-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
      }
      else {
        dir.create(BACKSERIES__PROCESSED_PATH)
        write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/3_2_5_a-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
      }
    }
    else {
      stop(
        "Aborting reprocessing procedure - user does does not want to write reprocessed data to file"
      )
    }
  #}
  # else {
  #   stop(paste0(
  #     str_trim("Series contains gaps."),"\n",
  #     str_trim("Investigate source of series gaps/break before continuing, noting that one possibility is genuine gaps in the most recent data."),"\n"
  #   ))
  # }
  
  
}




# Update series with latest data 
#===============================================================================

if (UPDATE==T) {
  
  
  # Scrape and save latest data
  scrape_and_write_chain_data(UPDATE_URL, UPDATE__RELEASE_YEAR)
  
  # Process/clean latest data
  df_update <- load_and_clean_raw_app_data(paste0(UPDATE__RAW_PATH,'/', UPDATE__RELEASE_YEAR), UPDATE__YEAR)
  
  # Add latest data to existing series (and overwrite series where applicable)
  df_update_series <- add_update_to_series(paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__CURR_RELEASE_YEAR), df_update)
  
  



  

  