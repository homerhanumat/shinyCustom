#' Use the shinyCustom Package
#'
#' @param slider_policy
#' @param slider_delay
#' @param numeric_policy
#' @param numeric_delay
#' @param text_policy
#' @param text_delay
#'
#' @return
#' @export
#'
#' @examples
useShinyCustom <- function(slider_policy = "debounce", slider_delay = "250",
                           numeric_policy = "debounce", numeric_delay = "250",
                           text_policy = "debounce", text_delay = "250") {
  #code <- paste0('<div')
  shiny::tags$body(shiny::div(id = "shinyCustomDiv",
                data-slider-policy = slider_policy, data-slider-delay = slider_delay,
                data-numeric-policy = numeric_policy, data-numeric-delay = numeric_delay,
                data-text-policy = text_policy, data-text-delay = text_delay))
  shiny::includeScript(system.file("shinyCustom.js", package = "shinyCustom"))
}
