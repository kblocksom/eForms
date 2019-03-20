library(tidyverse)
z <- readRDS('testData.RDS')

## General site stuff
dplyr::filter(z[['VERIFICATION']], PARAMETER %in% c('SITE_ID','VISIT_NO', "DATE_COL","LOC_NAME","CREW",
                                                    "ACTUAL_LAT_DD","ACTUAL_LON_DD","VALXSITE",'ADD_SITE_CHAR',
                                                    "GEN_COM","DRCTNS","RCHWIDTH","TRCHLEN","CREW_LEADER"))
# lat/lon for leaflet map, crew leader will have option to enter text box with contact information for inclusion in report
# If we really wanted to get fancy we could have user access nhdplus layer, snap X point to segment(s), clip segments by 
#   upstream/downstream reach length, dissolve to single segment, then project that single segment on to leaflet map
#   so people get an idea of what we actually sampled


## Field parameters
dplyr::filter(z[['FIELD']], PARAMETER %in% c("DO_DISPLAYED_UNITS" ,"LOCATION","TIME" ,"DO","TEMPERATURE" ,
                                             "PH","CONDUCTIVITY","CORRECTED"))

## samples collected
unique(z[['SAMPLES']]$SAMPLE_TYPE)[!(unique(z[['SAMPLES']]$SAMPLE_TYPE) %in% 'SAMP')]
# and a little blurb about what each sample will tell us

## Fish are sexy, people want this 
dplyr::filter(z[['FISHGEAR']], PARAMETER %in% c('FISH_PROTOCOL','WATER_VIS','PRIM_FSHTIME','PRIM_LENGTH_FISHED',
                                             'PRIM_GEAR','SEC_GEAR','SEC_FSHTIME'))
# then add up total fish time to single number, is the unit always seconds??
dplyr::filter(z[['FISH']], SAMPLE_TYPE == 'FISH') %>%
  dplyr::filter(PARAMETER %in% c('NAME_COM', 'COUNT_6')) 
# and other count variables, I assume these are size classes?
# add up each size class to single taxa count
# don't include fish tissue or voucher counts, that will make people sad

## Assessment info
dplyr::filter(z[['ASSESSMENT']], PARAMETER %in% c('WEATHER','CONDITIONS','OBSERVATIONS','BEAVER_SIGN','BEAVER_FLOW_MOD'))
# I dont think we should include pristine/appealing or landuse, but I could be talked into it and 
# put all this in table format