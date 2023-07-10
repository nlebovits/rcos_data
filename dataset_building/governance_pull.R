### governance pull

library(tidyverse)
library(sf)
library(janitor)
library(rphl)
library(arcpullr)
library(tmap)
library(rvest)
library(hacksaw)
library(tigris)



options(tigris_use_cache = TRUE)

crs <- "epsg:2272"
state <- "PA"


# Specify the URL of the webpage
url <- "https://vote.phila.gov/voting/current-elected-officials/elected-officials-in-philadelphia-county/"

# Use the 'read_html' function to read the HTML content of the webpage
page <- read_html(url)

# Select the <td> element(s) you want to extract
td_elements <- html_nodes(page, "td")

# Extract the text contents of each <td> element
td_contents <- html_text(td_elements)

# Split the contents into columns based on the delimiter '\n'
columns <- strsplit(td_contents, "\n")

# Determine the number of columns
num_columns <- max(lengths(columns))

# Create a dataframe with empty columns
df <- data.frame(matrix(ncol = num_columns, nrow = 0))

# Add the contents to the dataframe
for (i in 1:num_columns) {
  column <- unlist(lapply(columns, "[", i))
  df <- rbind(df, column)
}

# Reset column names
colnames(df) <- NULL

df <- df %>%
        t() %>%
        data.frame()

rows_to_shift <- which(df$X1 == "") #return indices of rows at whihc X1 is not empty

df$X1[df$X1 == ""] <- NA

df <- df %>%
      shift_row_values(.dir = "left", at = rows_to_shift) %>%
      filter(X1 != "") %>%
      select(X1, X2)

colnames <- c("name", "district")
colnames(df) <- colnames

df$position <- c("Mayor",
                 "District Attorney",
                 "City Controller",
                 "Register of Wills",
                 "Sheriff",
                 rep("City Commissioner", 3),
                 rep("City Council Member", 17),
                 "Governor",
                 "Lieutenant Governor",
                 "Attorney General",
                 "State Treasurer",
                 "Auditor General",
                 rep("State Representative", 26),
                 rep("State Senator", 7),
                 rep("United States Senator", 2),
                 rep("United States Representative", 3))


df$name <- df$name %>% 
              str_remove_all("Mayor") %>%
              str_remove_all("District Attorney") %>%
              str_remove_all( "City Controller") %>%
              str_remove_all( "Register of Wills") %>%
              str_remove_all( "Sheriff") %>%
              str_remove_all("Governor") %>%
              str_remove_all("Lieutenant Governor") %>%
              str_remove_all("Attorney General") %>%
              str_remove_all("State Treasurer") %>%
              str_remove_all("Auditor General")

df$party <- str_extract(df$name, "\\((.*?)\\)")
df$name <- str_trim(str_remove(df$name, "\\(.*?\\)"))
df$party <- gsub("[()]", "", df$party)
df$district <- ifelse(!grepl("^(District|At-Large)", df$district), NA, df$district)




# import city political boundaries

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

city_server <- 'https://services.arcgis.com/fLeGjb7u4uXqeF9q/arcgis/rest/services/'

city_datasets <- c(
  'City_Limits',
  'Council_Districts_2016'
)

queries <- '/FeatureServer/0'

city_names <- city_datasets %>% make_clean_names()

# Initialize an empty list to store the generated URLs
city_url_list <- list()

# Generate the URLs
for (dataset in city_datasets) {
  url <- paste0(city_server, dataset, queries)
  city_url_list <- c(city_url_list, url)
}

Map(assign_dataset, city_url_list, city_names)

city_limits <- city_limits %>%
                st_transform(crs = crs)

council_districts_2016 <- council_districts_2016 %>%
                                  st_transform(crs = crs)
                  


# import state political boundaries

  # state senate dists
state_senate <- state_legislative_districts(state = state, house = "upper", year = 2023)  %>%
  st_transform(crs = crs)
state_senate$district <- str_extract_all(state_senate$NAMELSAD, "\\d+") 

# state rep dists
state_reps <- state_legislative_districts(state = state, house = "lower", year = 2023)  %>%
  st_transform(crs = crs)
state_reps$district <- str_extract_all(state_reps$NAMELSAD, "\\d+")



  # us rep dists
us_reps <- congressional_districts(state = state)  %>%
  st_transform(crs = crs)
us_reps$district <- str_extract_all(us_reps$NAMELSAD, "\\d+")


df$dist_num <- str_extract_all(df$district, "\\d+")
df$dist_num[df$dist_num %in% c("NANA", 'character(0)')] <- NA

city_lims_politicians <- c("Mayor",
                           "District Attorney",
                           "City Controller",
                           "Register of Wills",
                           "Sheriff",
                           "City Commissioner",
                           "Governor",
                           "Lieutenant Governor",
                           "Attorney General",
                           "State Treasurer",
                           "Auditor General",
                           "United States Senator")


## there has to be a prettier way of writing this, I know.
## but I couldn't figure it out quickly, so I left it.

df$geometry <- NA
df$geometry[df$position %in% city_lims_politicians] <- city_limits$geoms
df$geometry[grepl("City Council", df$position) & df$district == "At-Large"] <- city_limits$geoms
df$geometry[grepl("City Council", df$position) & df$district != "At-Large"] <- council_districts_2016$geoms[grepl("City Council", df$position) & df$district != "At-Large"][council_districts_2016$DISTRICT == df$dist_num]


for (i in which(grepl("City Council", df$position) & df$district != "At-Large")) {
  df$geometry[i] <- council_districts_2016$geoms[council_districts_2016$DISTRICT == df$dist_num[i]]
}

for (i in which(grepl("United States Representative ", df$position))) {
  df$geometry[i] <- us_reps$geometry[us_reps$district == df$dist_num[i]]
}

state_senate_nums <- df$dist_num[df$position == "State Senator"]
for (dist_num in state_senate_nums) {
  df$geometry[df$position == "State Senator" & df$dist_num == dist_num] <- state_senate$geometry[state_senate$district == dist_num]
}

state_reps_nums <- df$dist_num[df$position == "State Representative"]
for (dist_num in state_reps_nums) {
  df$geometry[df$position == "State Representative" & df$dist_num == dist_num] <- state_reps$geometry[state_reps$district == dist_num]
}

us_reps_nums <- df$dist_num[df$position == "United States Representative"]
for (dist_num in us_reps_nums) {
  df$geometry[df$position == "United States Representative" & df$dist_num == dist_num] <- us_reps$geometry[us_reps$district == dist_num]
}


df <- st_as_sf(df, sf_column_name = "geometry", crs = "epsg:2272") %>%
          st_transform(crs = crs)

tm_shape(state_reps$geometry[state_reps$NAMELSAD == "State House District 10"]) +
  tm_polygons(alpha = 0.5, id = "district")

tm_shape(state_reps[city_limits, ]) +
  tm_polygons(id = "district")

