#' Display an Observable notebook as HTML widget
#'
#'
#' @param notebook The notebook id, such as "@d3/bar-chart".
#' @param cell character vector of cell names to be rendered. If NULL,  the whole notebook is rendered.
#' @param hide character vector of cell names in `cell` to be hidden in the output.
#' @param input A named list of cells to be updated.
#' @param observers A vector of character strings representing variables in observable that
#'   you would like to set as input values in Shiny.
#' @param width htmlwidget width.
#' @param height htmlwidget height.
#' @param elementId optional manual widget HTML id.
#'
#' @details
#' If a data.frame is passed as a cell value in `input`, it will be converted into the format
#' expected by `d3` (ie, converted by rows)..
#'
#' @import htmlwidgets
#'
#' @examples
#' \donttest{
#' ## Display a notebook cell
#' robservable(
#'   "@d3/bar-chart",
#'   cell= "chart"
#' )
#'
#' ## Change cells data with input
#' robservable(
#'   "@d3/bar-chart",
#'   cell= "chart",
#'   input = list(color = "red", height = 700)
#' )
#'
#' ## Change data frame cells data
#' df <- data.frame(table(mtcars$cyl))
#' names(df) <- c("name", "value")
#' robservable(
#'   "@d3/horizontal-bar-chart",
#'   cell= "chart",
#'   input = list(data = df)
#' )
#' }
#' @export
#'
robservable <- function(
  notebook, cell = NULL, hide = NULL,
  input = NULL, observers = NULL,
  width = NULL, height = NULL, elementId = NULL
) {

  x <- list(
    notebook = notebook,
    cell = cell,
    hide = hide,
    input = input,
    observers = observers
  )
  attr(x, 'TOJSON_ARGS') <- list(dataframe = "rows")

  if (!is.null(width)) {
    x$robservable_width <- width
  }


  htmlwidgets::createWidget(
    x,
    name = 'robservable',
    width = width,
    height = height,
    package = 'robservable',
    elementId = elementId
  )
}

#' Convert a Date or POSIXt object to a JS Date format
#'
#' @param date object to be converted
#'
#' @details
#' The object is converted to the number of milliseconds since 1 January 1970 UTC.
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
robservableOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'robservable', width, height, package = 'robservable')
}

#' @rdname robservable-shiny
#' @export
renderRobservable <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, robservableOutput, env, quoted = TRUE)
}
