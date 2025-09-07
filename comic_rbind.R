marvel = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/marvel-wikia-data.csv")

dc = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/dc-wikia-data.csv")

library(tidyverse)

comic = rbind(
marvel %>% select(name, ALIGN, EYE, HAIR, SEX, GSM, ALIVE, APPEARANCES,
                  FIRST.APPEARANCE, YEAR=Year) %>%
  mutate(Universe="marvel"),
dc %>% select(name, ALIGN, EYE, HAIR, SEX, GSM, ALIVE, APPEARANCES,
                  FIRST.APPEARANCE, YEAR) %>% 
  mutate(Universe="dc"))
