data("Cholera")
View(Cholera)
library(tidyverse)
## data from 1849 Cholera outbreak

#pop_dens
#population density (persons per acre), a numeric vector

#persons_house
#persons per inhabited house, a numeric vector

#house_valpp
#average annual value of house, per person (pounds), a numeric vector

#poor_rate
#poor rate precept per pound of house value, a numeric vector

Cholera %>%
  ggplot(aes(x=water, y=cholera_drate)) +
  geom_boxplot()

Cholera %>%
  ggplot(aes(x=elevation, y=cholera_drate)) +
  geom_point()

Cholera %>% 
  ggplot(aes(elevation, cholera_drate)) + 
  geom_point()

Cholera %>% 
  ggplot(aes(water, cholera_drate)) + 
  geom_point()

Cholera %>% 
  ggplot(aes(water, cholera_drate)) + 
  geom_boxplot()

Cholera %>% 
  ggplot(aes(elevation, cholera_drate)) + 
  facet_wrap(~water)+
  geom_point()


elevation.model = 
  lm(cholera_drate ~ elevation,
     data = Cholera)

summary(elevation.model)

water.model = 
  lm(cholera_drate ~ water,
     data = Cholera)

summary(water.model)


full.model = 
  lm(cholera_drate ~ elevation + water,
     data = Cholera)

summary(full.model)












###
library(HistData)
library(sp)

slist <- split(Snow.streets[,c("x","y")],as.factor(Snow.streets[,"street"]))
Ll1 <- lapply(slist,Line)
Lsl1 <- Lines(Ll1,"Street")
Snow.streets.sp <- SpatialLines(list(Lsl1))
plot(Snow.streets.sp, col="gray")
title(main="Snow's Cholera Map of London (R)")

spp <- SpatialPoints(Snow.pumps[,c("x","y")])
Snow.pumps.sp <- SpatialPointsDataFrame(spp,Snow.pumps[,c("x","y")])
plot(Snow.pumps.sp, add=TRUE, col='blue', pch=17, cex=1.0)
text(Snow.pumps[,c("x","y")], labels=Snow.pumps$label, pos=1, cex=0.6)

Snow.deaths.sp = SpatialPoints(Snow.deaths[,c("x","y")])
plot(Snow.deaths.sp, add=TRUE, col ='red', pch=1, cex=0.1)

####

