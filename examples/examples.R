
# Horizontal bar chart --------------------------------------------------------


robservable(
  "@d3/horizontal-bar-chart"
)

robservable(
  "@d3/horizontal-bar-chart",
  include = "chart"
)

df <- data.frame(table(mtcars$cyl))
names(df) <- c("name", "value")
robservable(
  "@d3/horizontal-bar-chart",
  include = "chart",
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
  include = "chart",
  input = list(
    data = df,
    color = "#567890",
    height = 800
  )
)



# Sankey diagram ----------------------------------------------------------


robservable(
  "@zacol/marvel-cinematic-universe-sankey-diagram",
  include = "chart"
)




# Eyes --------------------------------------------------------------------


robservable(
  "@mbostock/eyes"
)

robservable(
  "@mbostock/eyes",
  include = c("canvas", "mouse"),
  hide = "mouse"
)



# Web GL -------------------------------------------------------------------


robservable(
  "@rreusser/gpgpu-boids"
)

robservable(
  "@mbostock/liquidfun",
  include = "canvas"
)

robservable(
  "@mbostock/clifford-attractor-iii",
  include = c("viewof gl", "draw")
)

robservable(
  "@mbostock/clifford-attractor-iii",
  include = c("viewof gl", "draw"),
  hide = "draw"
)

robservable(
  "@mbostock/clifford-attractor-iii",
  include = c("viewof gl", "draw"),
  hide = c("draw"),
  input = list(settings = list(a = 1, b = 1, c = 3, d = 1))
)



# Multi line chart --------------------------------------------------------


robservable("@d3/multi-line-chart")

robservable(
  "@d3/multi-line-chart",
  include = "chart"
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
  include = "chart",
  input = list(data = df)
)



# Updatable charts --------------------------------------------------------

robservable(
  "@mkfreeman/d3-chart-updates-in-observable"
)

# Forked to add a name to redraw and style cells
robservable(
  "@juba/d3-chart-updates-in-observable",
  include = c("chart", "redraw", "style"),
  hide = c("redraw", "style"),
  input = list(state = "District of Columbia")
)

robservable(
  "@juba/updatable-bar-chart",
  include = c("chart", "draw"),
  hide = "draw",
  input = list(
    data = data.frame(
      name = LETTERS[1:10],
      value = round(runif(10)*100)
    )
  )
)















