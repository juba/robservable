library(questionr)
data(hdv2003)
df <- as.data.frame(table(hdv2003$qualif))
names(df) <- c("name", "value")

robservable(
  "@d3/horizontal-bar-chart",
  cell= "chart",
  input = list(
    data = df,
    #color = "#567890",
    margin = list(top = 20, right = 0, left = 150, bottom = 0)
  ),
  width = 400
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


robservable(
  "@zacol/marvel-cinematic-universe-sankey-diagram",
  cell = "chart"
)

robservable(
  "@mbostock/eyes"
)

# Doesn't work in pure JS either
robservable(
  "@mbostock/eyes",
  cell = "canvas"
)


robservable(
  "@rreusser/gpgpu-boids"
)

df <- data.frame(table(mtcars$cyl))
names(df) <- c("name", "value")
robservable(
  "@d3/horizontal-bar-chart",
  cell= "chart",
  input = list(data = df)
)

robservable("@mbostock/liquidfun", cell = "canvas")


robservable("@mbostock/clifford-attractor-iii")

## MULTI LINE CHART ---------

robservable("@d3/multi-line-chart", cell = "chart")

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
#dates <- (dates - 1970) * 365 * 24 * 3600 * 1000

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


