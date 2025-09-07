train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/train.csv")

View(train)
table(train$HomePlanet)

train = 
train %>%
  mutate(Transported = 
           as.logical(Transported))

m = glm(Transported ~ Age, 
        family="binomial",
        data=train)
summary(m)

m = glm(Transported ~ HomePlanet, 
        family="binomial",
        data=train)
summary(m)

m = glm(Transported ~ CryoSleep, 
        family="binomial",
        data=train)
summary(m)
