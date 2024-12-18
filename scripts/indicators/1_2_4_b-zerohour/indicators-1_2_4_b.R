#'[Script]#'*indicators-1_2_4_b.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*18/12/2024*
#'[Description]#'*blah*
#'[____________________________________________________________________________]

# Proportion of workers on zero hour contracts London vs UK (1_2_4_b)
#===============================================================================


generate_indicator_124b <- function(series_path, release_year, dw, dw_id=NULL) {
  
  
  series_path <- paste0(UPDATE__PROCESSED_PATH,'/', UPDATE__RELEASE_YEAR)
  release_year <- UPDATE__RELEASE_YEAR
  dw <- UPDATE__DW
  dw_id <- UPDATE__DW_ID
  
  cat(paste0(
    str_trim('=================================================================='),"\n",
    str_trim('Generating indicator 1_2_4_b'),"\n",
    str_trim('=================================================================='),"\n"
  ))
  
  # Load series
  df_ind <- read_csv(paste0(series_path, '/1_2_4_b-processed.csv'), show_col_types=FALSE) %>%
    mutate(across(c(london, uk),~ round(.x,1)))
  
  # Update data wrapper plot
  if (dw==T) {
    if (is.null(dw_id)) {
      dw_id <- '9YZTc'
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
        str_trim("Confirm that you have viewed are are satisfied with the updated output.(y/n)")
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
    str_trim("Note that the updated output is saved in a new workbook, so there is no risk of overwriting data from previous year, which can still be found in sheet from previous year workbook."),"\n",
    str_trim("It is advisable to QA the new output by comparing output to the corresponding worksheet from the previous year's workbook")
  ))
  # if does not exist, create workbook
  wb <- loadWorkbook(
    paste0('data/master-data/economc_fairness_master_',release_year,'.xlsx')
  )
  if ('1_2_4_b' %ni% names(wb)) {
    addWorksheet(wb, '1_2_4_b')
  }
  writeData(wb, sheet = "1_2_4_b", df_ind, colNames = T)
  saveWorkbook(wb,paste0('data/master-data/economc_fairness_master_',release_year,'.xlsx'),overwrite = T)
}
