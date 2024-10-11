#'[Script]#'*process-backseries-2_2_6.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*08/10/2024*
#'[Description]#'*Defines all processing functions blah *
#'[____________________________________________________________________________]

# Process backseries data (2005/06-2016/17)
#===============================================================================

process_app_backseries_0516 <- function(app_names, pop_name) {
  
  #' @description 
  #' Processes apprenticeships back series data from the period 2005/06-2016/17
  #' 
  #' @details
  #' Apprenticeships data is taken directly from the source data Excel file from the GLA network drive. 
  #' Note that this data is no longer available for download online. Population data from NOMIS is merged 
  #' into backseries, permitting the creation of rate-based metrics, replicating the rate metrics
  #' included in the post-2016-17 DfE publications. Title of NOMIS population data is: 
  #' "Population estimates - local authority based by single year of age", with filter=16-64.
  #' 
  #' @param app_names Vector of strings (of n=2) providing the names of the backseries data files.
  #' There is one file for 'Starts' and another for 'Achievements'. Defined in global `BACKSERIES__APP_0516_NAMES`
  #' @param pop_name String name of the population data file. Defined in global `BACKSERIES__POP_0516_NAME`
  #' 
  #' @return `df_app rate` Processed partial (2005/06-2016/17) backseries, ready for merging with later data
  #' 
  #' @noRd
  print("Reprocessing backseries for 2005/07-2016/17")
  
  
  # Load, clean and reshape apprenticeships backseries data
  df_app_list <- lapply(
    app_names, function(file) {
      metric <- str_extract(file, c('starts','achievements'))[!is.na(str_extract(file, c('starts','achievements')))]
      tempdf <-
        read_csv(paste0('data/raw-data/2_2_6-apprenticeships/',file), show_col_types=FALSE) %>%
        pivot_longer(!Region, names_to='year', values_to=metric) %>%
        rename(
          'region_name'='Region',
          'time_period'='year') %>%
        mutate(year = as.numeric(as.character(substr(time_period, start = 1, stop = 4))))
      return(tempdf)
    }
  )
  # Merge Starts and Achievements dataframes
  df_app <- merge(df_app_list[[1]], df_app_list[[2]])
#   
  # Load, clean and reshape population data
  df_pop <-
    read_excel(paste0('data/raw-data/2_2_6-apprenticeships/',pop_name), skip=6) %>%
    drop_na() %>%
    select(-c(`Wales`, `Scotland`, `Northern Ireland`)) %>%
    pivot_longer(!Date, names_to='region_name', values_to='population') %>%
    mutate(region_name = case_when(region_name=='East'~'East of England', T~region_name)) %>%
    rename('year'='Date')

  # Add population estimates to apprenticeships data and generate rates
  df_app_rate <-
    left_join(df_app, df_pop, by=c('region_name', 'year'))  %>%
    mutate(year = year+1) %>% #  Adjust year variable to reflect latter year, and therefore data_year (the data_year variable is redundant for this back series, but relevant to the latter portion, since it indicates what series a given year is taken from - ik it's a bit messy here, my bad!)
    select(time_period, 'data_year'='year', region_name, population, starts, achievements)
  
  return(df_app_rate)

}

# Process backseries data (2017/18-Current)
#===============================================================================
process_app_backseries_17toCURR <- function(dirs, curr_year) {
  
  #' @description 
  #' Processes back series data from 2017/18 to current year.
  #' 
  #' @details  relies on function load_and_clean_raw_app_data, functionis is designed to be run prior to download of latest data. 
  #' For example, reprocessing up to 2022/23 breaks if I execute procedure when 2023 data is already downloaded.
  #' If you do want to to do this then remove -1 from definiton of curr_year global 
  #'
  #' @param dirs Character vector of paths to backseries data. Defined in global `BACKSERIES__17toCURR_DIRS`
  #' @param curr_year Numeric value of current year. Defined in global `BACKSERIES__CURR_YEAR`
  #'
  #' @return `df_clean` Processed partial (2017/18-current)backseries, ready for merging with later data
  #' 
  #' @noRd
  print(paste0("Reprocessing backseries for 2017/18-",curr_year-1,"/",curr_year-2000))
  
  
  # Do the following if latest backseries year is equal to curr_year (e.g. for 2022/23, 2023==2023)
  if (as.numeric(paste0('20',max(str_sub(dirs[length(dirs)], -2, -1))))==curr_year) {
    # Loop through backseries directories and read in (and process) geography-population table via process_raw_app_data()
    df_list  <- lapply(
      dirs, function(dir) {
        raw_path <- paste0(dir, '/data/', list.files(paste0(dir, '/data'))[grepl('geography-population', list.files(paste0(dir, '/data')))])
        data_year <- as.numeric(paste0('20',str_sub(dir,-2,-1)))
        year_df <- load_and_clean_raw_app_data(raw_path, data_year)
        return(year_df)
      }
    )
    # Append into dataframe 
    # Note. This dataframe will include duplicate records for at least one time_period
    df <- bind_rows(df_list)
    # Loop through each value of time_period and keep most recent record of time_period 
    # Note. This results in the elimination of duplicates
    df_clean_list <- lapply(
      sort(unique(df$time_period)), function(y) {
        last_occurence <- max(df$data_year[which(df$time_period==y)])
        df_year <- df %>% filter(time_period==y & data_year==last_occurence)
        return(df_year)
      }
    )
    # Append into dataframe
    df_clean <- bind_rows(df_clean_list)
    # Check for duplicates
    dupcheck <- ave(
      as.integer(paste0(substr(df_clean$time_period,1,4), substr(df_clean$time_period, 6,7))),
      df_clean$region_name, FUN = function(g) any(duplicated(g))) > 0
    # Return if all duplicates are removed (and exit function)
    if (all(dupcheck)==F) {
      return(df_clean)
    }
    
    # Return error if duplicates still exist
    else {
      stop(paste0(
        str_trim("Reprocessed dataframe contains duplicates values by year-region_name."),"\n",
        str_trim("Use debug function `browser()` at line 145 to identify problem years.")
      ))
    }
  }
  
  # Return error if latest backseries year does not equal curr_year
  else {
    stop(paste0(
      str_trim("Latest year in backseries data does not match latest year in global option."),"\n", 
       str_trim("Check that global option `BACKSERIES__CURR_YEAR` is correctly specified."), "\n",
       str_trim("Otherwise ensure that data for `BACKSERIES__CURR_YEAR` has already been processed and that files exist")
    ))
  }

}




