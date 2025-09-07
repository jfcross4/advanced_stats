actuals = 
  read.csv("box_office_actuals.csv")

preds = 
  read.csv("box_office_predictions.csv")

library(tidyverse)

preds_long = preds %>% 
  pivot_longer(
    cols = c(Shay:Jonah),
    names_to = "student",
    values_to = "pred"
  )

preds_long %>% 
  ggplot(aes(pred)) +
  geom_histogram() +
  facet_wrap(~Movie)

preds_long %>% 
  ggplot(aes(pred)) +
  geom_histogram() +
  facet_wrap(~student)

preds_and_actuals = 
  left_join(preds_long, 
          actuals,
          by="Movie"
          )

preds_and_actuals =  
preds_and_actuals %>%
  mutate(error = abs(Actual - pred))

preds_and_actuals %>%
  group_by(student) %>%
  summarize(mae = mean(error)) %>%
  arrange(mae)

MAE <- function(x,y){mean(abs(x-y))}
RMSE <- function(x, y){sqrt(mean((x-y)^2))}
RMSPE <- function(pred, actual){
  100*sqrt(mean(((pred-actual)/actual)^2))
}

preds_and_actuals %>%
  summarize(mae = MAE(pred, Actual),
         rmse = RMSE(pred, Actual),
         rmspe = RMSPE(pred, Actual))

preds_and_actuals %>%
  group_by(student) %>%
  summarize(mae = MAE(pred, Actual),
            rmse = RMSE(pred, Actual),
            rmspe = RMSPE(pred, Actual)) %>%
  arrange(rmse)

preds_and_actuals %>%
ggplot(aes(pred, Actual, color=student))+
  geom_point()+geom_abline(slope=1, intercept=0)

preds_and_actuals %>%
  ggplot(aes(pred, Actual, color=student))+
  geom_point()+geom_abline(slope=1, intercept=0)+
  facet_wrap(~student)

preds_and_actuals %>%
  filter(student != "Ben") %>%
  ggplot(aes(pred, Actual, color=student, label=Movie))+
  geom_label()+geom_abline(slope=1, intercept=0)

class_avg = 
  preds_and_actuals %>%
  group_by(Movie) %>%
  summarize(pred = mean(pred),
            Actual=mean(Actual))

class_median = 
  preds_and_actuals %>%
  group_by(Movie) %>%
  summarize(pred = median(pred),
            Actual=median(Actual))

class_avg %>%
  ggplot(aes(pred, Actual, label=Movie))+
  geom_label()+geom_abline(slope=1, intercept=0)

class_median %>%
  ggplot(aes(pred, Actual, label=Movie))+
  geom_label()+geom_abline(slope=1, intercept=0)

class_median %>%
  summarize(mae = MAE(pred, Actual),
            rmse = RMSE(pred, Actual)) 

class_avg %>%
  summarize(mae = MAE(pred, Actual),
            rmse = RMSE(pred, Actual)) 

class_avg_without_B = 
  preds_and_actuals %>%
  filter(student != "Ben") %>%
  group_by(Movie) %>%
  summarize(pred = mean(pred),
            Actual=mean(Actual))

class_avg_without_B %>%
  summarize(mae = MAE(pred, Actual),
            rmse = RMSE(pred, Actual)) 
