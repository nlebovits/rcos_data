library(tidyverse)
library(sf)
library(arcpullr)
library(tmap)
library(janitor)

tmap_mode('view')

crs <- 'epsg:2272'


septa_server <- 'https://services2.arcgis.com/9U43PSoL47wawX5S/arcgis/rest/services/'
queries <- '/FeatureServer/0'

datasets <- c(
  'Bus_Routes',
  'SEPTA_-_Highspeed_Lines',
  'SEPTA_-_Highspeed_Stations',
  'SEPTA_-_Regional_Rail_Stations',
  'SEPTA_-_Trolley_Routes',
  'SEPTA_-_Trolley_Stops',
  'SEPTA_Facilities',
  'Bus_Ridership_by_Census_Tract'
)

names <- datasets %>%
            make_clean_names()

# Initialize an empty list to store the generated URLs
url_list <- list()

# Generate the URLs
for (dataset in datasets) {
  url <- paste0(septa_server, dataset, queries)
  url_list <- c(url_list, url)
}


# Use Map() to assign datasets to separate objects in the environment
Map(function(url, name) {
  tryCatch({
    dataset <- get_spatial_layer(url)
    assign(name, dataset, envir = .GlobalEnv)
  }, error = function(err) {
    if (grepl("return_geometry is NULL", conditionMessage(err))) {
      dataset <- get_table_layer(url)
      assign(name, dataset, envir = .GlobalEnv)
    } else {
      stop(err)
    }
  })
}, url_list, names)
