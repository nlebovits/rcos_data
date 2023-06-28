library(tidyverse)
library(sf)
library(arcpullr)
library(tmap)
library(janitor)
library(tidycensus)
library(acs)


tmap_mode('view')

crs <- 'epsg:2272'

# pull from city's databases

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


# city schools data
city_server <- 'https://services.arcgis.com/fLeGjb7u4uXqeF9q/arcgis/rest/services/'

queries <- '/FeatureServer/0'

city_datasets <- c(
  'Schools'
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


# acs pull

year <- 2020

vars <- c(
  "B15003_001E", #Total Pop 25+
  "B15003_017E", #Regular high school diploma
  "B15003_018E", #GED or alternative credential
  "B15003_019E", #Some college, less than 1 year
  "B15003_020E", #Some college, 1 or more years, no degree
  "B15003_021E", #Associate's degree
  "B15003_022E", #Bachelor's degree
  "B15003_023E", #Master's degree
  "B15003_024E", #Professional school degree
  "B15003_025E") #Doctorate degree 


phl_education <- get_acs(
                    geography = "tract",
                    year = year,
                    variables = vars,
                    geometry = TRUE,
                    state = "PA",
                    county = "Philadelphia",
                    output = "wide") |> 
                    mutate(
                      tot_pop_25plus = B15003_001E,
                      tot_hs_dip_or_alt = (B15003_017E + B15003_018E),  # Regular high school diploma + GED or alternative credential
                      tot_some_college = (B15003_019E + B15003_020E),  # Some college, less than one year + Some college, 1 or more years, no degree
                      tot_bach_plus = (
                        B15003_021E +  # Associate's degree
                          B15003_022E +  # Bachelor's degree
                          B15003_023E +  # Master's degree
                          B15003_024E +  # Professional school degree
                          B15003_025E), # Doctorate degree
                        pct_hs_or_equiv = (tot_hs_dip_or_alt / tot_pop_25plus),
                        pct_some_college = (tot_some_college / tot_pop_25plus),
                        pct_bach_plus = (tot_bach_plus / tot_pop_25plus)) |>
                  select(
                         GEOID,
                         NAME, 
                         tot_pop_25plus,
                         tot_hs_dip_or_alt,
                         tot_some_college,
                         tot_bach_plus,
                         pct_hs_or_equiv,
                         pct_some_college,
                         pct_bach_plus)
