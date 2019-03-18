


karenOrganizationShiny <- function(path, filelist){
  finalOut <- list() #vector("list", length(filelist)) # preallocate list length to speed processing
  
  # Remove tracking information from parsing exercise
  filelist <- filelist[!str_detect(filelist,'TRACKING')]
  
  for(i in 1:length(filelist)){
    fileName <- paste(path,filelist[i],sep='/')
    
    print(fileName)
    
    # This step parses data and then organizes data in each file
    finalOut[[fileName %>% 
                str_replace("[:alnum:]+\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_",'') %>%
                str_replace('.json*','') %>% 
                str_replace('.*/','') ]] <- eFormsParseJSON(fileName) %>%
      eFormsOrganize_byTable()  }
  
    return(finalOut)
  }
    
#path = "C:/eFormsData/VA_RF008/" # need to define path first to get list.files command to work    
#finalList <- karenOrganizationShiny(path = "C:/eFormsData/VA_RF008/",
#                                filelist = list.files(paste(path,'/',sep=''), pattern='json|JSON') )





karenWriteShiny <- function(path, filelist, finalList, fileFormat){
  # Create the first part of the filename for writing to a .csv file, based on visit info and sample type
  subName.out <- str_extract(paste(path,filelist[1],sep='/'),"[:alnum:]+\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_")
  
  if( fileFormat == '.xlsx'){
    objLen <- map(finalList, length)
    specialCases <- names(objLen[objLen>2]) # deal with list objects with > 2 separately
    
    others <- finalList[!(names(finalList) %in% specialCases)]
    phab_channel <- finalList[specialCases] %>%
      map_df('channel') 
    phab_chanrip <- finalList[specialCases] %>%
      map_df('chanrip')
    phab_thalweg <- finalList[specialCases] %>%
      map_df('thalweg') 
    phab <- list(PHAB_channel = phab_channel, PHAB_chanrip = phab_chanrip, PHAB_thalweg = phab_thalweg)
    
    return(c(map(others,1),phab))

    #write_xlsx(c(map(others,1),phab), paste(path, subName.out,"summary.xlsx",sep=''))  
    }
  if( fileFormat == '.csv'){
    
    
    for(i in 1:length(finalList)){
      print(i)
      # This determines the number of data frames in the list output of finalOut and subtracts one 
      # because the last object in the list is always sample type
      numList <- length(finalList[[i]]) - 1
      # if there is only one dataframe in finalList, just add .csv to filename and write file
      if(numList==1){
        finalName.out <- paste(path,'/',subName.out,names(finalList)[i],".csv",sep='')    
        write.csv(finalList[[i]],finalName.out)
      }else{
        for ( j in 1:numList){
          # if there is more than one dataframe, for each data frame, add object name to file name, then write file
          finalName.out <- paste(path,'/',subName.out,names(finalList)[i],'_', names(finalList[[i]])[j],".csv",sep='')
          write.csv(finalList[[i]][j],finalName.out)
        }
      }
      
    }
  }
}

#z <- karenWriteShiny("C:/eFormsData/VA_RF008/", list.files(paste(path,'/',sep=''), pattern='json|JSON' ), finalList, '.xlsx')
#karenWriteShiny("C:/eFormsData/VA_RF008/", list.files(paste(path,'/',sep=''), pattern='json|JSON' ), finalList, '.csv')

