#' Display an Observable notebook as HTML widget
#'
#'
#' @param notebook The notebook id, such as "@d3/bar-chart", or the full notebook URL.
#' @param include character vector of cell names to be rendered. If NULL,  the whole notebook is rendered.
#' @param hide character vector of cell names in `include` to be hidden in the output.
#' @param input A named list of cells to be updated with a fixed value.
#' @param input_js A named list of cells to be updated with JavaScript code. Each list element is itself a list
#'   with a vector of argument names as `inputs` entry,  and a character string of JavaScript code 
#'   as `definition` entry, as expected by Observable runtime variable.define function.
#' @param observers A vector of character strings representing variables in observable that
#'   you would like to set as input values in Shiny.
#' @param update_height if TRUE (default) and input$height is not defined, replace its value with the height of the widget root HTML element. Note there will not always be such a cell in every notebook. Set it to FALSE to always keep the notebook value.
#' @param update_width if TRUE (default) and input$width is not defined, replace its value with the width of the widget root HTML element. Set it to FALSE to always keep the notebook or the Observable stdlib value.
#' @param width htmlwidget width.
#' @param height htmlwidget height.
#' @param elementId optional manual widget HTML id.
#' @param json_args custom arguments passed to JSON serializer.
#' @param json_func optional custom JSON serializer R function.
#'
#' @details
#' If a data.frame is passed as a cell value in `input`, it will be converted into the format
#' expected by `d3` (ie, converted by rows).
#' 
#' For more details on the use of `input_js` to update cells with JavaScript code, see the
#' introduction vignette and https://github.com/observablehq/runtime#variable_define.
#'
#' @return
#' An object of class `htmlwidget`.
#'
#' @import htmlwidgets
#'
#' @examples
#' ## Display a notebook cell
#' robservable(
#'   "@d3/bar-chart",
#'   include = "chart"
#' )
#'
#' ## Change cells data with input
#' robservable(
#'   "@d3/bar-chart",
#'   include = "chart",
#'   input = list(color = "red", height = 700)
#' )
#'
#' ## Change data frame cells data
#' df <- data.frame(table(mtcars$cyl))
#' names(df) <- c("name", "value")
#' robservable(
#'   "@d3/horizontal-bar-chart",
#'   include = "chart",
#'   input = list(data = df)
#' )
#'
#' @export
#'
robservable <- function(
                        notebook, include = NULL, hide = NULL,
                        input = NULL, input_js = NULL, observers = NULL,
                        update_height = TRUE,
                        update_width = TRUE,
                        width = NULL, height = NULL,
                        elementId = NULL,
                        json_args = list(dataframe = "rows"),
                        json_func = NULL
                      ) {

  input_js = lapply(input_js, function(entry) {
    list(inputs = entry$inputs, definition = htmlwidgets::JS(entry$definition))
  })

  x <- list(
    notebook = notebook,
    include = include,
    hide = hide,
    input = input,
    input_js = input_js,
    observers = observers,
    update_height = update_height,
    update_width = update_width
  )

  # Custom JSON serialization
  attr(x, "TOJSON_ARGS") <- json_args
  if (!is.null(json_func)) {
    attr(x, "TOJSON_FUNC") <- json_func
  }

  htmlwidgets::createWidget(
    x,
    name = "robservable",
    width = width,
    height = height,
    package = "robservable",
    elementId = elementId
  )
}

#' Convert a Date or POSIXt object to a JS Date format
#'
#' @param date object to be converted
#'
#' @return
#' Numeric value representing the number of milliseconds between Unix Epoch
#' (1 January 1970 UTC) and `date`.
#'
#' @export
#'
to_js_date <- function(date) {
  ## Code taken from lubridate::origin
  diff <- as.POSIXct(date) - structure(0, class = c("POSIXct", "POSIXt"), tzone = "UTC")
  as.numeric(diff, unit = "secs") * 1000
}


#' Shiny bindings for robservable
#'
#' Output and render functions for using robservable within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a robservable
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name robservable-shiny
#'
#' @export
robservableOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "robservable", width, height, package = "robservable")
}

#' @rdname robservable-shiny
#' @export
renderRobservable <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, robservableOutput, env, quoted = TRUE)
}
