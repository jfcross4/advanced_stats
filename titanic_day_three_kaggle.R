# Titanic Day Three: Kaggle

library(dplyr)
library(rpart)
library(rpart.plot)

titanic_train <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

titanic_test <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_test.csv")

mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic_train, 
  method = "anova", #for minimizing RMSE*
  maxdepth=2,
  cp = 0.01
)

titanic_test$Survived = predict(mytree, 
                        newdata=titanic_test) 

my_submission = titanic_test %>% 
  select(PassengerId, Survived)

write.csv(my_submission, 
          file="titanic_predictions.csv",
          row.names = FALSE)


