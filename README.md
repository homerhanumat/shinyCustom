# shinyCustom

This package is under development.  The aim is to automate, to some extent, the creation of custom objects for the RStudio's Shiny framework.

To see an example, try:

```
install.packages("htmltools")
devtools::install_github("homerhanumat/shinyCustom")
shiny::runApp(system.file("examples/shinyapp", package = "shinyCustom"),
              display.mode = "showcase")
```

At the present time the package supports three custom inputs, all of which are intended to allow the author of a Shiny app to inhibit updating so as to avoid expensive computations that the user probably did not intend.  The supported inputs are:

* `customTextInput()`
* `customNumericInput()`
* `customSliderInput()`

The first two inputs are "patient", in the sense that they update if and only if the user presses the Enter key or shifts focus away from the input control.

All three inputs permit the rate policy to be customized.  (For an explanation of rate policies, see [this RStudio article](http://shiny.rstudio.com/articles/building-inputs.html).

The procedure for invoking the features of the package is inspired by Dean Attali's [`shinyjs`](https://github.com/daattali/shinyjs).  Simply insert a call to `useShinyCustom()` within the UI, preferably near the top.  Here's an example:

```
library(shiny)
library(shinyCustom)

ui <- fluidPage(
  useShinyCustom(slider_delay = "!500"),
  customSliderInput(inputId = "slow", label = "I'm a Lazy Slider!",
                    min = 0, max = 100, value = 0),
  verbatimTextOutput("slowout")
)

server <- function(input, output) {
  output$slowout <- renderText({
    input$slow
  })
}

shinyApp(ui, server)
```
