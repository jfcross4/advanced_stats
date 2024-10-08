# Titanic Day Two

library(dplyr)
library(rpart)
library(rpart.plot)


titanic <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE*
  maxdepth=1
)

mytree
rpart.plot(mytree)

mytree <- rpart(
  Survived ~ Sex, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=2
)

mytree
rpart.plot(mytree)

mytree <- rpart(
  Survived ~ Age, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=1
)

mytree <- rpart(
  Survived ~ Age + Sex, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=2
)

titanic$pred = predict(mytree)[,"1"]

titanic %>% 
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))

mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "class", #for minimizing MAE
  control = rpart.control(cp = 0, maxdepth = 30)
)

titanic$pred = predict(mytree, type="class") %>% 
  as.character() %>% as.numeric()

titanic %>% 
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))

setA = sample(1:891, floor(891/2), replace=FALSE)
titanicA = titanic[setA, ]
titanicB = titanic[-setA, ]

mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanicA, 
  method = "anova", #for minimizing RMSE
  cp = 0.09, maxdepth = 15
)

rpart.plot(mytree)

titanicA$pred = predict(mytree)
titanicB$pred = predict(mytree, 
                       newdata=titanicB) 

titanicA %>% 
  summarize(rmse = RMSE(pred, Survived))

titanicB %>% 
  summarize(rmse = RMSE(pred, Survived))
# out of sample, 6 out-performs 30!