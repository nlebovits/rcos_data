library(tidyverse)
library(sf)
library(janitor)
library(tidycensus)
library(lehdr) #https://github.com/jamgreen/lehdr


var_list<-load_variables(2020,'acs5')

#census var ideas

#B23001_001 total employment 16 years +
#B23001_088 female EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER

#B08126_001 MEANS OF TRANSPORTATION TO WORK BY INDUSTRY
census_api_key("746ea8916547306ae2abf2aafe059e1a1b70b98a")


#more census variables should be added
vars <- c("B23001_001",'B23001_088','B08126_001')

year <- 2019

phl_acs <- get_acs(
  geography = "tract",
  year = year,
  variables = vars,
  geometry = TRUE,
  state = "PA",
  county = "Philadelphia",
  output = "wide") %>% 
  mutate()

#residential area characteristics
pa_rac_load  <- grab_lodes(state = "pa", 
                    year = year, 
                    #version = "LODES8", 
                    lodes_type = "rac", 
                    job_type = "JT01",
                    segment = "S000", 
                    state_part = "main", 
                    agg_geo = "tract") 

pa_rac <- pa_rac_load %>% 
  rename(total_jobs_rac = C000,
         age_29_or_younger_rac = CA01,
         age_30_to_54_rac = CA02,
         age_55_or_older_rac = CA03,
         monthly_income_1250_or_less_rac = CE01,
         monthly_income_1251_to_3333_rac = CE02,
         monthly_income_3334_or_more_rac = CE03,
         agriculture_rac = CNS01, # agriculture, forestry, fishing, hunting / NAICS11
         mining_rac = CNS02, # mining, oil/gas extraction / MAICS21
         utilities_rac = CNS03, # utilities / NAICS22
         construction_rac = CNS04, # construction / NAICS23
         manufacturing_rac = CNS05, # manufacturing /NAICS31 and NAICS33
         wholesaleTrade_rac = CNS06, # wholesale trade / NAICS42
         retailTrade_rac = CNS07, # retail trade / 44/46
         transportationWarehousing_rac = CNS08, # transportation and warehousing / 48, 49
         informationTech_rac = CNS09, # information /51
         financeInsurance_rac = CNS10, # finance and insurance /52
         realEstate_rac = CNS11, # real estate /53
         techServices_rac = CNS12, # professional, scientific, and tech services /54
         management_rac = CNS13, # management (enterprise) /55
         wasteRemediation_rac = CNS14, # waste / remediation /56
         educational_rac = CNS15, # education /61
         healthcareSocial_rac = CNS16, # healthcare/social services /62
         artsEntertainmentRec_rac = CNS17, # arts/entertainment/rec /71
         foodServices_rac = CNS18, # food services /72
         otherJobs_rac = CNS19, # other /81
         publicAdmin_rac = CNS20, # public admin /92
         white_work_rac = CR01,
         black_work_rac = CR02,
         native_american_work_rac = CR03,
         asian_work_rac = CR04,
         pacific_work_rac = CR05,
         mixed_race_work_rac = CR07,
         not_hispanic_work_rac = CT01,
         hispanic_work_rac = CT02,
         male_work_rac = CS01,
         female_work_rac = CS02,
         underHS_work_rac = CD01,
         HS_work_rac = CD02,
         associate_work_rac = CD03,
         bachProfessional_work_rac = CD04)

phl_econ <- left_join(phl_acs, pa_rac, by = c('GEOID' = 'h_tract'))

#Work area characteristics
pa_wac_load  <- grab_lodes(state = "pa", 
                           year = year, 
                           #version = "LODES8", 
                           lodes_type = "wac", 
                           job_type = "JT01",
                           segment = "S000", 
                           state_part = "main", 
                           agg_geo = "tract") 

pa_wac <- pa_wac_load %>% 
  rename(total_jobs_wac = C000,
         age_29_or_younger_wac = CA01,
         age_30_to_54_wac = CA02,
         age_55_or_older_wac = CA03,
         monthly_income_1250_or_less_wac = CE01,
         monthly_income_1251_to_3333_wac = CE02,
         monthly_income_3334_or_more_wac = CE03,
         agriculture_wac = CNS01, # agriculture, forestry, fishing, hunting / NAICS11
         mining_wac = CNS02, # mining, oil/gas extwaction / MAICS21
         utilities_wac = CNS03, # utilities / NAICS22
         construction_wac = CNS04, # construction / NAICS23
         manufacturing_wac = CNS05, # manufacturing /NAICS31 and NAICS33
         wholesaleTrade_wac = CNS06, # wholesale trade / NAICS42
         retailTrade_wac = CNS07, # retail trade / 44/46
         transportationWarehousing_wac = CNS08, # transportation and warehousing / 48, 49
         informationTech_wac = CNS09, # information /51
         financeInsurance_wac = CNS10, # finance and insurance /52
         realEstate_wac = CNS11, # real estate /53
         techServices_wac = CNS12, # professional, scientific, and tech services /54
         management_wac = CNS13, # management (enterprise) /55
         wasteRemediation_wac = CNS14, # waste / remediation /56
         educational_wac = CNS15, # education /61
         healthcareSocial_wac = CNS16, # healthcare/social services /62
         artsEntertainmentRec_wac = CNS17, # arts/entertainment/rec /71
         foodServices_wac = CNS18, # food services /72
         otherJobs_wac = CNS19, # other /81
         publicAdmin_wac = CNS20, # public admin /92
         white_work_wac = CR01,
         black_work_wac = CR02,
         native_american_work_wac = CR03,
         asian_work_wac = CR04,
         pacific_work_wac = CR05,
         mixed_race_work_wac = CR07,
         not_hispanic_work_wac = CT01,
         hispanic_work_wac = CT02,
         male_work_wac = CS01,
         female_work_wac = CS02,
         underHS_work_wac = CD01,
         HS_work_wac = CD02,
         associate_work_wac = CD03,
         bachProfessional_work_wac = CD04)

