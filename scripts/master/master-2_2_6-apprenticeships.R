#'[Script]#'*master-2_2_6-apprenticeships.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*02/10/2024*
#'[Description]#'*Master script* 
#'[Libraries]
library(tidyverse)
library(readxl)
library(rvest)
#' [Source Paths]
source('scripts/helpers.R')
source('scripts/processing/2_2_6-apprenticeships/process-apprenticeships-backseries.R')
#source('scripts/processing/2_2_6-apprenticeships/process-apprenticeships.R')
#'[Global Options]
#' Backseries inputs
REPROCESS_BACKSERIES <- TRUE
if (REPROCESS_BACKSERIES==TRUE) {
  BACKSERIES__APP_0516_NAMES <- c('z-2_2_6-backseries-starts-0516.csv', 'z-2_2_6-backseries-achievements-0516.csv')
  BACKSERIES__POP_0516_NAME <- 'z-population-data-la-nomis-0516.xlsx'
  BACKSERIES__CURR_YEAR <- as.numeric(format(Sys.time(),"%Y"))-1  
  BACKSERIES__17toCURR_DIRS <- list.dirs(paste0('data/raw-data/2_2_6-apprenticeships'), recursive=F)
  BACKSERIES__PROCESSED_PATH <- paste0('data/processed-data/2_2_6-apprenticeships/',BACKSERIES__CURR_YEAR-1,'_',substr(BACKSERIES__CURR_YEAR ,3,4))
  BACKSERIES__PROCESSED_SUFFIX <- '' 
}


# grepl('geography-population', paste0(BACKSERIES__RAW_FOLDER, '\\data\\', list.files(paste0(BACKSERIES__RAW_FOLDER, '\\data'))))
# # RAW_PATH <- paste0('raw-data/2_2_6-apprenticeships/batch-datyr',DATA_RELEASE,'-pubyr',PUBLICATION_YEAR)
# # RAW_DATA <- paste0(RAW_PATH, '/data/', list.files(paste0(RAW_PATH, '/data'))[grepl('app-geography-population', list.files(paste0(RAW_PATH, '/data')))])
# # PROCESSED_PATH <- 'processed-data/2_2_6-apprenticeships/'
# # Update inputs
# UPDATE_SERIES <- TRUE
# if (UPDATE_SERIES==T) {
# UPDATE__YEAR <- as.numeric(format(Sys.time(),"%Y"))
# UPDATE__RELEASE <- paste0(UPDATE__YEAR-1,'_',UPDATE__YEAR)
# UPDATE__RAW_FOLDER <- paste0('data\\raw-data\\2_2_6-apprenticeships\\batch-rel',UPDATE__RELEASE,'-upd',UPDATE__YEAR,'/data/')
# UPDATE__RAW_PATH <- paste0(UPDATE__RAW_FOLDER, '/data/', list.files(paste0(UPDATE__RAW_FOLDER, '/data'))
#                            [grepl('app-geography-population', list.files(paste0(UPDATE__RAW_FOLDER, '/data')))])
# 
#                                

# UPDATE_INDICATOR_A <- TRUE
# UPDATE_INDICATOR_B <- TRUE
# URL <- 'https://explore-education-statistics.service.gov.uk/find-statistics/apprenticeships'
# PUBLICATION_YEAR <- format(Sys.time(),"%Y") 
# PREVIOUS_YEAR <- as.numeric(PUBLICATION_YEAR)-1
# DATA_RELEASE <- paste0(PREVIOUS_YEAR,'_',PUBLICATION_YEAR)
# RAW_PATH <- paste0('raw-data/2_2_6-apprenticeships/batch-datyr',DATA_RELEASE,'-pubyr',PUBLICATION_YEAR)
# RAW_DATA <- paste0(RAW_PATH, '/data/', list.files(paste0(RAW_PATH, '/data'))[grepl('app-geography-population', list.files(paste0(RAW_PATH, '/data')))])
# PROCESSED_PATH <- 'processed-data/2_2_6-apprenticeships/'
#'[____________________________________________________________________________]


# 0. Reprocess backseries
#===============================================================================

#'* Unless you have a clear reason to update the back series, skip this step,* (`PROCESS_BACKSERIES <- F`)
#'* Even if you do have a good reason, it is recommended that you do define global* `BACKSERIES__PROCESSED_SUFFIX` *with some string*
#'* In this way, you will not overwrite existing backseries!*
#'
if (REPROCESS_BACKSERIES==T) {
  
  
  # Reprocess original backseries (2005/6-2016/17)
  df_0516 <- process_app_backseries_0516(BACKSERIES__APP_0516_NAMES, BACKSERIES__POP_0516_NAME)
  
  # Reprocess backseries (from 2017/18-BACKSERIES__CURR_YEAR)
  df_17toCURR <- process_app_backseries_17toCURR(BACKSERIES__17toCURR_DIRS, BACKSERIES__CURR_YEAR)
  
  # Append into single series 
  df_backseries <- bind_rows(df_0516, df_17toCURR)
  
  # Save if series has no gaps
  if (length(unique(df_backseries$time_period))*length(unique(df_backseries$region_name)) == nrow(df_backseries)) {
    cat(
      'Series has no gaps, and all additional QA checks have been satisfied.\n
       Writing backseries to file.'
    )
    write_csv(df_backseries, paste0(BACKSERIES__PROCESSED_PATH, '/2_2_6-processed',BACKSERIES__PROCESSED_SUFFIX,'.csv'))
  }
  else {
    stop(
      'Series contains gaps.\n
      Investigate source of series gaps/break before continuing, noting that one possibility is genuine gaps in the most recent data.\n
      There should not, however, be gaps up to and including 2022/23' 
    )
  }
  
  
}


