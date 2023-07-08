#Housing
#Housing ACS
library(tidycensus)
library(tidyverse)

#census_api_key(get_env(.env), install=TRUE, overwrite=TRUE)
#Define survey year & survey 
year <- 2021
dataset <- "acs5"
# Set the geographic resolution to census tracts
geo_res <- "tract"
# Set the state and county FIPS code for Philadelphia
state <- "PA"
county <- "101"

# Get the census variables of interest
variables <- c("B25064_001E", #Median gross rent
               "B25070_007E", #Rent 30.0 to 34.9 percent
               "B25070_008E", #Rent 35.0 to 39.9 percent
               "B25070_009E", #Rent 40.0 to 49.9 percent 
               "B25070_010E", #Rent 50.0 percent or more
               "B25003_002E", #Owner occupied
               "B25003_003E", #Renter occupied
               "B25001_001E", #Number of residential units
               "B25002_002E", #Occupied
               "B25002_003E", #Vacant
               "B25077_001E"  #Median house value (dollars) 
)
#TODO: refactor this so 'variables' and 'replacements' are more descriptive

# Define the replacements
replacements <- c(
  "B25003_002" = "Owner occupied",
  "B25003_003" = "Renter occupied",
  "B25001_001" = "Number of residential units",
  "B25002_002" = "Occupied",
  "B25002_003" = "Vacant",
  "B25064_001" = "Median gross rent",
  "B25070_007" = "Rent 30.0 to 34.9 percent",
  "B25070_008" = "Rent 35.0 to 39.9 percent",
  "B25070_009" = "Rent 40.0 to 49.9 percent",
  "B25070_010" = "Rent 50.0 percent or more",
  "B25077_001" = "Median house value (dollars)"
)

# Query the census data
philly_data <- get_acs(
  geography = geo_res,
  variables = variables,
  year = year,
  survey = dataset,
  state = state,
  county = county
) 

# Replace the strings in the "variable" column
df <- mutate(philly_data, variable = str_replace_all(variable, replacements))

df_pivot <- df %>%
  pivot_wider(
    id_cols = c("GEOID", "NAME"),
    names_from = "variable",
    values_from = c("estimate", "moe"),
    names_sep = "_"
  )

#Eviction Lab
library(httr)
#Monthly 2016-2019	Census Tract
r <- GET("https://evictionlab.org/uploads/philadelphia_monthly_2020_2021.csv")
# Save to file
bin <- content(r, "raw")
writeBin(bin, "data.csv")
# Read as csv
Philadelphia_MONTHLY_Evictions = read.csv("data.csv", header = TRUE, dec = ",")

#Weekly
r <- GET("https://evictionlab.org/uploads/philadelphia_weekly_2020_2021.csv")
# Save to file
bin <- content(r, "raw")
writeBin(bin, "data.csv")
# Read as csv
Philadelphia_WEEKLY_Evictions = read.csv("data.csv", header = TRUE, dec = ",")

#QUESTIONS:
#how can we programatically query https://preservationdatabase.org/?
#if it's static, can we store in an s3 bucket or as github user content?
#How should we handle census api for tidycensus?


