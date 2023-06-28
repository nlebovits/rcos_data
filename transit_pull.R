library(tidyverse)
library(sf)
library(arcpullr)
library(tmap)
library(janitor)

tmap_mode('view')

crs <- 'epsg:2272'

# Define the function to assign datasets to objects in the environment
assign_dataset <- function(url, name) {
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
}


# septa data

# septa data
septa_server <- 'https://services2.arcgis.com/9U43PSoL47wawX5S/arcgis/rest/services/'
septa_datasets <- c(
  'Bus_Routes',
  'SEPTA_-_Highspeed_Lines',
  'SEPTA_-_Highspeed_Stations',
  'SEPTA_-_Regional_Rail_Stations',
  'SEPTA_-_Trolley_Routes',
  'SEPTA_-_Trolley_Stops',
  'SEPTA_Facilities',
  'Bus_Ridership_by_Census_Tract'
)
queries <- '/FeatureServer/0'
septa_names <- septa_datasets %>% make_clean_names()

# Initialize an empty list to store the generated URLs
septa_url_list <- list()

# Generate the URLs
for (dataset in septa_datasets) {
  url <- paste0(septa_server, dataset, queries)
  septa_url_list <- c(septa_url_list, url)
}

Map(assign_dataset, septa_url_list, septa_names)


# city datasets

city_server <- 'https://services.arcgis.com/fLeGjb7u4uXqeF9q/arcgis/rest/services/'

city_datasets <- c(
  'Bike_Network',
  'COLLISION_CRASH_2016_2020'
)

city_names <- city_datasets %>% make_clean_names()

# Initialize an empty list to store the generated URLs
city_url_list <- list()

# Generate the URLs
for (dataset in city_datasets) {
  url <- paste0(city_server, dataset, queries)
  city_url_list <- c(city_url_list, url)
}

Map(assign_dataset, city_url_list, city_names)
