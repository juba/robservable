library(shiny)
library(robservable)

robs <- robservable(
  "@juba/robservable-bar-chart",
  include = "chart",
  input = list(color = "red", height = 700)
)

ui <- tagList(
  robservableOutput("bar")
)
server <- function(input, output, session) {
  output$bar <- renderRobservable({
    robs
  })

  # set up a proxy to our bar robservable instance
  #   for later manipulation
  robs_proxy <- robservableProxy("bar")

  robs_observe(robs_proxy, "color")

  observeEvent(input$bar_color, {
    print(input$bar_color)
  })

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
}

shinyApp(ui, server)
