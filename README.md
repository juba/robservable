 <!-- badges: start -->
 [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
  [![R build status](https://github.com/juba/robservable/workflows/R-CMD-check/badge.svg)](https://github.com/juba/robservable/actions)
  <!-- badges: end -->

# robservable

The goal of this package is to allow the use of [Observable](https://observablehq.com/) notebooks (or part of them) as htmlwidgets in R.

Note that this is a package in early stage of development.

## Features

- Display an entire published notebook as an htmlwidget
- Display specified named cells of a published notebook as an htmlwidget
- Use R data to update cell values before displaying the notebook
- Add observers on cells values to get them back inside a Shiny app
- Use inside Shiny app or Rmarkdown document (as any htmlwidget)

## Limitations

- Only published notebooks can be used (but you may fork and publish any notebook in Observable)
- Only named cells can be displayed alone (but you can fork the notebook and name the cell in Observable)


## Installation

```r
remotes::install_github("juba/robservable")
```

## Usage


For an introduction and examples, see the [introduction to robservable](https://juba.github.io/robservable/articles/introduction.html) vignette.

For usage in Shiny, see the [robservable in Shiny applications](https://juba.github.io/robservable/articles/shiny.html) vignette (work in progress)

