#'[Script]#'*indicators-2_2_6.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*08/10/2024*
#'[Description]#'*blah*
#'[____________________________________________________________________________]

# Starts London versus Rest of England (2_2_6_a)
#===============================================================================


generate_indicator_226a <- function(series_path, release_year, dw, dw_id=NULL) {
  
  cat(paste0(
    str_trim('=================================================================='),"\n",
    str_trim('Generating indicator 2_2_6_a'),"\n",
    str_trim('=================================================================='),"\n"
  ))

  # Load series
  df <- read_csv(paste0(series_path, '/2_2_6-processed.csv'), show_col_types=FALSE)

  # Create indicator dataframe
  df_ind <- df %>%
    mutate(geography = case_when(region_name=='London'~'London', T~'Rest of England')) %>%
    group_by(time_period, geography) %>%
    summarise(starts_rate_per_100k_population = round((sum(starts)/sum(population))*100000,0)) %>%
    ungroup() %>%
    pivot_wider(id_cols=time_period, names_from='geography', values_from='starts_rate_per_100k_population')
  
  # chart <- dw_create_chart(
  #   type='d3-bars-bullet',
  #   folderId='266890',
  #   title='Apprenticeships - Starts per 100,000 working age population: London versus Rest of England'
  # )
  # dw_data_to_chart(df_ind, chart) 
  
  
  # Update data wrapper plot
  if (dw==T) {
    if (is.null(dw_id)) {
      dw_id <- 'ZbznR'
    }
    # Test DW API
    key <- 'YFdh5P5bJcllD8leFsnnZMFB0wGberKn105tv5SJC0xAcCny6WTyunpzMSRt4bhc' 
    datawrapper_auth(api_key = key, overwrite=T)
    # Create copy of chart for review 
    if (dw_test_key()[[1]]$email == 'gis@london.gov.uk') {
      clone <- dw_copy_chart(dw_id)
      dw_data_to_chart(df_ind, clone[[1]]$publicId)
      user_input <- readline(paste0(
        str_trim("A copy of this chart using the updated data has been created and sent to Datawrapper."),"\n",
        str_trim("Log in to Datawrapper to review the chart, which can be found in the economic fairness folder under ID"), clone[[1]]$publicId,"\n",
        str_trim("Confirm that the you are satisfied with the updated output.(y/n)")
      ))
      # 
      if (user_input=='y') {
        cat(paste0(
          str_trim("Sending updated data to Datawrapper master chart; ID="), dw_id,".\n",
          str_trim("It is advised that you now delete the temporary copy; ID="), clone[[1]]$publicId,"."
        ))
        dw_data_to_chart(df_ind, dw_id) 
      }
      else {
        stop(paste0(
          str_trim("Aborting update procedure: User has indicator that they are satisfied with the updated output."),"\n",
          str_trim("Review the data and code to identify and fix any problem that there might be")
        ))
      }
    }
    else {
      stop(paste0(
        str_trim("Aborting update procedure: R has failed to connect to the Datawrapper API."),"\n",
        str_trim("Ensure that you have access to the editor Datawrapper account under email gis@london.gov.uk")
      ))
    }
  }
  else {
    print("Skipping Datawrapper update in line with user input")
  }
  
  
  # Save output
  cat(paste0(
    str_trim("Saving output to Excel worbook economic_fairness_master_"),release_year,"\n",
    str_trim("Note that the updated output is saved in a new workbook, so there is no risk of overwriting data."),"\n",
    str_trim("It is advisable to QA the new output by comparing output to the corresponding worksheet from the previous year's workbook")
  ))
  # if does not exist, create workbook
  wb <- loadWorkbook(
    paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',release_year,'.xlsx')
  )
  addWorksheet(wb, '2_2_6_a')
  writeData(wb, sheet = "2_2_6_a", df_ind, colNames = T)
  saveWorkbook(wb,paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',release_year,'.xlsx'),overwrite = T)
}


generate_indicator_226b <- function(series_path, release_year, dw, dw_id=NULL) {
  
  cat(paste0(
    str_trim('=================================================================='),"\n",
    str_trim('Generating indicator 2_2_6_b'),"\n",
    str_trim('=================================================================='),"\n"
  ))
  
  # Load processed dataframe
  df <- read_csv(paste0(series_path, '/2_2_6-processed.csv'), show_col_types=FALSE)
  
  # Create indicator dataframe
  df_ind <- df %>%
    mutate(geography = case_when(region_name=='London'~'London', T~'Rest of England')) %>%
    group_by(time_period, geography) %>%
    summarise(achievements_rate_per_100k_population = round((sum(achievements)/sum(population))*100000,0)) %>%
    ungroup() %>%
    pivot_wider(id_cols=time_period, names_from='geography', values_from='achievements_rate_per_100k_population')
  
  
  # Create chart
  # chart <- dw_create_chart(
  #   type='d3-bars-bullet',
  #   folderId='266890',
  #   title='Apprenticeships - Achievements per 100,000 working age population: London versus Rest of England'
  # )
  # dw_data_to_chart(df_ind, chart) 
  # 
  
  # Update data wrapper plot
  if (dw==T) {
    if (is.null(dw_id)) {
      dw_id <- 'EnQ4V'
    }
    # Test DW API
    key <- 'YFdh5P5bJcllD8leFsnnZMFB0wGberKn105tv5SJC0xAcCny6WTyunpzMSRt4bhc' 
    datawrapper_auth(api_key = key, overwrite=T)
    # Create copy of chart for review 
    if (dw_test_key()[[1]]$email == 'gis@london.gov.uk') {
      clone <- dw_copy_chart(dw_id)
      dw_data_to_chart(df_ind, clone[[1]]$publicId)
      user_input <- readline(paste0(
        str_trim("A copy of this chart using the updated data has been created and sent to Datawrapper."),"\n",
        str_trim("Log in to Datawrapper to review the chart, which can be found in the economic fairness folder under ID"), clone[[1]]$publicId,"\n",
        str_trim("Confirm that the you are satisfied with the updated output.(y/n)")
      ))
      # 
      if (user_input=='y') {
        cat(paste0(
          str_trim("Sending updated data to Datawrapper master chart; ID="), dw_id,".\n",
          str_trim("It is advised that you now delete the temporary copy; ID="), clone[[1]]$publicId,"."
        ))
        dw_data_to_chart(df_ind, dw_id) 
      }
      else {
        stop(paste0(
          str_trim("Aborting update procedure: User has indicator that they are satisfied with the updated output."),"\n",
          str_trim("Review the data and code to identify and fix any problem that there might be")
        ))
      }
    }
    else {
      stop(paste0(
        str_trim("Aborting update procedure: R has failed to connect to the Datawrapper API."),"\n",
        str_trim("Ensure that you have access to the editor Datawrapper account under email gis@london.gov.uk")
      ))
    }
  }
  else {
    print("Skipping Datawrapper update in line with user input")
  }
  
  
  # Save output
  cat(paste0(
    str_trim("Saving output to Excel worbook economic_fairness_master_"),release_year,"\n",
    str_trim("Note that the updated output is saved in a new workbook, so there is no risk of overwriting data."),"\n",
    str_trim("It is advisable to QA the new output by comparing output to the corresponding worksheet from the previous year's workbook")
  ))
  # if does not exist, create workbook
  wb <- loadWorkbook(
    paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',release_year,'.xlsx')
  )
  addWorksheet(wb, '2_2_6_b')
  writeData(wb, sheet = "2_2_6_b", df_ind, colNames = T)
  saveWorkbook(wb,paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',release_year,'.xlsx'),overwrite = T)
}
