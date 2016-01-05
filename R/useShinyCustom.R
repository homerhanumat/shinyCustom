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
#'
#' @return a tag list
#' @export
useShinyCustom <- function(slider_policy = "debounce", slider_delay = "250",
                           numeric_policy = "debounce", numeric_delay = "250",
                           text_policy = "debounce", text_delay = "250") {
  code <- makeScript(slider_policy, slider_delay, numeric_policy,
                     numeric_delay, text_policy, text_delay)
  shiny::addResourcePath("customjs", system.file("js", package = "shinyCustom"))
  jsFile <- file.path("customjs", "shinyCustom.js")
  shiny::tagList(shiny::tags$head(shiny::tags$script(code)),
                 shiny::tags$head(shiny::tags$script(
                   src = jsFile))
                 )
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
