library(shiny)
library(shinyCustom)

basicPage(
  useShinyCustom(slider_delay = 1500),
  title = "Inputs with Limited Update-Properties",
  h2("Slow Sliders"),
  p("These sliders wait longer than usual before updating."),
  customSliderInput(inputId = "input1", label = "A Slow Number Slider",
                 min = 0, max = 100, step = 1, value = 0),
  verbatimTextOutput("out1")
  ,
  customSliderInput(inputId = "input2", label = "A Slow Date Slider",
                  min = as.Date("2015-01-01"), max = as.Date("2015-12-31"),
                  step = 1, value = as.Date("2015-01-01")),
  verbatimTextOutput("out2"),
  h2("Patient Inputs"),
  p("This numeric input updates when you press enter or shift focus."),
  customNumericInput(inputId = "input3", label = "Patient Numeric",value = 0),
  verbatimTextOutput("out3"),
  p("This text input updates updates when you press enter or shift focus."),
  customTextInput("input4", label = "Patient Text"),
  verbatimTextOutput("out4"),
  h2("Codependency"),
  p("Application to a problem posed by Weicheng Zhu:"),
  sliderInput("slider", NULL, 0, 100, 0),
  customNumericInput("num", NULL, 0)
)