# 1. Update series with latest data
#===============================================================================




# 2. Push updates to chart
#===============================================================================
  

# Fix 01516

# process_raw_app_data
# process_apps_backseries_0516
# process_apps_backseries_17toCURR
# collect
# update
# plots for individual indicators
# then package to describe functions
# then packrat
# 


  # Do the following where latest backseries year is equal to BACKSERIES__CURR_YEAR 
#   if (as.numeric(max(str_sub(backseries_dirs[length(backseries_dirs)], -4, -1)))==BACKSERIES__CURR_YEAR) {
#     # Loop through backseries directories and read in geography-population table
#     backseries_17toCurr_list  <- lapply(
#       backseries_dirs, function(dir) {
#         year <- as.numeric(str_sub(dir,-4,-1))
#         path <- paste0(dir, '/data/', list.files(paste0(dir, '/data'))[grepl('geography-population', list.files(paste0(dir, '/data')))])
#         process_raw_app_data(year, path)
#       }
#     )
#     # Append into dataframe 
#     # Note. This dataframe will include duplicate records for at least one time_period
#     backseries_17toCurr_df <- bind_rows(backseries_17toCurr_list)
#     # Loop through each value of time_period and keep most recent record of time_period 
#     # Note. This results in the elimination of duplicates
#     backseries_17toCurr_clean_list <- lapply(
#       sort(unique(backseries_17toCurr_df$time_period)), function(y) {
#         last_occurence <- max(backseries_17toCurr_df$year[which(backseries_17toCurr_df$time_period==y)])
#         year_df <- backseries_17toCurr_df %>% filter(time_period==y & year==last_occurence)
#         return(year_df)
#       }
#     )
#     # Append into dataframe
#     backseries_17toCurr_clean_df <- bind_rows(backseries_17toCurr_clean_list)
#     # Check for duplicates
#     dupcheck <- ave(as.integer(
#       backseries_17toCurr_clean_df$time_period),backseries_17toCurr_clean_df$region_name,
#       FUN = function(g) any(duplicated(g))) > 0
#     # Write dataframe if all duplicates are removed 
#     if (!all(dupcheck)==T) {
#       print('Writing reprocessed dataframe to file')
#     }
#     # Return error if duplicates still exist
#     else {
#       cat(
#         'Error in reprocessing.\n  
#           Reprocessed dataframe contains duplicates values by year-region_name.\n
#           Use debug function `browser()` at line 94 to identify "problem" years '
#       )
#     }
#   }
#   # Return error if latest backseries year does not equal BACKSERIES__CURR_YEAR 
#   else {
#     cat(
#       'Error in reprocessing.\n 
#         Latest year in backseries data does not match latest year in global option. 
#         Check that global option `BACKSERIES__CURR_YEAR` is correctly specified.\n
#         Otherwise ensure that data for `BACKSERIES__CURR_YEAR` has already been processed and that files exist'
#     )
#   }
#   
# }


if (UPDATE_SERIES==T) {


}

#scrape_apps_data()
#process_apps_data()
  
#   # This whole block is gross, but alternative is functionalise each script, and that effort does not justify the return
#   # could always just call them vector 1:2:3, put them in a vector and then name as length of vector
#   DATA_RELEASE_UPDATE <- DATA_RELEASE
#   RAW_PATH_UPDATE <- RAW_PATH
#   RAW_DATA_UPDATE <- RAW_DATA
#   PUBLICATION_YEAR <- PREVIOUS_YEAR
#   PREVIOUS_YEAR <- as.numeric(PUBLICATION_YEAR)-1
#   DATA_RELEASE <- paste0(PREVIOUS_YEAR,'_',PUBLICATION_YEAR)
#   RAW_PATH <- paste0('raw-data/2_2_6-apprenticeships/batch-datyr',DATA_RELEASE,'-pubyr',PUBLICATION_YEAR)
#   RAW_DATA <- paste0(RAW_PATH, '/data/', list.files(paste0(RAW_PATH, '/data'))[grepl('app-geography-population', list.files(paste0(RAW_PATH, '/data')))])
#   source('scripts/processing/2_2_6-apprenticeships/process-apprenticeships.R')
# 
# }
# 
# # Update series with latest data
# 
# 
# 
