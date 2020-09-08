 <!-- badges: start -->
 [![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
  [![R build status](https://github.com/juba/robservable/workflows/R-CMD-check/badge.svg)](https://github.com/juba/robservable/actions)
  <!-- badges: end -->

# robservable

This package allows the use of [Observable](https://observablehq.com/) notebooks (or parts of them) as `htmlwidgets` in R.

Note that *it is not an `iframe` embedding a whole notebook* -- cells are `<div>` included directly in your document or application.  You can choose what cells to display, update cell values from R, and add observers to cells to get their values back into a Shiny application.

The following GIF shows a quick example of reusing a bar chart race notebook inside R with our own data.

![example](https://raw.githubusercontent.com/juba/robservable/master/resources/screencast_0.2.gif)

You'll find more examples and the associated R code in the [robservable gallery](https://juba.github.io/robservable/articles/gallery.html).

## Features

- Display an entire published or shared notebook as an `htmlwidget`
- Display specific cells of a published or shared notebook as an `htmlwidget`
- Use R data to update cell values
- Add observers on cell values to communicate with a Shiny app
- Use inside Shiny app or Rmarkdown document (as any htmlwidget)

## Limitations

- Named cells can be included by name, but unnamed cells are refenced by their index (1-based), which is sometimes a bit tricky to determine. An alternative is to fork the notebook and name the cell in Observable.


## Installation

The package is not on CRAN yet, but you can install the development version with:

```r
remotes::install_github("juba/robservable")
```

## Usage

For an introduction and examples, see the [introduction to robservable](https://juba.github.io/robservable/articles/introduction.html) vignette.

For a small gallery of interesting notebooks, see the [robservable gallery](https://juba.github.io/robservable/articles/gallery.html) vignette.

For usage in Shiny, see the [robservable in Shiny applications](https://juba.github.io/robservable/articles/shiny.html) vignette (work in progress).

