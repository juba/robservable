 <!-- badges: start -->
 [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
  [![R build status](https://github.com/juba/robservable/workflows/R-CMD-check/badge.svg)](https://github.com/juba/robservable/actions)
  <!-- badges: end -->

# robservable

The goal of this package is to allow the use of [Observable](https://observablehq.com/) notebooks (or part of them) as htmlwidgets in R.

Note that this is a toy package in very early stage of development.

## Features

- Display an entire published notebook as an htmlwidget
- Display specified named cells of a published notebook as an htmlwidget
- Use R data to update cell values before displaying the notebook
- Add observers on cells values to get them back inside a Shiny app
- Use inside Shiny app or Rmarkdown document (as any htmlwidget)

## Limitations

- Only published notebooks can be used (but you may fork and publish any notebook in Observable)
- Only named cells can be displayed alone (but you can fork the notebook and name the cell in Observable)
- Font size and display problems when a fixed width is not specified



## Installation

```r
remotes::install_github("juba/robservable")
```

## Usage

First think to do is to identify the notebook you want to use. The notebook has to be published, and its id is the same as the one used to `import` it in Observable. For example, the id of [this notebook](https://observablehq.com/@d3/horizontal-bar-chart) is `@d3/horizontal-bar-chart`.

### Render an entire notebook

The simplest thing is to display an entire notebook from R. You can do this by calling a notebook with the function `robservable` :

```r
robservable("@mbostock/clifford-attractor-iii")
```

### Render only some cells

Instead of displaying an entire notebook, it may be better to display only one of its cell. To do this, the cell in the notebook must have a name (*ie* it must be of the form `foo = ...`). For example, if you want to display only the `chart` cell of the [horizontal bar chart notebook](https://observablehq.com/@d3/horizontal-bar-chart), you can do :

```r
robservable(
  "@d3/horizontal-bar-chart", 
  cell = "chart"
)
```

For some notebooks you'll have to render several cells to get the desired result. For example, in the [Clifford Attractor III notebook](https://observablehq.com/@mbostock/clifford-attractor-iii?collection=@observablehq/webgl), the main chart is in a cell named `viewof gl`, but it only generates an empty `<canvas>` element. For the chart to be created, you also have to render the `draw` cell :

```r
robservable(
  "@mbostock/clifford-attractor-iii",
  cell = c("viewof gl", "draw")
)
```

If we want to render `draw` without displaying it, we can add its name to the `hide` argument :

```r
robservable(
  "@mbostock/clifford-attractor-iii",
  cell = c("viewof gl", "draw"),
  hide = "draw"
)
```


### Update cell values 

Another feature is the ability to update one of the notebook cell values from R before displaying it. To do this, you can provide a named list as `input` argument. In the previous example, we could change the `barHeight` cell value with :

```r
robservable(
  "@d3/horizontal-bar-chart", 
  cell = "chart",
  input = list(barHeight = 15)
)
```

More interesting, we can update the `data` cell value to generate the bar chart based on our own data. We just have to be sure that it is in the same format as the notebook data. For example :

```r
df <- data.frame(table(mtcars$cyl))
names(df) <- c("name", "value")

robservable(
  "@d3/horizontal-bar-chart", 
  cell = "chart",
  input = list(data = df)
)
```

In the previous example, our species names are truncated. We can fix this because the notebook allows us to change the margins of the plot :

```r
robservable(
  "@d3/horizontal-bar-chart",
  cell= "chart",
  input = list(
    data = df,
    margin = list(top = 20, right = 0, left = 70, bottom = 0)
  )
)
```

Finally, here is a bit more complex example which displays a multi-line chart with the `gapminder` data. The `to_js_date` function is an helper to convert `Date` or `POSIXt` R objects to JavaScript `Date` values (*ie* number of miliseconds since Unix Epoch) :

```r
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
```

### Fixed width

There can be display problems when the width of the output is not fixed, especially in Rmarkdown document or Shiny app. You can use the `width` argument to fix this :

```r
robservable(
  "@d3/horizontal-bar-chart", 
  cell = "chart",
  width = 400
)
```

## Usage in Shiny

`robservable` can be used inside a Shiny app the same way as any `htmlwidget`. You will find a very basic example in [examples/shiny.R](https://github.com/juba/robservable/blob/master/examples/shiny.R).

When the notebook allows it, cells can be updated with animated transisitions instead of being recreated. You will find an example in [examples/shiny_updatable.R](https://github.com/juba/robservable/blob/master/examples/shiny_updatable.R), and the [associated notebook](https://observablehq.com/@juba/updatable-bar-chart).

You can also add observers to notebook cell values and use cell values as inputs inside your Shiny app. You will find an example in [examples/shiny_observer.R](https://github.com/juba/robservable/blob/master/examples/shiny_observer.R).

To do this, add the name of cells you want to observe in the `observers` argument. Something like :

```r
robservable(
    "@jashkenas/inputs",
    cell = c("worldMapCoordinates", "viewof worldMap1"),
    hide = "worldMapCoordinates",
    observers = "worldMap1"
)
```





