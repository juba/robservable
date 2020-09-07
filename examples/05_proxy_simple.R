library(shiny)
library(robservable)

robs <- robservable(
  "@d3/bar-chart",
  include = "chart",
  input = list(color = "red", height = 700)
)

ui <- tagList(
  actionButton("btnChangeHeight", "Change Height"),
  actionButton("btnChangeWidth", "Change Width"),
  robservableOutput("bar")
)
server <- function(input, output, session) {
  output$bar <- renderRobservable({
    robs
  })

  # set up a proxy to our bar robservable instance
  #   for later manipulation
  robs_proxy <- robservableProxy("bar")

  observe({
    invalidateLater(2000, session)

    # update with random color
    robs_update(
      robs_proxy,
      color = paste0(
        "rgb(",
        paste0(col2rgb(colors()[floor(runif(1,1,length(colors())))]),collapse=","),
        ")"
      )
    )
  })

  observeEvent(input$btnChangeHeight, {
    robs_update(
      robs_proxy,
      height = floor(runif(1,200,600))
    )
  })

  observeEvent(input$btnChangeWidth, {
    robs_update(
      robs_proxy,
      width = floor(runif(1,200,600))
    )
  })
}

shinyApp(ui, server)
