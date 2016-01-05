#' Use the shinyCustom Package
#'
#' @param slider_policy policy for custom slider
#' @param slider_delay delay for cusotm slider
#' @param numeric_policy
#' @param numeric_delay
#' @param text_policy
#' @param text_delay
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
