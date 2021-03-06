# 1.0 Library
library(tidyverse)
library(ggrepel)

# 2.0 Load + merge data
death_tbl <- read_csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv") %>%
  select(deaths, countriesAndTerritories, popData2019,dateRep, countryterritoryCode) %>%
  mutate(across(countriesAndTerritories, str_replace_all, "_", " ")) %>%
  mutate(countriesAndTerritories = case_when(
    countriesAndTerritories == "United Kingdom" ~ "UK",
    countriesAndTerritories == "United States of America" ~ "USA",
    countriesAndTerritories == "Czechia" ~ "Czech Republic",
    TRUE ~ countriesAndTerritories
  )) %>%
  group_by(countriesAndTerritories, popData2019) %>%
  summarize(deaths = sum(deaths)) %>%
  mutate(deaths = (deaths/popData2019)*100) %>%
  select(countriesAndTerritories, deaths)

# 3.0 Create the worldmap with death-rates
  world <- map_data("world")
  life.exp.map <- merge(x=death_tbl, y=world_map, by.x = "countriesAndTerritories", by.y = "region")
  
  ggplot(life.exp.map, aes(map_id = countriesAndTerritories, fill = deaths))+
    geom_map(aes(map_id =  countriesAndTerritories), map = world )+
    expand_limits(x = life.exp.map$long, y = life.exp.map$lat)+
    #coord_fixed() +
    labs(
      title = str_glue("Confirmed COVID-19 deaths realtive to population size"),
      subtitle = str_glue("More than 1.2 Million confirmed COVID-19 deaths worldwide"),
      x = "Longitude",
      y = "Latitude"
    ) +
    scale_fill_continuous(name = "Death in %")
  fpath <- system.file("02_data_wrangling/Challenge4_2_world.png",package='imager') 
  im <- load.image(fpath)
  plot(im)
  
  
  library(magick)
 im <- image_read("Challenge4_2_world_2.png")
 plot(im)