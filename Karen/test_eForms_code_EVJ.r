# test_eForms_code.r
# Purpose: use files submitted to process JSON files using a subset of Curt's code
#
# Created 2/27/2019 by Karen Blocksom
####################################################################################

library(reshape2)
library(plyr)
library(dplyr)
library(Hmisc)
library(gtools)
library(RJSONIO)
library(stringr)
#setwd("c:/users/kblockso/OneDrive - Environmental Protection Agency (EPA)/Documents/Parsing JSON data/")

source('Karen/eFormsParseJSON_basic.r')
source('Karen/eFormsParseJSONtext.r') 
source('Karen/eFormsOrganizeData_byTable.r')

# # This approach parses the data and then organizes it by form
# fishgearTest <- eFormsParseJSON("NRS18_AL_10001_2_FISHGEAR.json") %>%
#   eFormsOrganize_byTable()
# 
# fishTest <- eFormsParseJSON("NRS18_AL_10001_2_FISH.json") %>%
#   eFormsOrganize_byTable()
# 
# benthicTest <- eFormsParseJSON("NRS18_AL_10001_2_BENTHIC.json") %>%
#   eFormsOrganize_byTable()
#   
# verifTest <- eFormsParseJSON("NRS18_AL_10001_2_VERIFICATION.json") %>%
#   eFormsOrganize_byTable()
# 
# fieldTest <- eFormsParseJSON("NRS18_AL_10001_2_FIELD.json") %>%
#   eFormsOrganize_byTable()
# 
# samplesTest <- eFormsParseJSON("NRS18_AL_10001_2_SAMPLES.json") %>%
#   eFormsOrganize_byTable()
# 
# phabATest <- eFormsParseJSON("NRS18_AL_10001_2_PHAB_A.json") %>%
#   eFormsOrganize_byTable()
# 
# phabBTest <- eFormsParseJSON('NRS18_AL_10001_2_PHAB_B.json') %>%
#   eFormsOrganize_byTable()
# 
# phabBoatTest <- eFormsParseJSON("NRS18_AL_10008_1_PHAB_A.json") %>%
#   eFormsOrganize_byTable()
# 
# assessmentTest <- eFormsParseJSON("NRS18_AL_10001_2_ASSESSMENT.json") %>%
#   eFormsOrganize_byTable()
# 
# constraintTest <- eFormsParseJSON("NRS18_AL_10001_2_CONSTRAINT.json") %>%
#   eFormsOrganize_byTable()
# 
# constraintBTest <- eFormsParseJSON("NRS18_AL_10008_1_CONSTRAINT.json")
# 
# dischargeTest <- eFormsParseJSON("NRS18_AL_10001_2_discharge.json") %>%
#   eFormsOrganize_byTable()
# 
# slopeTest <- eFormsParseJSON("NRS18_AL_10001_2_SLOPE.json") %>%
#   eFormsOrganize_byTable()
# 
# torrentTest <- eFormsParseJSON("NRS18_AL_10001_2_TORRENT.json") %>%
#   eFormsOrganize_byTable()

# Alternative approach, which reads in all files in directory, then creates csv files as output
# setwd(paste(getwd(),"data/VA_RF008/NRS_VA_RF008_1",sep='')) # setwd doesn't work wiht Rprojects
# Create list of files in working directory with extension of json or JSON
filelist <- list.files(path= 'data/VA_RF008/',pattern='json|JSON') 

# Loop through file list
for(i in 1:length(filelist)){
  fileName <- filelist[i]
  print(i)
  
  # This step parses data and then organizes data in each file
  finalOut <- eFormsParseJSON(fileName) %>%
    eFormsOrganize_byTable()
  
  # Create the first part of the filename for writing to a .csv file, based on visit info and sample type
  subName.out <- str_extract(fileName,"NRS18\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_")
  sampName.out <- finalOut[["SAMPLE_TYPE"]]
  # This determines the number of data frames in the list output of finalOut and subtracts one 
  # because the last object in the list is always sample type
  numList <- length(finalOut) - 1
  
  for(j in 1:numList){
    # if there is only one dataframe in finalOut, just add .csv to filename and write file
    if(numList==1){
      finalName.out <- paste(subName.out,sampName.out,".csv",sep='')    
      write.csv(finalOut[[1]],finalName.out)
    }else{
      # if there is more than one dataframe, for each data frame, add object name to file name, then write file
      finalName.out <- paste(subName.out,sampName.out,"_",names(finalOut)[j],".csv",sep='')
      write.csv(finalOut[[j]],finalName.out)
    }
  }
  
}
