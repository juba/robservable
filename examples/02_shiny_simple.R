## Simple robservable Shiny app

library(shiny)
library(robservable)

library(gapminder)
library(tidyverse)
data(gapminder)
dates <- sort(unique(gapminder$year))
dates <- to_js_date(as.Date(as.character(dates), format = "%Y"))

ui <- fluidPage(

    titlePanel("robservable simple Shiny app"),

    sidebarLayout(
        sidebarPanel(
            selectInput(
                "var",
                label = "Variable",
                choices = c("lifeExp", "pop", "gdpPercap")
            )
        ),

        mainPanel(
           robservableOutput("chart", width = 600)
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
            "@juba/multi-line-chart",
            include = "chart",
            input = list(
                data = df,
                margin = list(top = 20, right = 20, bottom = 30, left = 80)
            ),
            width = 600
        )
    })
}

shinyApp(ui = ui, server = server)
