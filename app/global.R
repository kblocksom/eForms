library(shiny)
library(shinyjs)
library(shinyFiles)
library(reshape2)
library(plyr)
library(tidyverse)
library(RJSONIO)
library(stringr)
library(writexl)
library(zip)

#####################################   UPDATE EACH NEW TOOL REBUILD #############################################
assessmentCycle <- '2018-2019'
##################################################################################################################


# Loading screen
load_data <- function() {
  Sys.sleep(2)
  shinyjs::hide("loading_page")
  shinyjs::show("main_content")
}


source('functions/eFormsParseJSON_basic.r')
source('functions/eFormsParseJSONtext.r') 
source('functions/eFormsOrganizeData_byTable.r')

source('functions/karenParseEVJ.R')