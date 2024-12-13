#'[Script]#'*process-backseries-1_2_4_b.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*18/12/2024*
#'[Description]#'*Defines function to process backseries data on rough sleeping from 2005/06-2022/23.*
#'* Note that because this data is not part of an established/scrapeable series, I have reverted to constructing *
#'* a minimal function that does the following only:*
#'*   a), loads the Excel backseries stored on the network drive*
#'*   b), transforms the data so that it is in a format that is consistent with other EF indicators *
#' 
#                                                              *
#'[____________________________________________________________________________]

# Process backseries data (2005/06-2022/23)
#===============================================================================

process_zerohour_backseries_1323 <- function(name) {
  
  #' @description 
  #' Reprocesses backseries from 2013Q4-2023Q4 using data stored in network drive/datastore
  #' 
  #' @details 
  #' Function performs a minimal reprocessing of backseries due to raw data being unavailable as a single series 
  #' 
  #' @param name String name of backseries file. Defined in global `BACKSERIES_1324_NAME`
  #'
  #' @noRd
  print("Reprocessing backseries from 2013Q1-2023Q4 ")
  
  df <- read_csv(paste0("data/raw-data/1_2_4_b-zerohour/", name))
  names(df)[names(df)=='X.1'] <- 'time_period'
  df$data_year <- as.numeric(gsub('.{3}$', '', df$time_period))
  names(df) <- tolower(names(df))
  df <- relocate(df, data_year, .after='time_period')
  return(df)
  
  
  
  
}