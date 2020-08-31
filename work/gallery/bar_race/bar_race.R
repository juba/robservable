
## Covid-19 positive tests by department
## Source : https://www.data.gouv.fr/fr/datasets/donnees-relatives-aux-resultats-des-tests-virologiques-covid-19/


library(tidyverse)

df <- read_csv2("gallery/bar_race/sp-pos-quot-dep-2020-07-29-19h15.csv")

df <- df %>%
  group_by(dep, jour) %>%
  summarise(across(P:T, sum)) %>%
  mutate(value = cumsum(P)) %>%
  select(id = dep, date = jour, value) %>%
  arrange(id, date) %>%
  mutate(date_label = substring(date, 1, 7))

robservable(
  "https://observablehq.com/@juba/bar-chart-race",
  include = c("viewof date", "chart", "draw", "styles"),
  hide = "draw",
  input = list(
    data = df,
    title = "Tests positifs Covid-19 par département",
    subtitle = "Nombre cumulé de tests positifs",
    source = "Santé publique France"
  )
)


## Covid-19 deaths by department
## Source : https://www.data.gouv.fr/fr/datasets/donnees-de-certification-electronique-des-deces-associes-au-covid-19-cepidc/

df <- read_csv2("gallery/bar_race/covid-cedc-sex-quot.csv")

df <- df %>%
  group_by(dep, jour) %>%
  filter(sexe == 0) %>%
  rename(value = Dc_Elec_Covid_cum) %>%
  select(id = dep, date = jour, value) %>%
  arrange(id, date)

robservable(
  "https://observablehq.com/@juba/bar-chart-race",
  include = c("viewof date", "chart", "draw", "styles"),
  hide = "draw",
  input = list(
    data = df,
    title = "Décès dus au Covid-19",
    subtitle = "Nombre cumulé de décès par département",
    source = "Santé publique France"
  )
)



## Covid-19 deaths by country
## Source : Johns Hopkins https://github.com/CSSEGISandData/COVID-19

library(tidyverse)

d <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

d <- d %>%
  select(-`Province/State`, -Lat, -Long) %>%
  rename(id = `Country/Region`) %>%
  group_by(id) %>%
  summarise(across(everything(), sum)) %>%
  pivot_longer(-id, names_to = "date") %>%
  mutate(date = as.character(lubridate::mdy(date)))

robservable(
  "https://observablehq.com/@juba/bar-chart-race",
  include = c("viewof date", "chart", "draw", "styles"),
  hide = "draw",
  input = list(
    data = d,
    title = "COVID-19 deaths",
    subtitle = "Cumulative number of COVID-19 deaths by country",
    source = "Source : Johns Hopkins University"
  )
)

write_csv(d, "gallery/bar_race/covid_deaths_by_country.csv")




