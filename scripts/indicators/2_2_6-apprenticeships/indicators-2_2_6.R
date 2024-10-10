#'[Script]#'*indicators-2_2_6.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*08/10/2024*
#'[Description]#'*blah*
#'[____________________________________________________________________________]

# Starts London versus Rest of England (2_2_6_a)
#===============================================================================


generate_indicator_226a <- function(UPDATE__SERIES_PATH, UPDATE__DW, UPDATE__DW_ID=NULL) {

  # Load series
  df <- read_csv(paste0(UPDATE__SERIES_PATH, '/2_2_6-processed.csv'))

  # Create indicator dataframe
  df_ind <- df %>%
    mutate(geography = case_when(region_name=='London'~'London', T~'Rest of England')) %>%
    group_by(time_period, geography) %>%
    summarise(starts_rate_per_100k_population = round((sum(starts)/sum(population))*100000,0)) %>%
    ungroup() %>%
    pivot_wider(time_period, names_from='geography', values_from='starts_rate')
  
  # Update data wrapper plot
  if (UPDATE__DW==T) {
    if (is.nul(UPDATE__DW_ID)) {
      UPDATE__DW_ID <- 'ZbznR'
    }
    # Test DW API
    key <- 'YFdh5P5bJcllD8leFsnnZMFB0wGberKn105tv5SJC0xAcCny6WTyunpzMSRt4bhc' 
    datawrapper_auth(api_key = key, overwrite=T)
    # Create copy of chart for review 
    if (dw_test_key()[[1]]$email == 'gis@london.gov.uk') {
      clone <- dw_copy_chart('ZbznR')
      dw_data_to_chart(df_plot, clone[[1]]$publicId)
      user_input <- readline(paste0(
        "A copy of this chart using the updated data has been created and sent to Datawrapper.\n
        Log in to Datawrapper to review the chart, which can be found in the economic fairness folder under ID", clone[[1]]$publicId,"\n
        Confirm that the you are satisfied with the updated output.(y/n)
        "
      ))
      # 
      if (user_input=='y') {
        cat(paste0(
          "Sending updated data to Datawrapper master chart; ID=",UPDATE__DW_ID,".\n
          It is advised that you now delete the temporary copy; ID=", clone[[1]]$publicId,"."
        ))
        dw_data_to_chart(df_plot, 'ZbznR') 
      }
      else {
        stop(
          "Aborting update procedure: User has indicator that they are satisfied with the updated output.\n
          Review the data and code to identify and fix any problem that there might be"
        )
      }
    }
    else {
      stop(
        "Aborting update procedure: R has failed to connect to the Datawrapper API.\n
        Ensure that you have access to the editor Datawrapper acount under email gis@london.gov.uk"
      )
    }
  }
  else {
    print("Skipping Datawrapper update in line with user input")
  }
        

  # Save output
  cat(paste0(
    "Saving output to Excel worbook 'economic_fairness_master_",UPDATE__RELEASE_YEAR,"'\n
     Note that the updated output is saved in a new workbook, so there is no risk of overwriting data.
    It is advisable to QA the new output by comparing output to the corresponding worksheet from the previous year's workbook
    "
    ))
  wb <- loadWorkbook(
    paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',UPDATE__RELEASE_YEAR,'.xlsx')
  )
  addWorksheet(wb, '2_2_6_a')
  writeData(wb, sheet = "2_2_6_a", df_sum, colNames = T)
  saveWorkbook(wb,paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',UPDATE__RELEASE_YEAR,'.xlsx'),overwrite = T)
}


generate_indicator_226b <- function(UPDATE__SERIES_PATH, UPDATE__DW, UPDATE__DW_ID=NULL) {
  
  # Load series
  df <- read_csv(paste0(UPDATE__SERIES_PATH, '/2_2_6-processed.csv'))
  
  # Create indicator dataframe
  df_ind <- df %>%
    mutate(geography = case_when(region_name=='London'~'London', T~'Rest of England')) %>%
    group_by(time_period, geography) %>%
    summarise(achievements_rate_per_100k_population = round((sum(starts)/sum(population))*100000,0)) %>%
    ungroup() %>%
    pivot_wider(time_period, names_from='geography', values_from='starts_rate')
  
  # Update data wrapper plot
  if (UPDATE__DW==T) {
    if (is.nul(UPDATE__DW_ID)) {
      UPDATE__DW_ID <- 'ZbznR' # change to ID for for achievements
    }
    # Test DW API
    key <- 'YFdh5P5bJcllD8leFsnnZMFB0wGberKn105tv5SJC0xAcCny6WTyunpzMSRt4bhc' 
    datawrapper_auth(api_key = key, overwrite=T)
    # Create copy of chart for review 
    if (dw_test_key()[[1]]$email == 'gis@london.gov.uk') {
      clone <- dw_copy_chart('ZbznR')
      dw_data_to_chart(df_plot, clone[[1]]$publicId)
      user_input <- readline(paste0(
        "A copy of this chart using the updated data has been created and sent to Datawrapper.\n
        Log in to Datawrapper to review the chart, which can be found in the economic fairness folder under ID", clone[[1]]$publicId,"\n
        Confirm that the you are satisfied with the updated output.(y/n)
        "
      ))
      # 
      if (user_input=='y') {
        cat(paste0(
          "Sending updated data to Datawrapper master chart; ID=",UPDATE__DW_ID,".\n
          It is advised that you now delete the temporary copy; ID=", clone[[1]]$publicId,"."
        ))
        dw_data_to_chart(df_plot, 'ZbznR') 
      }
      else {
        stop(
          "Aborting update procedure: User has indicator that they are satisfied with the updated output.\n
          Review the data and code to identify and fix any problem that there might be"
        )
      }
    }
    else {
      stop(
        "Aborting update procedure: R has failed to connect to the Datawrapper API.\n
        Ensure that you have access to the editor Datawrapper acount under email gis@london.gov.uk"
      )
    }
  }
  else {
    print("Skipping Datawrapper update in line with user input")
  }
  
  
  # Save output
  cat(paste0(
    "Saving output to Excel worbook 'economic_fairness_master_",UPDATE__RELEASE_YEAR,"'\n
     Note that the updated output is saved in a new workbook, so there is no risk of overwriting data.
    It is advisable to QA the new output by comparing output to the corresponding worksheet from the previous year's workbook
    "
  ))
  wb <- loadWorkbook(
    paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',UPDATE__RELEASE_YEAR,'.xlsx')
  )
  addWorksheet(wb, '2_2_6_b')
  writeData(wb, sheet = "2_2_6_b", df_sum, colNames = T)
  saveWorkbook(wb,paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',UPDATE__RELEASE_YEAR,'.xlsx'),overwrite = T)
}

#export excel


