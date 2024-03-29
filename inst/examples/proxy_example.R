if (interactive()) {
  # change color with update through proxy

  library(shiny)
  library(robservable)

  ui <- tagList(
    robservableOutput("bar")
  )

  server <- function(input, output, session) {
    robs <- robservable(
      "@juba/robservable-bar-chart",
      include = "chart",
      input = list(color = "red", height = 700)
    )
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
  }

  shinyApp(ui, server)


  # change data using update with proxy

  library(shiny)
  library(robservable)

  ui <- tagList(
    actionButton("btnChangeData", "Change Data"),
    robservableOutput("bar")
  )

  server <- function(input, output, session) {
    robs <- robservable(
      "@juba/robservable-bar-chart",
      include = "chart",
      input = list(color = "red", height = 700)
    )

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


  # add an observer through proxy

  library(shiny)
  library(robservable)

  ui <- tagList(
    robservableOutput("bar")
  )

  server <- function(input, output, session) {
    robs <- robservable(
      "@juba/robservable-bar-chart",
      include = "chart",
      input = list(color = "red", height = 700)
    )

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
}

