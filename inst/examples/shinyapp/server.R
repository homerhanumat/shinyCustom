function(input,output, session) {
  output$out1 <- renderText({
    input$input1
  })
  output$out2 <- renderText({
    as.character(input$input2)
  })
  output$out3 <- renderText({
    as.character(input$input3)
  })
  output$out4 <- renderText({
    input$input4
  })
  total = 10000
  observe({
    updateSliderInput(session, "slider", value = input$num/total*100)
  })

  observe({
    updateNumericInput(session, "num", value = input$slider*total/100)
  })
}
