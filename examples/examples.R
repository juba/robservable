# Horizontal bar chart --------------------------------------------------------


robservable(
  "@juba/robservable-bar-chart"
)

robservable(
  "@juba/robservable-bar-chart",
  include = "chart"
)

df <- data.frame(table(mtcars$cyl))
names(df) <- c("name", "value")
df$name <- paste0("cyl", df$name)
robservable(
  "@juba/robservable-bar-chart",
  include = "chart",
  input = list(
    data = df,
    x = "value",
    y = "name",
    margin = list(top = 20, right = 0, left = 15, bottom = 30)
  ),
  width = 800
)



# Bar chart ---------------------------------------------------------------


robservable(
  "@juba/updatable-bar-chart",
  include = c("chart", "draw"),
  input = list(
    data = df
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


robservable("@juba/multi-line-chart")

robservable(
  "@juba/multi-line-chart",
  include = "chart"
)

library(gapminder)
library(tidyverse)
data(gapminder)
series <- purrr::map(unique(gapminder$country), ~ {
  name <- .x
  values <- gapminder %>%
    filter(country == .x) %>%
    pull(lifeExp)
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
  "@juba/multi-line-chart",
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
      value = round(runif(10) * 100)
    )
  )
)



# input_js examples ---------------------------------------------------------

robservable(
  "https://observablehq.com/d/e1db8b0bd1c06ad2",
  input_js = list(format = list(inputs = "x", definition = "(x) => ((y) => (x * y))"))
)

robservable(
  "https://observablehq.com/d/e1db8b0bd1c06ad2",
  input_js = list(format = list(inputs = NULL, definition = "() => ((x) => (x + 200))"))
)


robservable(
  "https://observablehq.com/d/e1db8b0bd1c06ad2",
  input_js = list(
    func = list(inputs = "param", definition = "(param) => (x) => (x - param)")
  )
)