#Housing
"B25064_001E", #Median gross rent
"B25070_007E", #Rent 30.0 to 34.9 percent
"B25070_008E", #Rent 35.0 to 39.9 percent
"B25070_009E", #Rent 40.0 to 49.9 percent
"B25070_010E", #Rent 50.0 percent or more
"B25003_002E", #Owner occupied
"B25003_003E", #Renter occupied
"B25001_001E", #Number of residential units
"B25002_002E", #Occupied
"B25002_003E", #Vacant
"B25077_001E", #Median house value (dollars)

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


