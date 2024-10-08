library(tidyverse)
test = read.csv(file="test.csv")
test %>% dplyr::select(prediction_number, Sleep_Hours_Schoolnight)

names =
  c("jonah",
    "ian",
    "ben",
    "lucy",
    "shay",
    "jake",
    "full_random_forest",
    "numeric_random_forest",
    "jake_rf",
    "jonah_rf",
    "beckett_gbm",
    "ian_gbm",
    "jake_gbm",
    "jonah_gbm",
    "shay_gbm",
    "aidan_gbm")

names =
  c("full_random_forest",
    "numeric_random_forest",
    "jake_rf",
    "jonah_rf",
    "beckett_gbm",
    "ian_gbm",
    "jake_gbm",
    "jonah_gbm",
    "shay_gbm",
    "aidan_gbm")

predictions = data.frame(name=NA, 
                         prediction_number=NA,
                         preds = NA)

for (name in names){
temp = 
  read.csv(paste0("sleep_predictions/", 
                  name,
                  "_predictions.csv"))

temp$name = name
predictions = rbind(predictions,
      temp %>% dplyr::select(name, prediction_number, preds))
  
}


preds_plus = left_join(predictions, 
                       test %>% 
          dplyr::select(prediction_number, 
                        Sleep_Hours_Schoolnight), 
                       by="prediction_number") %>%
  filter(!is.na(name))

RMSE = function(x,y){sqrt(mean((x-y)^2))}

preds_plus %>% group_by(name) %>%
  summarize(rmse = RMSE(preds, Sleep_Hours_Schoolnight),
            sd_preds = sd(preds),
            r = cor(preds, Sleep_Hours_Schoolnight)) %>%
  arrange(rmse)

preds_plus %>% group_by(prediction_number) %>%
  summarize(mean_pred = mean(preds, na.rm=TRUE),
            median_pred = median(preds, na.rm=TRUE),
            Sleep_Hours_Schoolnight = first(Sleep_Hours_Schoolnight)) %>%
  ungroup() %>%
  summarize(rmse_mean = RMSE(mean_pred, Sleep_Hours_Schoolnight),
            rmse_median = RMSE(median_pred, Sleep_Hours_Schoolnight))

wide_data = preds_plus %>%
  pivot_wider(id_cols=c(prediction_number,Sleep_Hours_Schoolnight),
              names_from=name,
              values_from=preds)
  
m = lm(Sleep_Hours_Schoolnight ~ 
         jonah + ian + ben + lucy + shay + jake,
     data=wide_data)

summary(m)
# 


m2 = lm(Sleep_Hours_Schoolnight ~ ian + ben + jake,
       data=wide_data)
summary(m2)

m2 = lm(Sleep_Hours_Schoolnight ~ ian + ben,
        data=wide_data)
summary(m2)

round(cor(wide_data),2)

m3 = lm(Sleep_Hours_Schoolnight ~ lucy,
        data=wide_data)
summary(m3)

m3 = lm(Sleep_Hours_Schoolnight ~ jake,
        data=wide_data)
summary(m3)

m4 = lm(Sleep_Hours_Schoolnight ~ jonah + ian + ben + lucy + shay +
          numeric_random_forest + full_random_forest,
        data=wide_data)

summary(m4)

m5 = lm(Sleep_Hours_Schoolnight ~ ben + 
          numeric_random_forest,
        data=wide_data)
summary(m5)


m6 = lm(Sleep_Hours_Schoolnight ~  
          numeric_random_forest,
        data=wide_data)
summary(m6)

m7 = lm(Sleep_Hours_Schoolnight ~  
          jake_rf + beckett_gbm + 0,
        data=wide_data)
summary(m7)

m7 = lm(Sleep_Hours_Schoolnight ~  
          I(0.5*(jake_rf + beckett_gbm)) + 0,
        data=wide_data)

m8 = lm(Sleep_Hours_Schoolnight ~  
          jake_rf + I(beckett_gbm-jake_rf) + 0,
        data=wide_data)


wide_data %>% 
  ggplot(aes(jake_rf, beckett_gbm))+geom_point()+
  geom_abline(slope=1, intercept=0)

wide_data %>% 
  summarize(cor(jake_rf, beckett_gbm))
