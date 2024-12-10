
# Inverse of %in% 
#===============================================================================
`%ni%` <- Negate(`%in%`)


# Add update to series
#==============================================================================
add_update_to_series <- function(processed_path, code, df_update) {
  
  #'
  #'
  #'
  #'
  #'
  #'
  #'
  print('Adding updated data to existing series')
  
  # Load current series 
  df_series <- read_csv(paste0(processed_path,'/',code,'-processed.csv'), show_col_types=FALSE)
  # Append update to backseries
  df <- bind_rows(df_series, df_update)
  # Loop through each value of time_period and keep most recent record of time_period 
  # Note. This results in the elimination of year duplicates - DW!!!
  df_clean_list <- lapply(
    sort(unique(df$time_period)), function(y) {
      last_occurence <- max(df$data_year[which(df$time_period==y)])
      df_year <- df %>% filter(time_period==y & data_year==last_occurence)
      return(df_year)
    }
  )
  # Append into dataframe
  df_clean <- bind_rows(df_clean_list)
  
  return(df_clean)
  
}



