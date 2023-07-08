phl_demos <- get_acs(geography = "tract", # What is the lowest level of geography are we interested in?
                     year = 2020, # What year do we want - this can also be used for 2000 census data
                     variables = c(
                       #Population
                       "B01003_001E", #Total population
                       "B11001_001E", #Total number of households
                       "B09001_001E", #Total population under 18
                       "B09021_022", #Estimate!!Total:!!65 years and over:
                       "B01002_001", #Estimate!!Median age --!!Total:
                       
                       
                       #Race
                       "B02001_002E", #Total white population
                       "B02001_003E", #Total Black population
                       "B02001_004E", #American Indian and Alaska Native alone
                       "B02001_005E", #Total Asian population
                       "B02001_006E", #Native Hawaiian and Other Pacific Islander alone
                       "B02001_007E", #Some other race alone
                       "B02001_008E", #Two or more races
                       
                       #Ethnicitiy
                       "B01001I_001E", #Total: Hispanic or Latino (distinct from race)