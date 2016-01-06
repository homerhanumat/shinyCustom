# shinyCustom

## Introduction

This package is under development.  It automates, to some extent, the creation of custom objects for the RStudio's Shiny framework.

To see an example, try:

```
install.packages("htmltools")
devtools::install_github("homerhanumat/shinyCustom")
shiny::runApp(system.file("examples/shinyapp", package = "shinyCustom"),
              display.mode = "showcase")
```

At the present time the package supports three custom inputs, all of which are intended to keep the Shiny server from having to perform expensive computations that the user probably did not need.  Typically this is accomplished by means of a "Submit"" action button, but in some apps the users may wish to perform so many computations that constant use of a Submit button becomes tiresome.  The inputs provided in this package solve the problem by restricting the conditions under which the input sends update-messages to the server, and/or by a rate policy that the author of the app can set.

The supported inputs are:

* `customTextInput()`
* `customNumericInput()`
* `customSliderInput()`

The first two inputs are "patient", in the sense that they update if and only if the user presses the Enter key or shifts focus away from the input control.

All three inputs permit the rate policy to be customized.  (For an explanation of rate policies, see [this RStudio article](http://shiny.rstudio.com/articles/building-inputs.html).

## Usage

The procedure for invoking the features of the package is inspired by Dean Attali's [`shinyjs`](https://github.com/daattali/shinyjs).  Simply insert a call to `useShinyCustom()` within the UI, preferably near the top.  Here's an example:

```
library(shiny)
library(shinyCustom)

ui <- fluidPage(
  useShinyCustom(slider_delay = "1500"),
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

## Limitations

At the present time the package can be used only with standard Shiny apps, not with interactive R Markdown documents or with apps where the user interface is built from an HTML file.  That shouldl change soon.

This package has not undergone much testing.  If you happen upon it feel free to give it a try, but do please post an issue when you find something going wrong.
