# custom slider ---------
customSliderInput <- function(inputId, label, min, max, value, step = NULL,
                            round = FALSE,
                            ticks = TRUE, animate = FALSE, width = NULL, sep = ",",
                            pre = NULL, post = NULL, timeFormat = NULL,
                            timezone = NULL, dragRange = TRUE)
{

  # If step is NULL, use heuristic to set the step size.
  findStepSize <- function(min, max, step) {
    if (!is.null(step)) return(step)

    range <- max - min
    # If short range or decimals, use continuous decimal with ~100 points
    if (range < 2 || hasDecimals(min) || hasDecimals(max)) {
      step <- pretty(c(min, max), n = 100)
      step[2] - step[1]
    } else {
      1
    }
  }

  if (inherits(min, "Date")) {
    if (!inherits(max, "Date") || !inherits(value, "Date"))
      stop("`min`, `max`, and `value must all be Date or non-Date objects")
    dataType <- "date"

    if (is.null(timeFormat))
      timeFormat <- "%F"

  } else if (inherits(min, "POSIXt")) {
    if (!inherits(max, "POSIXt") || !inherits(value, "POSIXt"))
      stop("`min`, `max`, and `value must all be POSIXt or non-POSIXt objects")
    dataType <- "datetime"

    if (is.null(timeFormat))
      timeFormat <- "%F %T"

  } else {
    dataType <- "number"
  }

  step <- findStepSize(min, max, step)

  if (dataType %in% c("date", "datetime")) {
    # For Dates, this conversion uses midnight on that date in UTC
    to_ms <- function(x) 1000 * as.numeric(as.POSIXct(x))

    # Convert values to milliseconds since epoch (this is the value JS uses)
    # Find step size in ms
    step  <- to_ms(max) - to_ms(max - step)
    min   <- to_ms(min)
    max   <- to_ms(max)
    value <- to_ms(value)
  }

  range <- max - min

  # Try to get a sane number of tick marks
  if (ticks) {
    n_steps <- range / step

    # Make sure there are <= 10 steps.
    # n_ticks can be a noninteger, which is good when the range is not an
    # integer multiple of the step size, e.g., min=1, max=10, step=4
    scale_factor <- ceiling(n_steps / 10)
    n_ticks <- n_steps / scale_factor

  } else {
    n_ticks <- NULL
  }

  sliderProps <- dropNulls(list(
    class = "customSliderInput js-range-slider",
    id = inputId,
    `data-type` = if (length(value) > 1) "double",
    `data-min` = formatNoSci(min),
    `data-max` = formatNoSci(max),
    `data-from` = formatNoSci(value[1]),
    `data-to` = if (length(value) > 1) formatNoSci(value[2]),
    `data-step` = formatNoSci(step),
    `data-grid` = ticks,
    `data-grid-num` = n_ticks,
    `data-grid-snap` = FALSE,
    `data-prettify-separator` = sep,
    `data-prefix` = pre,
    `data-postfix` = post,
    `data-keyboard` = TRUE,
    `data-keyboard-step` = step / (max - min) * 100,
    `data-drag-interval` = dragRange,
    # The following are ignored by the ion.rangeSlider, but are used by Shiny.
    `data-data-type` = dataType,
    `data-time-format` = timeFormat,
    `data-timezone` = timezone
  ))

  # Replace any TRUE and FALSE with "true" and "false"
  sliderProps <- lapply(sliderProps, function(x) {
    if (identical(x, TRUE)) "true"
    else if (identical(x, FALSE)) "false"
    else x
  })

  sliderTag <- div(class = "form-group shiny-input-container",
                   style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
                   if (!is.null(label)) controlLabel(inputId, label),
                   do.call(tags$input, sliderProps)
  )

  # Add animation buttons
  if (identical(animate, TRUE))
    animate <- animationOptions()

  if (!is.null(animate) && !identical(animate, FALSE)) {
    if (is.null(animate$playButton))
      animate$playButton <- icon('play', lib = 'glyphicon')
    if (is.null(animate$pauseButton))
      animate$pauseButton <- icon('pause', lib = 'glyphicon')

    sliderTag <- tagAppendChild(
      sliderTag,
      tags$div(class='slider-animate-container',
               tags$a(href='#',
                      class='slider-animate-button',
                      'data-target-id'=inputId,
                      'data-interval'=animate$interval,
                      'data-loop'=animate$loop,
                      span(class = 'play', animate$playButton),
                      span(class = 'pause', animate$pauseButton)
               )
      )
    )
  }

  dep <- list(
    htmltools::htmlDependency("ionrangeslider", "2.0.12", c(href="shared/ionrangeslider"),
                   script = "js/ion.rangeSlider.min.js",
                   # ion.rangeSlider also needs normalize.css, which is already included in
                   # Bootstrap.
                   stylesheet = c("css/ion.rangeSlider.css",
                                  "css/ion.rangeSlider.skinShiny.css")
    ),
    htmltools::htmlDependency("strftime", "0.9.2", c(href="shared/strftime"),
                   script = "strftime-min.js"
    )
  )

  htmltools::attachDependencies(sliderTag, dep)
}


# custom numeric input -----------

customNumericInput <- function(inputId, label, value, min = NA, max = NA, step = NA,
                             width = NULL) {

  # build input tag
  inputTag <- tags$input(id = inputId, type = "customnumber", class="form-control",
                         value = formatNoSci(value))
  if (!is.na(min))
    inputTag$attribs$min = min
  if (!is.na(max))
    inputTag$attribs$max = max
  if (!is.na(step))
    inputTag$attribs$step = step

  div(class = "form-group shiny-input-container",
      style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
      label %AND% tags$label(label, `for` = inputId),
      inputTag
  )
}

#' Custom Text Input
#'
#' @param inputId
#' @param label
#' @param value
#'
#' @return
#' @export
#'
#' @examples
customTextInput <- function(inputId, label, value = "") {
  tagList(tags$label(label, `for` = inputId),
          tags$input(id = inputId,
                     type = "text", value = value,
                     class="customTextInput form-control shiny-bound-input"))
}

