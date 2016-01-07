#' Use the shinyCustom Package
#'
#' @description Injects into the Shiny app the JavaScript required to create
#' custom objects.
#'
#' @param slider_policy Policy for a custom slider.  Values are 'debounce' (the
#' default) and 'throttle'.
#' @param slider_delay Delay for a custom slider.  Values are in milliseconds.  The
#' default is 250 (same as for a regular slider).
#' @param numeric_policy Policy for a custom numeric input.  Values are 'debounce'
#' (the default) and 'throttle'.
#' @param numeric_delay Delay for a custom numeric input.  Values are in milliseconds.
#' The default is 250 (same as for a regular numeric input).
#' @param text_policy Policy for a custom text input.  Values are 'debounce'
#' (the default) and 'throttle'.
#' @param text_delay Delay for a custom text input.  Values are in milliseconds.
#' The default is 250 (same as for a regular text input).
#' @param rmd Whether or not the app is an interactive R Mardown document.  Default
#' is \code{FALSE}.
#' @param html Whether or not this is a Shiny app in which the user interface is
#' built from a custom HTML file.  Default value is \code{FALSE}.
#'
#' @return a tag list
#' @export
useShinyCustom <- function(slider_policy = "debounce", slider_delay = "250",
                           numeric_policy = "debounce", numeric_delay = "250",
                           text_policy = "debounce", text_delay = "250",
                           rmd = FALSE, html = FALSE) {

  #Borrowing Dean Attali's ideas all the way through! https://github.com/daattali/shinyjs

  # Dean's comment:
  # `astext` is FALSE in normal shiny apps where the shinyjs content is returned
  # as a shiny tag that gets rendered by the Shiny UI, and TRUE in interactive
  # Rmarkdown documents or in Shiny apps where the user builds the entire UI
  # manually with HTML, because in those cases the content of shinyjs needs to
  # be returned as plain text that can be added to the HTML
  astext <- rmd || html

  # dean's comment:
  # inject is TRUE when the user builds the entire UI manually with HTML,
  # because in that case the shinyjs content needs to be injected into the page
  # using JavaScript
  inject <- html

  codeProperties <- makeScript(slider_policy, slider_delay, numeric_policy,
                     numeric_delay, text_policy, text_delay)
  shiny::addResourcePath("customjs", system.file("js", package = "shinyCustom"))
  jsFile <- file.path("customjs", "shinyCustom.js")

  # if rmd or html, inject inline; if regular shiny, place in head.
  # codeInject will be used only if html.
  if ( astext ) {
    shinyCustomContent <- shiny::tagList(shiny::tags$script(codeProperties),
                                         shiny::tags$script(src = jsFile))
  } else {
    shinyCustomContent <- shiny::tagList(shiny::tags$head(shiny::tags$script(codeProperties)),
                                         shiny::tags$head(shiny::tags$script(src = jsFile)))
  }


  # If html, inject using Javascript handler.
  # App author needs to put <script src="js/inject.js"></script>`
  # into the head element.
  # Results so far:  injection succeeeds, but binding does not take place.
  if (inject) {
    shinyCustomContent <- as.character(shinyCustomContent)
    session <- shiny::getDefaultReactiveDomain()
    session$sendCustomMessage('shinyCustom-inject', shinyCustomContent)
  } else {
    shinyCustomContent
  }

}


makeScript <- function(sp, sd, np, nd, tp, td) {
  text <- paste0("var customSliderPolicy = '", sp, "';\n",
                 "var customSliderDelay = ", sd, ";\n",
                 "var customNumericPolicy = '", np, "';\n",
                 "var customNumericDelay = ", nd, ";\n",
                 "var customTextPolicy = '", tp, "';\n",
                 "var customTextDelay = ", td, ";\n")
  text
}
