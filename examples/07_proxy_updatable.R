## Sample robservable Shiny app with updatable chart with animated transitions

library(shiny)
library(robservable)

robs <- robservable(
    "@juba/updatable-bar-chart",
    include = c("chart", "draw"),
    hide = "draw"
)

ui <- fluidPage(

    # Application title
    titlePanel("robservable updatable app"),

    sidebarLayout(
        sidebarPanel(
            shiny::actionButton("update", "Update")
        ),

        mainPanel(
           robservableOutput("chart")
        )
    )
)


server <- function(input, output) {

    output$chart <- renderRobservable({
        robs
    })

    # set up a proxy to our bar robservable instance
    #   for later manipulation
    robs_proxy <- robservableProxy("chart")

    observeEvent(input$update, {
        df <- data.frame(
            name = LETTERS[1:10],
            value = round(runif(10)*100)
        )
        robs_update(
            robs_proxy,
            data = df
        )
    })

}

shinyApp(ui = ui, server = server)
