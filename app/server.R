# Run in R 3.5.2
source('global.R')



shinyServer(function(input, output, session) {
  
  # display the loading feature until data loads into app
  load_data()
  
  
  # Reactive Value to store all user data
  userData <- reactiveValues()
  
  
  # Bring in user data when they select directory
  volumes <- getVolumes()
  shinyDirChoose(input, 'directory', roots=volumes, session=session)
  path1 <- reactive({
    return(print(parseDirPath(volumes, input$directory)))
  })
  
  filesInDir <- reactive({
    list.files(paste(path1(),'/',sep=''), pattern='json|JSON')
  })
 
  
  # Files in directory preview for UI
  output$preview <- renderTable({
    req(filesInDir())
    filesInDir() })
  
  
  # The user data
  observeEvent(input$uploadFiles, { 
    userData$finalOut <- karenOrganizationShiny(path1()[1], list.files(paste(path1(),'/',sep=''), pattern='json|JSON') )  })

  
  # Don't let user click download button if no data available
  observe({ shinyjs::toggleState('downloadxlsx', length(userData$finalOut) != 0  )  })
  observe({ shinyjs::toggleState('downloadcsv', length(userData$finalOut) != 0  )  })
  
  
  # Download Excel File
  output$downloadxlsx<- downloadHandler( filename = function() { 
      paste( str_extract(paste(path1()[1],
                               list.files(paste(path1(),'/',sep=''), pattern='json|JSON')[1],sep='/'),
                         "[:alnum:]+\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_"),
             "summary.xlsx")},
    content = function(file) {
      write_xlsx(karenWriteShiny(path1()[1], list.files(paste(path1(),'/',sep=''), pattern='json|JSON') , userData$finalOut), path = file)}
  )
  
  
  # Download CSV
  
  output$downloadcsv <- downloadHandler( filename = function() {
      paste(str_extract(paste(path1()[1],
                              list.files(paste(path1(),'/',sep=''), pattern='json|JSON')[1],sep='/'),
                        "[:alnum:]+\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_"), "csvFiles.zip", sep="")
    },
    content = function(fname) {
      fs <- c()
      #tmpdir <- tempdir()
      z <- karenWriteShiny(path1()[1], list.files(paste(path1(),'/',sep=''), pattern='json|JSON') , userData$finalOut)
      #dir.create(paste0(path1()[1], '/data/'))
      for (i in 1:length(z)) {
        path <- paste0(#path1()[1], '/data/',
                       str_extract(paste(path1()[1],
                                         list.files(paste(path1(),'/',sep=''), pattern='json|JSON')[1],sep='/'),
                                   "[:alnum:]+\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_"),
                       names(z)[[i]], ".csv")
        fs <- c(fs, path)
        write.csv(data.frame(z[[i]]), path, row.names=F)
      }
      zip::zip(zipfile=fname, files=fs)
    },
    contentType = "application/zip"
  )

  
  ####--------------------------------------- RMARKDOWN SECTION--------------------------------------------------
  
  # Send input data to html report
  output$report <- downloadHandler(
    paste(unique(userData$finalOut[[1]][[1]]$SITE_ID),"_LandownerReport.html",sep=""),
    content= function(file){
      tempReport <- file.path(tempdir(),"landownerReport_fromApp.Rmd")
      print(list.files(tempdir()))
      imageToSend1 <- file.path(tempdir(),'NRSA logo_sm.png') # choose image name
      file.copy("landownerReport_fromApp.Rmd",tempReport,overwrite = T)
      file.copy(imageToSend1, 'NRSA logo_sm.png') # same name
      params <- list(userDataRMD=userData$finalOut)
      
      
      rmarkdown::render(tempReport,output_file = file,
                        params=params, envir=new.env(parent = globalenv()))})
      
      
  
  
  ## Send input data to html report
  #output$report <- downloadHandler(
  #  paste(unique(userData$finalOut[[1]][[1]]$SITE_ID),"_LandownerReport.html",sep=""),
  #  content= function(file){
  #    tempReport <- file.path(tempdir(),"landownerReport_fromApp.Rmd")
  #    file.copy("landownerReport_fromApp.Rmd",tempReport,overwrite = T)
  #    params <- list(userDataRMD=userData$finalOut)
  #    
  #    rmarkdown::render(tempReport,output_file = file,
  #                      params=params,envir=new.env(parent = globalenv()))})
  
  
  
  #output$verbatim1 <- renderPrint({unique(userData$finalOut[[1]][[1]]$SITE_ID)})
})