library(tidyverse)
library(DatawRappr)

# Global Options
PUBLICATION_YEAR <- format(Sys.time(),"%Y")
INPUT_PATH <- paste0('processed-data/2_2_6-apprenticeships/2_2_6_a/2_2_6_a-processed-pub',PUBLICATION_YEAR,'.csv')

#===============================================================================

# Load data
df <- read_csv(INPUT_PATH)

# Declare data wrapper key 
key <- 'YFdh5P5bJcllD8leFsnnZMFB0wGberKn105tv5SJC0xAcCny6WTyunpzMSRt4bhc' 
datawrapper_auth(api_key = key, overwrite=T)
dw_test_key()

# Add latest data
dw_data_to_chart(
  x=df,
  chart_id='GArQ8'
)





# # Create chart
# chart <- dw_create_chart(
#   type='column-chart',
#   folderId='266890',
#   title='Apprenticeships: Starts and Completions - London'
# )
# dw_data_to_chart(df, chart) 




# need to work out how to fully customise the chart with groupings and shit
# color etc.

# Then have oen code chunk for creation and one for updating
