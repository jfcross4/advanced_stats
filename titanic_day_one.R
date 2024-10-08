library(dplyr)
titanic <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

summary(titanic)

titanic %>% summarize(n=n(),
                      length(Survived),
                      sum(Survived))

titanic = titanic %>% mutate(pred=0)

MAE <- function(x,y){mean(abs(x-y))}
RMSE <- function(x, y){sqrt(mean((x-y)^2))}


titanic %>% summarize(mae = MAE(pred, Survived),
                      rmse = RMSE(pred, Survived))

titanic %>% mutate(pred=342/891) %>% 
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))


titanic %>% 
  group_by(Age >= 18) %>%
  summarize(n=n(), mean(Survived))

titanic %>% 
  group_by(Age >= 18 | is.na(Age)) %>%
  summarize(n=n(), mean(Survived))


titanic %>% 
  mutate(pred = 
           ifelse(Age >= 18 | is.na(Age),
                  0.361,
                  0.540)) %>%
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))

titanic %>% 
  mutate(pred = 
           ifelse(Age >= 18 | is.na(Age),
                  0.361,
                  0.540)) %>%
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))

titanic %>% 
  group_by(Age >= 18) %>%
  summarize(n=n(), mean(Survived))

titanic %>% 
  mutate(pred = 
           case_when(Age >= 18 & Sex == "female" ~ 0.381,
                  Age < 18 ~ 0.540,
                  is.na(Age) ~ 0.294)) %>%
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))

titanic = titanic %>% 
  mutate(woman_or_child = 
           ifelse((Age >= 18 | is.na(Age)) & Sex =="male",
                       0,1))

titanic %>% 
  mutate(pred = 
           ifelse(woman_or_child == 1,
                  0.688,
                  0.166)) %>%
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))


titanic %>% 
  mutate(pred = 
           ifelse(woman_or_child == 1,
                  1,
                  0)) %>%
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))

titanic %>% 
  group_by(woman_or_child) %>%
  summarize(n=n(), mean(Survived))



library(rpart)
library(rpart.plot)
library(RColorBrewer)

mytree <- rpart(
  Survived ~ Pclass+Sex+Age+SibSp+Parch+Fare+Embarked, 
  data = titanic, 
  method = "class",
  maxdepth=2
)

mytree <- rpart(
  Survived ~ Pclass+Sex+Age+SibSp+Parch+Fare+Embarked, 
  data = titanic, 
  method = "anova",
  maxdepth=2
)

rpart.plot(mytree)