phl_econ <- left_join(phl_econ, pa_wac, by = c('GEOID' = 'w_tract'))


# get difference between # of employees vs # of jobs in tract
#ppl who live there - ppl who work there
phl_econ1 <- phl_econ %>% mutate(
         total_jobs_diff = total_jobs_rac - total_jobs_wac ,
         age_29_or_younger_diff = age_29_or_younger_rac- age_29_or_younger_wac,
         age_30_to_54_diff = age_30_to_54_rac-age_30_to_54_wac,
         age_55_or_older_diff = age_55_or_older_rac-age_55_or_older_wac,
         monthly_income_1250_or_less_diff = monthly_income_1250_or_less_rac -monthly_income_1250_or_less_wac ,
         monthly_income_1251_to_3333_diff = monthly_income_1251_to_3333_rac -monthly_income_1251_to_3333_wac ,
         monthly_income_3334_or_more_diff = monthly_income_3334_or_more_rac-monthly_income_3334_or_more_wac,
         agriculture_diff = agriculture_rac -agriculture_wac , # agriculture, forestry, fishing, hunting / NAICS11
         mining_diff = mining_rac-mining_wac, # mining, oil/gas extraction / MAICS21
         utilities_diff = utilities_rac-utilities_wac, # utilities / NAICS22
         construction_diff = construction_rac-construction_wac, # construction / NAICS23
         manufacturing_diff = manufacturing_rac-manufacturing_wac, # manufacturing /NAICS31 and NAICS33
         wholesaleTrade_diff = wholesaleTrade_rac-wholesaleTrade_wac, # wholesale trade / NAICS42
         retailTrade_diff = retailTrade_rac-retailTrade_wac, # retail trade / 44/46
         transportationWarehousing_diff = transportationWarehousing_rac-transportationWarehousing_wac, # transportation and warehousing / 48, 49
         informationTech_diff = informationTech_rac-informationTech_wac, # information /51
         financeInsurance_diff = financeInsurance_rac-financeInsurance_wac, # finance and insurance /52
         realEstate_diff = realEstate_rac-realEstate_wac, # real estate /53
         techServices_diff = techServices_rac-techServices_wac, # professional, scientific, and tech services /54
         management_diff = management_rac-management_wac, # management (enterprise) /55
         wasteRemediation_diff = wasteRemediation_rac-wasteRemediation_wac, # waste / remediation /56
         educational_diff = educational_rac-educational_wac, # education /61
         healthcareSocial_diff = healthcareSocial_rac-healthcareSocial_wac, # healthcare/social services /62
         artsEntertainmentRec_diff = artsEntertainmentRec_rac-artsEntertainmentRec_wac, # arts/entertainment/rec /71
         foodServices_diff = foodServices_rac-foodServices_wac, # food services /72
         otherJobs_diff = otherJobs_rac-otherJobs_wac, # other /81
         publicAdmin_diff = publicAdmin_rac-publicAdmin_wac, # public admin /92
         white_work_diff = white_work_rac-white_work_wac,
         black_work_diff = black_work_rac-black_work_wac,
         native_american_work_diff = native_american_work_rac-native_american_work_wac,
         asian_work_diff = asian_work_rac-asian_work_wac,
         pacific_work_diff = pacific_work_rac-pacific_work_wac,
         mixed_race_work_diff = mixed_race_work_rac-mixed_race_work_wac,
         not_hispanic_work_diff = not_hispanic_work_rac-not_hispanic_work_wac,
         hispanic_work_diff = hispanic_work_rac-hispanic_work_wac,
         male_work_diff = male_work_rac-male_work_wac,
         female_work_diff = female_work_rac-female_work_wac,
         underHS_work_diff = underHS_work_rac-underHS_work_wac,
         HS_work_diff = HS_work_rac-HS_work_wac,
         associate_work_diff = associate_work_rac-associate_work_wac,
         bachProfessional_work_diff = bachProfessional_work_rac-bachProfessional_work_wac)

## viz 
ggplot(phl_econ1)+
  geom_sf(aes(fill = financeInsurance_wac))
