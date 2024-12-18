#'[Script]#'*process-1_2_4_b.R*
#'[Project]#'*economic_fairness_gla (https://github.com/mawtee/economic-fairness-gla)*
#'[Author]#'*M. Tibbles*
#'[Last Update]#'*18/12/2024*
#'[Description]#'*This blah *
#'[____________________________________________________________________________]



scrape_and_write_zerohourgeo_data <- function(url, release_year) {
  
  #' @description 
  #' Scrapes latest zero hours contracts data from DFE site and writes to file
  #' 
  #' @details  
  #' 
  #' @param url String URL to DFE Apprenticeships data page. Defined in global `UPDATE__URL`
  #' @param release_year String data release year (e.g. 2022_23). Defined in global `UPDATE__RELEASE`
  #'
  #' @noRd
  print(paste0("Scraping zero hour (geography cut) data for ", release_year))
  #url <- 'https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/datasets/emp17peopleinemploymentonzerohourscontracts'
  #release_year <- '2023_24'
  
  # Load HTML page
  page <- rvest::read_html(url)
  # Scrape link to data download
  link <- page %>%
    html_nodes("a") %>%               # find all links
    html_attr("href") %>%             # find all urls
    str_subset(".xlsx")               # find the api download link
  link <- paste0('https://www.ons.gov.uk', link)
  
  # Download load
  temp <- tempfile()
  download.file(url=link, temp, mode = "wb")
  df <- read_excel(temp, sheet='4')
  if (dir.exists(paste0('data/raw-data/1_2_4_b-zerohour/', release_year))) {
    user_confirm <- readline("Directory for data update already exists. Are you sure you want to overwrite the existing directory? (y/n)")
    if (user_confirm=='y') {
      write_csv(df, paste0('data/raw-data/1_2_4_b-zerohour/', release_year,'/ons_zerohour_geography.csv'))
      unlink(temp)
    }
    else {
      stop(
        'Aborting update: user does does not want to overwrite existing directory'
      )
    }
  } 
  else {
    #if (!dir.exists(paste0('data/raw-data/3_2_5-homelessness/', release_year))) {
    dir.create(paste0('data/raw-data/1_2_4_b-zerohour/', release_year))
    write_csv(df, paste0('data/raw-data/1_2_4_b-zerohour/', release_year,'/ons_zerohour_geography.csv'))
    unlink(temp)
  }
  
}


