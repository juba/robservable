library(shiny)
library(robservable)

robs <- robservable(
  "@d3/bar-chart",
  include = "chart",
  input = list(color = "red", height = 700)
)

ui <- tagList(
  actionButton("btnChangeData", "Change Data"),
  robservableOutput("bar")
)
server <- function(input, output, session) {
  output$bar <- renderRobservable({
    robs
  })

  # set up a proxy to our bar robservable instance
  #   for later manipulation
  robs_proxy <- robservableProxy("bar")

  observeEvent(input$btnChangeData, {
    robs_update(
      robs_proxy,
      data = data.frame(
        name = LETTERS[1:10],
        value = round(runif(10)*100)
      )
    )
  })


}

shinyApp(ui, server)
