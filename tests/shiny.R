library(shiny)

library(gapminder)
library(tidyverse)
data(gapminder)
dates <- sort(unique(gapminder$year))
dates <- to_js_date(as.Date(as.character(dates), format = "%Y"))

ui <- fluidPage(

    # Application title
    titlePanel("Test robservable"),

    sidebarLayout(
        sidebarPanel(
            selectInput(
                "var",
                label = "Variable",
                choices = c("lifeExp", "pop", "gdpPercap")
            )
        ),

        mainPanel(
           robservableOutput("chart", width = 800)
        )
    )
)


server <- function(input, output) {

    series <- reactive({
        purrr::map(unique(gapminder$country), ~{
            name <- .x
            var <- sym(input$var)
            values <- gapminder %>% filter(country == .x) %>% pull(!!var)
            list(name = name, values = values)
        })
    })


    output$chart <- renderRobservable({
        df <- list(
            y = input$var,
            series = series(),
            dates = dates
        )

        robservable(
            "@d3/multi-line-chart",
            cell = "chart",
            input = list(data = df),
            width = 800
        )
    })
}

shinyApp(ui = ui, server = server)
