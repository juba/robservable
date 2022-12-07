## Basic robservable Shiny app

library(shiny)
library(robservable)

data("USPersonalExpenditure")

ui <- fluidPage(
    titlePanel("robservable basic Shiny app"),
    sidebarLayout(
        sidebarPanel(
            selectInput(
                "year",
                label = "Year",
                choices = colnames(USPersonalExpenditure)
            )
        ),
        mainPanel(
           robservableOutput("chart", width = 600)
        )
    )
)


server <- function(input, output) {

    df <- reactive({
        data.frame(
            name = rownames(USPersonalExpenditure),
            value = USPersonalExpenditure[, input$year]
        )
    })

    output$chart <- renderRobservable({
        robservable(
            "@juba/robservable-bar-chart",
            include = "chart",
            input = list(
                data = df(),
                x = "value",
                y = "name",
                margin = list(top = 20, right = 20, bottom = 30, left = 130)
            ),
            width = 600
        )
    })
}

shinyApp(ui = ui, server = server)
