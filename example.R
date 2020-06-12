
# Horizontal bar chart --------------------------------------------------------


robservable(
  "@d3/horizontal-bar-chart"
)

robservable(
  "@d3/horizontal-bar-chart",
  cell = "chart"
)

df <- data.frame(table(mtcars$cyl))
names(df) <- c("name", "value")
robservable(
  "@d3/horizontal-bar-chart",
  cell= "chart",
  input = list(data = df,
    margin = list(top = 20, right = 0, left = 150, bottom = 0)
  ),
  width = 600
)



# Bar chart ---------------------------------------------------------------


robservable(
  "@d3/bar-chart"
)

robservable(
  "@d3/bar-chart",
  cell= "chart",
  input = list(
    data = df,
    color = "#567890",
    height = 800
  )
)



# Sankey diagram ----------------------------------------------------------


robservable(
  "@zacol/marvel-cinematic-universe-sankey-diagram",
  cell = "chart"
)




# Eyes --------------------------------------------------------------------


# Full notebook : ok
robservable(
  "@mbostock/eyes"
)

robservable(
  "@mbostock/eyes",
  cell = c("canvas", "mouse"),
  hide = "mouse"
)



# Web GL -------------------------------------------------------------------


robservable(
  "@rreusser/gpgpu-boids"
)

robservable(
  "@mbostock/liquidfun",
  cell = "canvas"
)

robservable(
  "@mbostock/clifford-attractor-iii",
  cell = c("viewof gl", "draw")
)

robservable(
  "@mbostock/clifford-attractor-iii",
  cell = c("viewof gl", "draw"),
  hide = "draw"
)


# Multi line chart --------------------------------------------------------


robservable("@d3/multi-line-chart")

robservable(
  "@d3/multi-line-chart",
  cell = "chart"
)

library(gapminder)
library(tidyverse)
data(gapminder)
series <- purrr::map(unique(gapminder$country), ~{
  name <- .x
  values <- gapminder %>% filter(country == .x) %>% pull(lifeExp)
  list(name = name, values = values)
})
dates <- sort(unique(gapminder$year))
dates <- as.Date(as.character(dates), format = "%Y")

df <- list(
  y = "Life expectancy",
  series = series,
  dates = to_js_date(dates)
)

robservable(
  "@d3/multi-line-chart",
  cell = "chart",
  input = list(data = df)
)



# Updatable charts --------------------------------------------------------

robservable(
  "@mkfreeman/d3-chart-updates-in-observable"
)



















