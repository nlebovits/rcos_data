# pull all crime data


library(tidyverse)
library(sf)
library(rphl)
library(tmap)


## query city's crime data

# define url for city's carto database
base_url = "https://phl.carto.com/api/v2/sql"

# define variable for six years ago to filter crime down
six_years_ago = (lubridate::ymd(Sys.Date()) - lubridate::years(6))

# define SQL query for database
query = sprintf("
        select dispatch_date_time, text_general_code, point_x, point_y
        from incidents_part1_part2
        where dispatch_date_time  >= '%s'
        ", six_years_ago)

# query crimes
crimes = st_as_sf(get_carto(query,
                            format = 'csv',
                            base_url = base_url,
                            stringsAsFactors = FALSE) |>
                    filter(!is.na(point_x),
                           !is.na(point_y)),
                  coords = c("point_x", "point_y"),
                  crs = st_crs('EPSG:4326')) |>
  mutate(year = lubridate::year(dispatch_date_time)) |>
  filter( between (year, 2018, 2022) ) |>
  st_transform(crs = st_crs("EPSG:2272")) # project to PA South NAD 1983 US Ft