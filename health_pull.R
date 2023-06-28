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


# city health data
city_server <- 'https://services.arcgis.com/fLeGjb7u4uXqeF9q/arcgis/rest/services/'

queries <- '/FeatureServer/0'

city_datasets <- c(
  'Health_Centers',
  'Farmers_Markets',
  'Vital_Natality_Cty',
  'Vital_Mortality_Cty',
  'HEAT_EXPOSURE_CENSUS_TRACT'
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