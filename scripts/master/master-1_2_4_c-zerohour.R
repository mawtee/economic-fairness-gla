#'[Script]#'*master-1_2_4_c-zerohour.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*19/12/2024*
#'[Description]#'*Master script* 
#'[Libraries]
rm(list=ls())
gc()
library(tidyverse)
library(readxl)
library(rvest)
library(openxlsx)
library(readODS)
library(DatawRappr)
#'[Helper Functions]
source('scripts/helpers.R')
#'[Backseries Options]
#' Note. Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
BACKSERIES <- T
if (BACKSERIES==TRUE) {
  source('scripts/processing/1_2_4_c-zerohour/process-backseries-1_2_4_c.R')
  BACKSERIES__2023_NAME <- 'z-1_2_4_c-backseries.csv'
  BACKSERIES__CURR_YEAR <- as.numeric(format(Sys.time(),"%Y")) -1 
  #BACKSERIES__23toCURR_DIRS <- list.dirs(paste0('data/raw-data/3_2_5_a-apprenticeships'), recursive=F)
  BACKSERIES__PROCESSED_PATH <- paste0('data/processed-data/1_2_4_c-zerohour/',BACKSERIES__CURR_YEAR-1,'_',substr(BACKSERIES__CURR_YEAR ,3,4))
  BACKSERIES__PROCESSED_SUFFIX <- '' 
}
#'[Update Options]
UPDATE <- TRUE
if (UPDATE==T) {
  source('scripts/processing/1_2_4_c-zerohour/process-1_2_4_c.R')
  UPDATE__CODE <- '1_2_4_c'
  UPDATE__URL <- 'https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/datasets/emp17peopleinemploymentonzerohourscontracts'
  # All = https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/adhocs/2229londonresidentsonzerohourcontractsfrom2020to2023
  # 16-24 = https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/adhocs/2082londonresidentsaged18to24yearsonzerohourcontractsfrom2020to2023
  UPDATE__YEAR <- as.numeric(format(Sys.time(),"%Y"))
  UPDATE__RELEASE_YEAR <- paste0(UPDATE__YEAR-1,'_', substr(UPDATE__YEAR, 3,4))
  UPDATE__CURR_RELEASE_YEAR <- paste0(UPDATE__YEAR-2,'_', substr(UPDATE__YEAR-1, 3,4)) # year of previous release (i.e. year before update)
  UPDATE__RAW_PATH <- paste0("data/raw-data/",UPDATE__CODE,"-zerohour")
  UPDATE__PROCESSED_PATH <- sub('raw-data', 'processed-data', UPDATE__RAW_PATH)
  UPDATE__SERIES_PATH <- paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__RELEASE_YEAR)
  source('scripts/indicators/1_2_4_b-zerohour/indicators-1_2_4_b.R')
  UPDATE__DW <- T
  UPDATE__DW_ID <- '9YZTc'
  
}



# Reprocess backseries
#===============================================================================

#'* Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
#'* Even if you do have a good reason, it is recommended that you define global* `BACKSERIES__PROCESSED_SUFFIX` *with some string*
#'* In this way, you will not overwrite existing backseries. *
#'* Additionally, reprocessing procedure will break if you execute it AFTER scraping and writing latest data via scrape_and_write_app_data() *
#'* In the above scenario, remove the*`-1`* condition from global*`BACKSERIES__CURR_YEAR`* and then reprocessing will run successfully, with the latest data included*
#'* But, to reiterate, if you do not have a clear reason (and curiosity is not a reason) to reprocess the backseries, then SKIP THIS STEP*
#'* Also note that as of 2024, the published data tables include the full series stretching back to 2013, effectively making this process superfluous*
#'* It is, however, possible, that future revisions to the published tables will result in earlier year being excluded from the series *
#'* Under these conditions, this reprocessing procedure will hold some values in terms of reproducing the full series *

if (BACKSERIES==T) {
  
  # Reprocess original backseries 2013Q1-2023Q4
  df_2023 <- process_zerohour_backseries_2023(BACKSERIES__2023_NAME)
  
  # Add backseries from 2023/24
  # TODO Add function for 2025 release, looping through the raw data files for each year
  df_backseries <- df_2023
  
  # TODO Work out and add appropriate QA check!: Only two points pre 2020, then four points thereafter, so need to add QA check for this
  # Save if series has no gaps (and user provides permission)
  # if (length(unique(df_backseries$time_period)) == length(2006:BACKSERIES__CURR_YEAR)) {  
  #   
  #   print('Series has no gaps, and all additional QA checks have been satisfied.')
  
  user_confirm <- readline(paste0(
    str_trim("Are you sure you want to write reprocssed data to file?"),"\n",
    str_trim("It is recommended that you define BACKSERIES__PROCESSED_SUFFIX so as not to overwrite existing backseries until you have checked that everything is in order."),"\n",
    str_trim("(y/n)"),"\n"
  ))
  if (user_confirm=='y') {
    print("Writing backseries to file.")
    if (dir.exists(BACKSERIES__PROCESSED_PATH)) {
      write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/1_2_4_c-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
    }
    else {
      dir.create(BACKSERIES__PROCESSED_PATH)
      write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/1_2_4_c-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
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

  
