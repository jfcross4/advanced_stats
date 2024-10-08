titanic = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

library(tidyverse)

MAE <- function(x,y){mean(abs(x-y))}
RMSE <- function(x, y){sqrt(mean((x-y)^2))}

titanic = titanic %>% 
  mutate(is_kid = Age <= 18)

summary(titanic)

titanic %>% 
  group_by(Sex, Pclass, is_kid) %>%
  summarize(n=n(),
            mean(Survived))

titanic_groups = 
  titanic %>% 
  group_by(Sex, Pclass, is_kid) %>%
  summarize(n=n(),
            prediction = mean(Survived))

titanic = 
left_join(titanic,
          titanic_groups,
          by=c("Sex", "Pclass", "is_kid"))

titanic = 
  titanic %>%
  mutate(mae_prediction = 
           round(prediction))

titanic %>%
  summarize(mae = MAE(mae_prediction, Survived),
            rmse = RMSE(prediction, Survived))

