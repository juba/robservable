#' Update \code{robservable} through \code{robservableProxy}
#'
#' @param robs \code{robservableProxy} that you would like to update
#'
#' @return \code{robservable_proxy}
#' @export
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
