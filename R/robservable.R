#' Display an Observable notebook as HTML widget
#'
#'
#' @param notebook The notebook id, such as "@d3/bar-chart"
#' @param output_cell The name of the cell to be rendered. If NULL,  the whole notebook is rendered
#' @param input A named list of cells to be updated.
#' @param input_df A named list of d3-array cells to be updated
#' @param width htmlwidget width
#' @param height htmlwidget height
#' @param elementId optional manual widget HTML id
#'
#' @details
#' Values passed in `input_df` are converted using the JavaScript function `HTMLWidgets.dataframeToD3`.
#'
#' @import htmlwidgets
#'
#' @example
#' \donttest{
#' ## Display a notebook cell
#' robservable(
#'   "@d3/bar-chart",
#'   output_cell= "chart"
#' )
#'
#' ## Change cells data with input
#' robservable(
#'   "@d3/bar-chart",
#'   output_cell= "chart",
#'   input = list(color = "red", height = 700)
#' )
#'
#' ## Change data frame cells data with input_df
#' df <- data.frame(table(mtcars$cyl))
#' names(df) <- c("name", "value")
#' robservable(
#'   "@d3/horizontal-bar-chart",
#'   output_cell= "chart",
#'   input_df = list(data = df)
#' )
#' }
#' @export
#'
robservable <- function(notebook, output_cell = NULL, input = NULL, input_df = NULL, width = NULL, height = NULL, elementId = NULL) {

  x = list(
    notebook = notebook,
    output_cell = output_cell,
    input = input,
    input_df = input_df
  )

  htmlwidgets::createWidget(
    x,
    name = 'robservable',
    width = width,
    height = height,
    package = 'robservable',
    elementId = elementId
  )
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
