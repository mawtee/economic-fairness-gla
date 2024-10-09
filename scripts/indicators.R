#'[Script]#'*process_apprenticeships_backseries.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*08/10/2024*
#'[Description]#'*Defines all processing functions used for indicator 2_2_6-apprenticeships*
#'[____________________________________________________________________________]

# Starts London versus Rest of England (2_2_6_a)
#=============================================================================

name <- function() {

  # Load series
  df <- read_csv(paste0(UPDATE__SERIES_PATH, '/2_2_6-processed.csv'))

  #
  df_plot <- df %>%
    mutate(geography = case_when(region_name=='London'~'London', T~'Rest of England')) %>%
    group_by(time_period, geography) %>%
    summarise(starts_rate = round((sum(starts)/sum(population))*100000,0)) %>%
    ungroup() %>%
    pivot_wider(time_period, names_from='geography', values_from='starts_rate')


  # Set API key
  key <- 'YFdh5P5bJcllD8leFsnnZMFB0wGberKn105tv5SJC0xAcCny6WTyunpzMSRt4bhc' 
  datawrapper_auth(api_key = key, overwrite=T)
  dw_test_key()
  
  clone <- dw_copy_chart('ZbznR')
  dw_data_to_chart(df_plot, clone[[1]]$publicId) 
  #readline
  #if all good, then update original chart
  dw_data_to_chart(df_plot, 'ZbznR') 
  
  # Add to Excel
  wb <- loadWorkbook(
    paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',UPDATE__RELEASE_YEAR,'.xlsx')
  )
  addWorksheet(wb, '2_2_6_a')
  writeData(wb, sheet = "2_2_6_a", df_sum, colNames = T)
  saveWorkbook(wb,paste0('C:/Users/Matt/Documents/economic-fairness-gla/data/master-data/economc_fairness_master_',UPDATE__RELEASE_YEAR,'.xlsx'),overwrite = T)
  
  
  

# chart <- ''
#   
# 
# chart <-  dw_create_chart(
#   type='d3-bars-bullet',
#   folderId='266890',
#   title='Apprenticeships - starts rate per 100,000 working-age population: London versus Rest of England'
# )
# chart_id <- chart[[1]]$publicId 
# #wx27P



}

#export excel


