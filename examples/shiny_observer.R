## Sample robservable Shiny app with observers

library(shiny)
library(robservable)
library(leaflet)

ui <- fluidPage(

    # Application title
    titlePanel("Test robservable"),

    sidebarLayout(
        sidebarPanel(
            robservableOutput("map_input")
        ),

        mainPanel(
            leafletOutput("map", width = 600, height = 600)
        )
    )
)


server <- function(input, output) {

    output$map_input <- renderRobservable({

        robservable(
            "@jashkenas/inputs",
            cell = c("worldMapCoordinates", "viewof worldMap1"),
            hide = "worldMapCoordinates",
            observers = "worldMap1"
        )

    })

    point <- reactive({
        cbind(
            input$map_input_observer_worldMap1[1],
            input$map_input_observer_worldMap1[2]
        )
    })

    output$map <- renderLeaflet({
        leaflet(options = leafletOptions(minZoom = 10, maxZoom = 10)) %>%
            addTiles() %>%
            addMarkers(data = point())
    })



}

shinyApp(ui = ui, server = server)
