
#' Custom Slider Input
#'
#' Constructs a custom slider widget to select a numeric value
#' from a range.  Primarily used to customize the rate policy.
#'
#' @rdname customSliderInput
#' @param inputId The input slot that will be used to access the value.
#' @param label Display label for the control, or NULL for no label.
#' @param min The minimum value (inclusive) that can be selected.
#' @param max The maximum value (inclusive) that can be selected.
#' @param value The initial value of the slider. A numeric vector of length
#'   one will create a regular slider; a numeric vector of length two will
#'   create a double-ended range slider. A warning will be issued if the value
#'   doesn't fit between min and max.
#' @param step Specifies the interval between each selectable value on the
#'   slider (if NULL, a heuristic is used to determine the step size). If the
#'   values are dates, step is in days; if the values are times (POSIXt), step
#'   is in seconds.
#' @param round TRUE to round all values to the nearest integer; FALSE if no
#'   rounding is desired; or an integer to round to that number of digits
#'   (for example, 1 will round to the nearest 10, and -2 will round to the
#'   nearest .01). Any rounding will be applied after snapping to the nearest step.
#' @param ticks \code{FALSE} to hide tick marks, \code{TRUE} to show them
#'   according to some simple heuristics.
#' @param animate \code{TRUE} to show simple animation controls with default
#'   settings; \code{FALSE} not to; or a custom settings list, such as those
#'   created using \code{\link{animationOptions}}.
#' @param width The width of the input, e.g., '200px' or '50\%'.
#' @param sep Separator between thousands places in numbers.
#' @param pre A prefix string to put in front of the value.
#' @param post A suffix string to put after the value.
#' @param timeFormat Only used if the values are Date or POSIXt objects. A time
#'   format string, to be passed to the Javascript strftime library. See
#'   \url{https://github.com/samsonjs/strftime} for more details. The allowed
#'   format specifications are very similar, but not identical, to those for R's
#'   \code{\link{strftime}} function. For Dates, the default is \code{"\%F"}
#'   (like \code{"2015-07-01"}), and for POSIXt, the default is \code{"\%F \%T"}
#'   (like \code{"2015-07-01 15:32:10"}).
#' @param timezone Only used if the values are POSIXt objects. A string
#'   specifying the time zone offset for the displayed times, in the format
#'   \code{"+HHMM"} or \code{"-HHMM"}. If \code{NULL} (the default), times will
#'   be displayed in the browser's time zone. The value \code{"+0000"} will
#'   result in UTC time.
#' @param dragRange This option is used only if it is a range slider (with two
#'   values). If \code{TRUE} (the default), the range can be dragged. In other
#'   words, the min and max can be dragged together. If \code{FALSE}, the range
#'   cannot be dragged.
#' @export
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


#' Custom Numeric Input
#'
#' Create a custom input control for entry of numeric values.
#' The control updates if and only if the user presses Enter or shifts
#' focus away from the control.
#'
#' @rdname customNumericInput
#' @param inputId The \code{input} slot that will be used to access the value.
#' @param label Display label for the control, or NULL for no label.
#' @param value Initial value.
#' @param min Minimim allowed value.
#' @param max Maximum allowed value.
#' @param step Interval to use when stepping between min and max.
#' @param width The width of the input, e.g., "200px" or "50\%".
#' @export
customNumericInput <- function(inputId, label, value, min = NA, max = NA, step = NA,
                             width = NULL) {

  # build input tag
  inputTag <- tags$input(id = inputId, type = "number",
                         class=" customNumericInput form-control",
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
#' Create a custom input control for entry of unstructured
#' text values.  The control updates if and only if the user presses Enter
#' or shifts focus away from the control.
#'
#' @rdname customTextInput
#' @param inputId The input slot that will be used to access the value.
#' @param label Display label for the control, or NULL for no label.
#' @param value Initial value.
#' @param width The width of the input, e.g. '400px', or '100\%'.
#' @param placeholder A character string giving the user a hint as to what
#'   can be entered into the control. Internet Explorer 8 and 9 do not support
#'   this option.
#' @export
customTextInput <- function(inputId, label, value = "", width = NULL,
                      placeholder = NULL) {

  div(class = "form-group shiny-input-container",
      style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"),
      label %AND% tags$label(label, `for` = inputId),
      tags$input(id = inputId, type="text", class="customTextInput form-control",
                 value=value,
                 placeholder = placeholder)
  )
}