load_and_clean_raw_zerohourgeo_data <- function(raw_path, data_year) {
  
  #' @description 
  #' Processes raw apprenticeships data downloaded from DfE.
  #' 
  #' @details 
  #' Raw apprenticeships data is loaded; columns renamed; regional filter applied and redundant variable dropped
  #'
  #' @param raw_path description
  #' @param data_year description
  #'
  #' @return `df_app_processed` Cleaned dataframe
  #' 
  #' @noRd
  
  #raw_path <- paste0(UPDATE__RAW_PATH,'/', UPDATE__RELEASE_YEAR)
  #data_year <- UPDATE__YEAR
  print(paste0("Loading and cleaning raw zero hour (geography cut) data for ", data_year-1,"/",data_year-2000))
  
  # Find geography-population file path (where path is not full CSV path e.g. in the UPDATE__RAW_PATH global)
  raw_file <- paste0(raw_path,'/',list.files(raw_path)[grepl('zerohour', list.files(raw_path))])
  
  # Load 
  df <- read_csv(raw_file, show_col_types=FALSE) 
  # Identify and flag row that contains column names
  df$flag_names <- rowSums(df=='UK', na.rm = TRUE) == 1
  # Get row number where data begins (where flag_names==1)
  begin <- which(grepl(T, df$flag_names))
  # Get row number where data ends (the last instance of update year)
  # Note. df needs to be double indexed [[]] for grepl to read as vector; in other words [[]] replicates behaviour of $
  end <- max(which(grepl(as.character(as.numeric(format(Sys.time(),"%Y"))), df[[1]])))
  # Create df of row length 1 containing only column names
  names_df <- df[begin:end, -ncol(df)] %>% filter(row_number()==1)
  # Rename NA column names with the colwise lag of column name
  # Note. This process effectively corrects for the lack of column names that results from merged cells in Excel
  colnames(names_df)[2:ncol(names_df)] <- lapply(
    2:ncol(names_df), function(x) {
      names_df[x] <- ifelse(is.na(names_df[[1, x]]), paste0(names_df[[1, x-1]],'_P'), names_df[[1, x]])
    })
  # Remove superfluous rows and flag_names column from df
  df <- df[begin:end, -ncol(df)]
  # Rename df columns with new names
  names(df)[1:ncol(df)] <- c('time_period', names(names_df)[-1])
  
  
  # Generated clean df
  df_processed <- df %>%
    #; Drop remaining NA-named columns
    select(-contains('NA_')) %>%
    #; Keep only percentage values (the right side of the merged columns that were initially not named)
    select(contains('_P')) %>%
    #; Drop remaining NA rows
    drop_na() %>%
    #; Drop redundant geographies
    select(time_period, UK_P, London_P) %>%
    #; Recode long form quarter dates as Qx
    mutate(time_period = case_when(
      grepl('Jan-Mar', time_period)~gsub('Jan-Mar', 'Q1', time_period),
      grepl('Apr-Jun', time_period)~gsub('Apr-Jun', 'Q2', time_period),
      grepl('Jul-Sep', time_period)~gsub('Jul-Sep', 'Q3', time_period),
      grepl('Oct-Dec', time_period)~gsub('Oct-Dec', 'Q4', time_period),
      T~time_period
    )) %>%
    # Re-order time period values (Qx after year)
    mutate(time_period = paste(substr(time_period, 4, 7), substr(time_period, 1,2))) %>%
    # Round percentage value
    mutate(across(!time_period,~ round(as.numeric(.x),2))) %>%
    # Remove '_P' from column names
    rename_with(~tolower(str_remove(., '_P')))  %>%
    # Add data year var and relocate
    mutate(data_year = as.numeric(UPDATE__YEAR)) %>%
    relocate(data_year, .after='time_period')

  return(df_processed)
  
}


  
  
  
  
  
  
  
  
  
  
  
  
  # 
  # 
  # 
  # 

    
#   
# 
#   
#   grepl()
#   
#   
#   
#   
#   
#   gfg <- c("7g8ee6ks1", "5f9o1r0", "geeks10")           
#   
#   gfg_numbers <- regmatches(gfg, gregexpr("[[:digit:]]+", gfg))
#     
#     df[1] == gregexpr("[0-9]+", df[1]))
#   
#   colnames(df) <- df$flag_names
#   df[which('UK' %in% , ]
#   df <- df[c(1, grepl('UK|London', names(df)))]
#   if (dir.exists(paste0('data/raw-data/3_2_5_a-roughleep/', release_year))) {
#     user_confirm <- readline("Directory for data update already exists. Are you sure you want to overwrite the existing directory? (y/n)")
#     if (user_confirm=='y') {
#       write_csv(df, paste0('data/raw-data/3_2_5_a-roughsleep/', release_year,'/CHAIN_rough_sleeping.csv'))
#       unlink(temp)
#     }
#     else {
#       stop(
#         'Aborting update: user does does not want to overwrite existing directory'
#       )
#     }
#   } 
#   else {
#     #if (!dir.exists(paste0('data/raw-data/3_2_5-homelessness/', release_year))) {
#     dir.create(paste0('data/raw-data/3_2_5_a-roughsleep/', release_year))
#     write_csv(df, paste0('data/raw-data/3_2_5_a-roughsleep/', release_year,'/CHAIN_roughsleep.csv'))
#     unlink(temp)
#   }
#   
# }