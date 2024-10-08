#'[Script]#'*process_apprenticeships.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*02/10/2024*
#'[Description]#'*This processes the latest apprenticeship data, generating data*
#'*tables ready for plotting. It is advised to run this script within the the master* 
#'[____________________________________________________________________________]


# # Load ata
# #-----------------
# process_raw_app_data <- function(year, path) {
#   
#   df_app_processed <- read_csv(path) %>%
#     rename_with(~str_extract(.x, 'population'), matches('population_')) %>%
#     rename_with(~str_extract(.x, 'age'), matches('age_')) %>%
#     rename_with(~gsub('apps', 'app', .x), matches('apps')) %>%
#     filter(
#       app_level=='Total',
#       age=='Total',
#       geographic_level=='Regional',
#       !str_detect(region_name, 'Outside')
#     ) %>%
#     mutate(`year` = year) %>%
#     select(time_period, year, geographic_level, country_name, region_name, population, starts, achievements, achievements_rate_per_100000_population,  achievements_rate_per_100000_population) %>%
#     mutate(across(c(starts, achievements, contains('rate')), ~as.numeric(as.character(.x))))
#   
# }


# 
# 
# # Starts London versus Rest of England (2_2_6_a)
# #--------------------------------------------
# 
# # Load existing data table
# df__2_2_6_a <- read_csv(paste0(PROCESSED_PATH,'/2_2_6_a/2_2_6_a-processed-pub',as.numeric(format(Sys.time(),"%Y"))-1,'.csv'))
# # Create data table with data for latest year
# df__2_2_6_a__update <- df %>%
#   filter(geographic_level=='Regional' & region_name=='London') %>%
#   mutate(year_numeric = as.numeric(substr(time_period, 1, 4))) %>%
#   filter(year_numeric == max(year_numeric)) %>%
#   select(Year=time_period, `Total starts`=starts, `Total achievements`=achievements) 
# # Append data for latest year and save (if year does not exist in existing table)
# if (df__2_2_6_a$Year[nrow(df__2_2_6_a)] != df__2_2_6_a__update$Year[1]) {
#   print(paste0('Adding data from latest release (',PUBLICATION_YEAR,') to existing data table'))
#   df__2_2_6_a <- df__2_2_6_a %>% bind_rows(df__2_2_6_a__update)
#   write_csv(df__2_2_6_a, paste0(OUTPUT_PATH,'/2_2_6_a/2_2_6_a-processed-pub',PUBLICATION_YEAR,'.csv'))
# }
# if (df__2_2_6_a$Year[nrow(df__2_2_6_a)] == df__2_2_6_a__update$Year[1]) {
#   cat(paste0('Error: Data from latest release (',PUBLICATION_YEAR,') already exists in existing data!
#              \n  Update for ',PUBLICATION_YEAR,' has already been conducted.
#              \n  Or data for ',PUBLICATION_YEAR,' has not been released.'))
# }
#   
# 
#  
# 
# 
# 
# 
# 
# 
# 
#  
# # Starts and Completions England (2_2_6_b)
# df %>%
#   filter(geographic_level=='National') %>%
#   mutate(year_numeric = as.numeric(substr(time_period, 1, 4))) %>%
#   filter(year_numeric == max(year_numeric)) %>%
#   select(Year=time_period, `Total Starts`=starts, `Total Achievements`=achievements) %>%
#   write_csv(paste0(OUTPUT_PATH,'2_2_6_b-processed.csv'))
# 
# # Completion rate London versus England (2_2_6_c)
# df3 <- df %>%
#   filter(geographic_level=='Regional' & region_name=='London'|geographic_level=='National') %>%
#   select(-c(country_name, region_name, starts, achievements)) %>%
#   mutate(geographic_level = case_when(geographic_level=='National'~ 'England', T~'London')) %>%
#   write_csv(paste0(OUTPUT_PATH,'2_2_6_c-processed.csv'))
# 
