# Run in R 3.5.2
source('global.R')



shinyServer(function(input, output, session) {
  
  # display the loading feature until data loads into app
  load_data()
  
  
  # Reactive Value to store all user data
  userData <- reactiveValues()
  
  
  volumes <- getVolumes()
  shinyDirChoose(input, 'directory', roots=volumes, session=session)
  path1 <- reactive({
    return(print(parseDirPath(volumes, input$directory)))
  })
  
  filesInDir <- reactive({
    list.files(paste(path1(),'/',sep=''), pattern='json|JSON')
  })
 
  output$preview <- renderTable({
    req(filesInDir())
    filesInDir() })
  
  
  observeEvent(input$uploadFiles, { 
    userData$finalOut <- karenOrganizationShiny(path1()[1], list.files(paste(path1(),'/',sep=''), pattern='json|JSON') )  })

  # Don't let user click download button if no data available
  observe({
    shinyjs::toggleState('downloadxlsx', length(userData$finalOut) != 0  )
  })
  observe({
    shinyjs::toggleState('downloadcsv', length(userData$finalOut) != 0  )
  })
  
  output$downloadxlsx<- downloadHandler(
    filename = function() { 
      paste( str_extract(paste(path1()[1],
                               list.files(paste(path1(),'/',sep=''), pattern='json|JSON')[1],sep='/'),
                         "[:alnum:]+\\_[:alpha:]+\\_[:alnum:]+\\_[:alnum:]\\_"),
             "summary.xlsx")},
    content = function(file) {
      write_xlsx(karenWriteShiny(path1()[1], list.files(paste(path1(),'/',sep=''), pattern='json|JSON') , userData$finalOut), path = file)}
  )
  
  
  
  output$downloadcsv <- downloadHandler(
    filename = function() {
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

  
  #output$verbatim1 <- renderPrint({length(userData$finalOut)})
})