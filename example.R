library(questionr)
data(hdv2003)
df <- as.data.frame(table(hdv2003$qualif))
names(df) <- c("name", "value")

robservable(
  "@d3/horizontal-bar-chart",
  output_cell= "chart",
  input = list(
    #color = "#567890",
    margin = list(top = 20, right = 0, left = 150, bottom = 0)
  ),
  input_df = list(data = df)
)


robservable(
  "@d3/bar-chart",
  output_cell= "chart",
  input = list(
    color = "#567890",
    height = 800
  ),
  input_df = list(data = df)
)

robservable(
  "@d3/bar-chart",
  input = list(
    color = "#567890",
    height = 800
  ),
  input_df = list(data = df)
)

robservable(
  "@zacol/marvel-cinematic-universe-sankey-diagram",
  output_cell = "chart"
)

robservable(
  "@zacol/marvel-cinematic-universe-sankey-diagram",
  output_cell = 1
)

robservable(
  "@mbostock/eyes",
  output_cell = "canvas"
)

robservable(
  "@rreusser/gpgpu-boids"
)

df <- data.frame(table(mtcars$cyl))
names(df) <- c("name", "value")
robservable(
  "@d3/horizontal-bar-chart",
  output_cell= "chart",
  input_df = list(data = df)
)


