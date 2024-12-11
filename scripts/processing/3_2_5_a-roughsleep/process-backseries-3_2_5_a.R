#'[Script]#'*process-backseries-3_2_5_a.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*08/10/2024*
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

process_roughsleep_backseries_0522 <- function(name) {
  
  #' @description 
  #' Reprocesses backseries from 2005/06-2022/23 using data stored in network drive/datastore
  #' 
  #' @details 
  #' Function performs a minimal reprocessing of backseries due to raw data being unavailable as a single series 
  #' 
  #' @param name String name of backseries file. Defined in global `BACKSERIES_0522_NAME`
  #'
  #' @noRd
  print("Reprocessing backseries from 2005/06-2022/23 ")
  
  df <- read_csv(paste0("data/raw-data/3_2_5_a-roughsleep/", name))
  df$Year <- gsub('_', '/',paste0('20',df$Year))
  names(df) <- c('time_period', 'num_roughsleep')
  df$data_year <- as.numeric(paste0('20',str_sub(df$time_period, -2)))
  df <- df[c('time_period', 'data_year', 'num_roughsleep')]
  return(df)
  
}



process_roughsleep_backseries_23toCURR <- function(name) {
  
  #' @description 
  #' Reprocesses backseries from 2023/24 to current year
  #' 
  #' @details 
  #' Function performs a minimal reprocessing of backseries due to raw data being unavailable as a single series 
  #' 
  #' @param name String name of backseries file. Defined in global `BACKSERIES_0623_NAME`
  #'
  #' @noRd
  print("Reprocessing backseries from 2005/06-2022/23 ")
  
  # TODO in 2025!
  

}



