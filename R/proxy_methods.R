#' Update \code{robservable} through \code{robservableProxy}
#'
#' @param robs \code{robservableProxy} that you would like to update
#' @param ... named arguments to represent variables or inputs to update
#'
#' @return \code{robservable_proxy}
#'
#' @example inst/examples/proxy_example.R
#' @export
#' @importFrom jsonlite toJSON
#'
robs_update <- function(robs=NULL, ...) {
  if(!inherits(robs, "robservable_proxy")) {
    stop(
      paste0("expecting robs argument to be robservableProxy but got ", class(robs)),
      call. = FALSE
    )
  }

  invokeRemote(robs, "update", jsonlite::toJSON(list(...), data.frame="rows", auto_unbox = TRUE))

  # return proxy for piping
  robs
}

#' Add an observer to a \code{robservable} notebook input through \code{robservableProxy}
#'
#' @param robs \code{robservableProxy} that you would like to update
#' @param observer \code{character} name(s) of inputs to observe
#'
#' @return \code{robservable_proxy}
#'
#' @example inst/examples/proxy_example.R
#' @export
#'
robs_observe <- function(robs=NULL, observer=NULL) {
  if(!inherits(robs, "robservable_proxy")) {
    stop(
      paste0("expecting robs argument to be robservableProxy but got ", class(robs)),
      call. = FALSE
    )
  }

  invokeRemote(robs, "observe", observer)

  # return proxy for piping
  robs
}
