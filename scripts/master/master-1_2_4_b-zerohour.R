#'[Script]#'*master-1_2_4_b-zerohour.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*11/12/2024*
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
  source('scripts/processing/1_2_4_b-zerohour/process-backseries-1_2_4_b.R')
  BACKSERIES__1323_NAME <- 'z-1_2_4_b-backseries.csv'
  BACKSERIES__CURR_YEAR <- as.numeric(format(Sys.time(),"%Y")) -1 
  #BACKSERIES__23toCURR_DIRS <- list.dirs(paste0('data/raw-data/3_2_5_a-apprenticeships'), recursive=F)
  BACKSERIES__PROCESSED_PATH <- paste0('data/processed-data/1_2_4_b-zerohour/',BACKSERIES__CURR_YEAR-1,'_',substr(BACKSERIES__CURR_YEAR ,3,4))
  BACKSERIES__PROCESSED_SUFFIX <- '' 
}
#'[Update Options]
UPDATE <- TRUE
if (UPDATE==T) {
  source('scripts/processing/1_2_4_b-zerohour/process-1_2_4_b.R')
  UPDATE__CODE <- '1_2_4_b'
  UPDATE__URL <- 'https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/datasets/emp17peopleinemploymentonzerohourscontracts'
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
  df_1323 <- process_zerohour_backseries_1323(BACKSERIES__1323_NAME)
  
  # Add backseries from 2023/24
  # TODO Add function for 2025 release, looping through the raw data files for each year
  df_backseries <- df_1323
  
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
        write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/1_2_4_b-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
      }
      else {
        dir.create(BACKSERIES__PROCESSED_PATH)
        write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/1_2_4_b-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
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
  scrape_and_write_zerohourgeo_data(UPDATE__URL, UPDATE__RELEASE_YEAR)
  
  # Process/clean latest data
  df_update <- load_and_clean_raw_zerohourgeo_data(paste0(UPDATE__RAW_PATH,'/', UPDATE__RELEASE_YEAR), UPDATE__YEAR)
  
  # Add latest data to existing series (and overwrite series where applicable)
  df_update_series <- add_update_to_series(paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__CURR_RELEASE_YEAR), UPDATE__CODE, df_update)
  
  # Not sure a QA check is really needed, maybe just check series is biannual up to Q4 2019, then quartery from Q1 202 onward
  cat(paste0(
    str_trim("Use the following output to conduct a review of the update process in terms of the length of the series by year"),"\n",
    str_trim("The expected length of each year is based on the series length from previous releases."),"\n",
    str_trim("Divergence between expected and actual length should be carefully investigated before proceeding. "),"\n"
  ))
  for (period in unique(as.numeric(substr(df_update_series$time_period, 1, 4)))) {
    if (period == 2013) {
      exp_length <- 1
    }
    else if (between(period, 2014, 2019)) {
      exp_length <- 2
    }
    else if (between(period, 2020, UPDATE__YEAR-1)) {
      exp_length <- 4
    }
    else {
      exp_length <- 3 # Assuming an update in November
    }
    act_length <- length(unique(df_update_series$time_period[grepl(as.character(period), df_update_series$time_period)]))
    print(paste0('  Data for time period ',period,' is recorded at ',act_length,' time points: Data for ',period,' should be recorded at ',exp_length,' time points.'  ))
  }
  # Also QA check on data provenance
  # QA report of series provenance
  cat(paste0(
    str_trim("As of 2024, a successul update should result in all years using data from update year ("),UPDATE__YEAR,")","\n",
    str_trim("Divergence from this standard may mean that the ONS publication has been such that some of the earlier years have now been dropped from the time series."),"\n",
    str_trim("This program should be able to deal with such change using data from a previous release, but nevertheless a thorough QA check is advised in the above scenario."),"\n"
  ))
  for (period in unique(as.numeric(substr(df_update_series$time_period, 1, 4)))) {
    data_year <- unique(df_update_series$data_year[as.numeric(substr(df_update_series$time_period, 1, 4))==period])
    print(paste0('  Data for time period ',period,' is from the data year ', data_year))
  }
  
  user_confirm <- readline('Confirm that you have reviewed and are satisfied with the length and provenance of the series.(y/n)')
  
  # Proceed to writing new series to file
  if (user_confirm=='y') {
    cat(paste0(
      str_trim("QA checks have been satisfied."),"\n",
      str_trim("Creating new directory and writing updated series to file.")
    ))
      if (!dir.exists(UPDATE__SERIES_PATH)) {
        dir.create(UPDATE__SERIES_PATH)
      }
      write_csv(df_update_series, paste0(UPDATE__SERIES_PATH,'/1_2_4_b-processed.csv'))
      print(paste0("Updated series saved to '", UPDATE__SERIES_PATH,"/1_2_4_b-processed.csv'"))
  }
  if (user_confirm=='n') {
    stop(
      'Aborting update procedure: You have confirmed that you are satisfied with the data provenance of the series. A thorough QA check is advised! '
    )
  }
  
  # Generate indicator (updating)
  generate_indicator_124b(UPDATE__SERIES_PATH, UPDATE__RELEASE_YEAR, UPDATE__DW, UPDATE__DW_ID)
  
  
}




