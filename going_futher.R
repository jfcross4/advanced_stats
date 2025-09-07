titanic_train <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")
titanic_test <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_test.csv")
library(dplyr)
library(rpart)
library(rpart.plot)
library(ggplot2)
my_age_model =
lm(Age ~ Sex + Pclass + SibSp,
data = titanic_train)
titanic_train$predicted_age =
predict(my_age_model, newdata=titanic_train)
titanic_train =
titanic_train %>%
mutate(Age2 = ifelse(is.na(Age), predicted_age, Age))
titanic_test$predicted_age =
predict(my_age_model, newdata=titanic_test)
titanic_test =
titanic_test %>%
mutate(Age2 = ifelse(is.na(Age), predicted_age, Age))
my_fare_model =
lm(Fare ~ Sex + Pclass + Age2 + SibSp + Parch,
data = titanic_train)
titanic_train$predicted_fare =
predict(my_fare_model, newdata=titanic_train)
titanic_train =
titanic_train %>%
mutate(Fare2 = ifelse(is.na(Fare), predicted_fare, Fare))
titanic_test$predicted_fare =
predict(my_fare_model, newdata=titanic_test)
titanic_test =
titanic_test %>%
mutate(Fare2= ifelse(is.na(Fare), predicted_fare, Fare))

linear_model_simple =
  lm(Survived ~ Sex + Age2 +  Pclass + Fare2,
     data = titanic_train)

linear_model_simple2 =
  lm(Survived ~ Sex + Age2 +  Fare2,
     data = titanic_train)

linear_model_simple =
  lm(Survived ~ Sex + Age2 +  Fare2,
     data = titanic_train %>% filter(Fare2 < 100))

summary(linear_model_simple)

linear_model_simple =
  lm(Survived ~ Sex + Age2 +  Pclass,
     data = titanic_train)

linear_model_age_exp =
  lm(Survived ~ Sex + I(1.1^Age2) +  Pclass,
     data = titanic_train %>%
       mutate(Age2 = ifelse(Age2 < 0, 0, Age2)))

summary(linear_model_age_exp)


linear_model_simple =
lm(Survived ~ Sex + Age2,
data = titanic_train)

summary(linear_model_simple)

linear_model_interaction =
lm(Survived ~ Sex*Age2,
data = titanic_train)

summary(linear_model_interaction)

prediction_frame = expand.grid(Age2 = 0:100, Sex=c("female", "male"))

prediction_frame$simple = 
  predict(linear_model_simple, newdata=prediction_frame)

prediction_frame$interaction = 
  predict(linear_model_interaction, newdata=prediction_frame)


ggplot(prediction_frame, aes(Age2, simple, color=Sex))+
  geom_line()+ggtitle("Simple Model")

ggplot(prediction_frame, aes(Age2, interaction, color=Sex))+
  geom_line()+ggtitle("Interaction Model")

library(mgcv)

model_smooth_interaction =
  gam(Survived ~ s(Age2, by=as.factor(Sex)),
     data = titanic_train, method="REML")

prediction_frame$smooth_interaction = 
  predict(model_smooth_interaction, newdata=prediction_frame)

ggplot(prediction_frame, aes(Age2, smooth_interaction, color=Sex))+
  geom_line()+ggtitle("Interaction Model")

model_smooth_interaction =
  gam(Survived ~ s(Age2, by=as.factor(Sex)) +
              Pclass,
      data = titanic_train, method="REML")

titanic_test = 
titanic_test %>%
  mutate(Fare2 = ifelse(Fare2 >=0, Fare2, 0))

hist(predict(model_smooth_interaction))

titanic_test$Survived = round(predict(model_smooth_interaction, 
                                      newdata=titanic_test))

my_smooth_submission = titanic_test %>% 
  select(PassengerId, Survived)

write.csv(my_smooth_submission, 
          file="titanic_smooth_predictions.csv",
          row.names = FALSE)

model_smooth_interaction =
  gam(Survived ~ s(Age2, by=as.factor(Sex)) +
        Pclass*Sex,
      data = titanic_train, family = binomial,
      )

titanic_test$Survived = round(predict(model_smooth_interaction, 
                                      newdata=titanic_test,
                                type="response"))
my_smooth_submission = titanic_test %>% 
  select(PassengerId, Survived)

write.csv(my_smooth_submission, 
          file="titanic_smooth_predictions.csv",
          row.names = FALSE)

my_linear_model =
  lm(Survived ~ Sex + Age2 + Pclass + Fare2, 
     data = titanic_train)

titanic_test$Survived = round(predict(my_linear_model, 
                                      newdata=titanic_test))

my_linear_submission = titanic_test %>% 
  select(PassengerId, Survived)

write.csv(my_linear_submission, 
          file="titanic_lm_predictions.csv",
          row.names = FALSE)

mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic_train, 
  method = "anova", #for minimizing RMSE*
  maxdepth=2,
  cp = 0.01
)

titanic_test$Survived = round(predict(mytree, 
                                      newdata=titanic_test))

my_tree_submission = titanic_test %>% 
  select(PassengerId, Survived)

write.csv(my_tree_submission, 
          file="titanic_tree_predictions.csv",
          row.names = FALSE)

titanic_test$Survived = round(
  0.3*predict(mytree, newdata=titanic_test)+
    0.5*predict(model_smooth_interaction, 
                newdata=titanic_test,
                type="response")+
    0.2*predict(my_linear_model, 
            newdata=titanic_test)
  )

my_crowd_submission = titanic_test %>% 
  select(PassengerId, Survived)

write.csv(my_crowd_submission, 
          file="titanic_crowd_predictions.csv",
          row.names = FALSE)
