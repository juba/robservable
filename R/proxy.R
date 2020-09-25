# this code is very strongly based off of RStudio's leaflet package
#   https://github.com/rstudio/leaflet/blob/master/R/utils.R in
#   an attempt to establish some consistency around the htmlwidget
#   proxy mechanism for use with Shiny

# Given a remote operation and a observable proxy, execute. If code was
# not provided for the appropriate mode, an error will be raised.
invokeRemote <- function(robs, method, args = list()) {
  if (!inherits(robs, "robservable_proxy"))
    stop("Invalid robs parameter; robservable proxy object was expected")

  msg <- list(
    id = robs$id,
    calls = list(
      list(
        dependencies = lapply(robs$dependencies, shiny::createWebDependency),
        method = method,
        args = args
      )
    )
  )

  sess <- robs$session
  if (robs$deferUntilFlush) {
    sess$onFlushed(function() {
      sess$sendCustomMessage("robservable-calls", msg)
    }, once = TRUE)
  } else {
    sess$sendCustomMessage("robservable-calls", msg)
  }
  robs
}




#' Send commands to a Proxy instance in a Shiny app
#'
#' Creates a robservable-like object that can be used to customize and control a robservable
#' that has already been rendered. For use in Shiny apps and Shiny docs only.
#'
#' Normally, you create a robservable instance using the \code{\link{robservable}} function.
#' This creates an in-memory representation of a robservable that you can customize,
#' print at the R console, include in an R Markdown document, or render as a Shiny output.
#'
#' In the case of Shiny, you may want to further customize a robservable, even after it
#' is rendered to an output. At this point, the in-memory representation of the
#' robservable is long gone, and the user's web browser has already realized the
#' robservable instance.
#'
#' This is where \code{robservableProxy} comes in. It returns an object that can
#' stand in for the usual robservable object. The usual robservable functions
#' can be called, and instead of customizing an in-memory representation,
#' these commands will execute on the already created robservable instance in
#' the browser.
#'
#' @param id single-element character vector indicating the output ID of the
#'   robservable to modify (if invoked from a Shiny module, the namespace will be added
#'   automatically)
#' @param session the Shiny session object to which the robservable belongs; usually the
#'   default value will suffice
#' @param deferUntilFlush indicates whether actions performed against this
#'   instance should be carried out right away, or whether they should be held
#'   until after the next time all of the outputs are updated; defaults to
#'   \code{TRUE}
#'
#' @return
#' A proxy object which allows to update an already created robservable instance.
#'
#' @export
robservableProxy <- function(id, session = shiny::getDefaultReactiveDomain(),
  deferUntilFlush = TRUE) {

  if (is.null(session)) {
    stop("robservableProxy must be called from the server function of a Shiny app")
  }

  # If this is a new enough version of Shiny that it supports modules, and
  # we're in a module (nzchar(session$ns(NULL))), and the id doesn't begin
  # with the current namespace, then add the namespace.
  #
  # We could also have unconditionally done `id <- session$ns(id)`, but
  # older versions of robservable would have broken unless the user did session$ns
  # themselves, and we hate to break their code unnecessarily.
  #
  # This won't be necessary in future versions of Shiny, as session$ns (and
  # other forms of ns()) will be smart enough to only namespace un-namespaced
  # IDs.
  if (
    !is.null(session$ns) &&
    nzchar(session$ns(NULL)) &&
    substring(id, 1, nchar(session$ns(""))) != session$ns("")
  ) {
    id <- session$ns(id)
  }

  structure(
    list(
      session = session,
      id = id,
      x = structure(
        list()
      ),
      deferUntilFlush = deferUntilFlush,
      dependencies = NULL
    ),
    class = "robservable_proxy"
  )
}
