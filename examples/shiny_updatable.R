## Sample robservable Shiny app with updatable chart with animated transitions

library(shiny)
library(robservable)

ui <- fluidPage(

    # Application title
    titlePanel("Test robservable"),

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

    data <- reactive({
        input$update
        data.frame(
            name = LETTERS[1:10],
            value = round(runif(10)*100)
        )
    })

    output$chart <- renderRobservable({

        robservable(
            "@juba/updatable-bar-chart",
            include = c("chart", "draw"),
            hide = "draw",
            input = list(
                data = data()
            )
        )
    })
}

shinyApp(ui = ui, server = server)
