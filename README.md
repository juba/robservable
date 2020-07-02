 <!-- badges: start -->
 [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
  [![R build status](https://github.com/juba/robservable/workflows/R-CMD-check/badge.svg)](https://github.com/juba/robservable/actions)
  <!-- badges: end -->

# robservable

The goal of this package is to allow the use of [Observable](https://observablehq.com/) notebooks (or part of them) as htmlwidgets in R.

Note that it is **not an `iframe`** embedding a whole notebook -- cells are `<div>`s included directly in your document.  You can choose what cells to display, update cell values from R, and add observers to cells to get their values back into a Shiny application.

This package is in early stage of development.

## Features

- Display an entire published notebook as an htmlwidget
- Display specific cells of a published notebook as an htmlwidget
- Use R data to update cell values
- Add observers on cell values to get them back inside a Shiny app
- Use inside Shiny app or Rmarkdown document (as any htmlwidget)

## Limitations

- Only published notebooks can be used (but you may fork and publish any notebook in Observable)
- Only named cells can be displayed by name, but you can reference unnamed cells by index (1-based), or you can fork the notebook and name the cell in Observable


## Installation

```r
remotes::install_github("juba/robservable")
```

## Usage

For an introduction and examples, see the [introduction to robservable](https://juba.github.io/robservable/articles/introduction.html) vignette.

For a small gallery of interesting notebooks, see the [robservable gallery](https://juba.github.io/robservable/articles/gallery.html) vignette (work in progress).

For usage in Shiny, see the [robservable in Shiny applications](https://juba.github.io/robservable/articles/shiny.html) vignette (work in progress)

