# census Random Forest and Gradient Boosted Tree code

#packages, you may need to install these:
library(tidyverse)
library(xgboost)
library(randomForest)
library(caret)
library(mice)

# creating functions that we'll use later
make_outliers_na <- function(x) 
{ifelse(x %in% boxplot.stats(x)$out, NA, x)}

clean_census = function(census){
  census %>%
    mutate(Height_cm = gsub("[^0-9.-]", "", Height_cm)) %>%
    mutate_at(vars(Ageyears, 
                   Height_cm,
                   Footlength_cm,
                   Armspan_cm,
                   Languages_spoken,
                   Travel_time_to_School,
                   Reaction_time,
                   Score_in_memory_game,
                   Importance_reducing_pollution:Left_Footlength_cm,
                   Index_Fingerlength_mm,
                   Ring_Fingerlength_mm,
                   Sleep_Hours_Schoolnight:Home_Occupants,
                   Text_Messages_Sent_Yesterday:Work_At_Home_Hours),
              as.numeric) %>%
    mutate_at(vars(Country,
                   Region,
                   Gender, 
                   Handed, 
                   Travel_to_School, 
                   Favourite_physical_activity,
                   Longer_foot,
                   Longer_Finger_Lefthand:Favorite_School_Subject,
                   Home_Internet_Access,
                   Communication_With_Friends,
                   Schoolwork_Pressure:Charity_Donation
    ), as.factor) %>%
    mutate_at(vars(Ageyears, 
                   Height_cm,
                   Footlength_cm,
                   Armspan_cm,
                   Languages_spoken,
                   Travel_time_to_School,
                   Reaction_time,
                   Score_in_memory_game,
                   Importance_reducing_pollution:Left_Footlength_cm,
                   Index_Fingerlength_mm,
                   Ring_Fingerlength_mm,
                   Sleep_Hours_Schoolnight:Home_Occupants,
                   Text_Messages_Sent_Yesterday:Work_At_Home_Hours),
              make_outliers_na)
  
}

### reading in the datasets and cleaning them
train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/all_states_all_grades_all_years_sample500.csv")

test_no_sleep = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/census_sleep_test_set.csv")

all = rbind(train %>% mutate(prediction_number=0), 
            test_no_sleep)

all_clean = clean_census(all)
all_clean[all_clean ==""] = NA #replacing blanks with NA

imputed_data <-  mice(all_clean, method="cart", maxit=1, m=1)
full_data <- complete(imputed_data) 

# splitting back into training and test sets
train = full_data[1:500, ]
test = full_data[-c(1:500),]

# random forest
mForest <- randomForest(x=train %>% 
                          dplyr::select(-Sleep_Hours_Schoolnight, 
                                        -prediction_number), 
                        y=train$Sleep_Hours_Schoolnight, 
                        ntree=200, mtry=19)


# random forest numeric only
mForest_numeric_only <- randomForest(x=train %>% 
                                       select(-Sleep_Hours_Schoolnight, 
                                              -prediction_number) %>%
                                       select_if(is.numeric), 
                                     y=train$Sleep_Hours_Schoolnight, 
                                     ntree=800, mtry=19)

# cross-validation for numeric variables:

my_control <- 
  trainControl(method="cv", number=5, verboseIter = TRUE)

random_forest_grid = expand.grid(
  mtry = seq(10, 30, 4)
)

rf_caret <- train(x=train %>% 
                    select(-Sleep_Hours_Schoolnight, 
                           -prediction_number) %>%
                    select_if(is.numeric), 
                  y=train$Sleep_Hours_Schoolnight, 
                  method='rf', 
                  trControl= my_control, 
                  tuneGrid=random_forest_grid,
                  ntree=1000) 

plot(rf_caret)
rf_caret$results
rf_caret$bestTune

## Gradient Boosted Tree

train_x = train %>% 
  select(-Sleep_Hours_Schoolnight, 
         -prediction_number) %>%
  select_if(is.numeric) %>% 
  data.matrix()

xgb_train = xgb.DMatrix(data = train_x, 
                        label = train$Sleep_Hours_Schoolnight)

test_x = test %>% 
  select(-Sleep_Hours_Schoolnight, 
         -prediction_number) %>%
  select_if(is.numeric) %>% 
  data.matrix()

xgb_test = xgb.DMatrix(data = test_x, 
                        label = test$Sleep_Hours_Schoolnight)

watchlist = list(train=xgb_train, test=xgb_test)

model = xgb.train(data = xgb_train, 
                  params = list(eta=1),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70)


model = xgb.train(data = xgb_train, 
                  params = list(eta=0.1),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70)

model = xgb.train(data = xgb_train, 
                  params = list(eta=0.01),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70)

model = xgb.train(data = xgb_train, 
                  params = list(eta=0.005),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 1300)

model = xgb.train(data = xgb_train, 
                  params = list(eta=0.005),
                  max.depth = 2, 
                  watchlist=watchlist, 
                  nrounds = 1300)



train_x = train %>% 
  select(-Sleep_Hours_Schoolnight, 
         -prediction_number) %>%
  data.matrix()

test_x = test %>% 
  select(-Sleep_Hours_Schoolnight, 
         -prediction_number) %>%
  data.matrix()

final = xgboost(data = xgb_train, max.depth = 3, 
                nrounds = 1300, 
                params = list(eta=0.005),
                verbose = 0)

xgb.plot.importance(xgb.importance(colnames(xgb_train), model = final), 
                    rel_to_first = TRUE, xlab = "Relative importance")

test$gbm_predictions = predict(final, newdata=xgb_test)

### random forest

test$rf_predictions = predict(mForest_numeric_only, newdata=test)

test %>% ggplot(aes(rf_predictions, gbm_predictions))+
  geom_point()

test %>% summarize(cor(rf_predictions, gbm_predictions))

test = 
test %>% mutate(
  average_predictions = 0.5*rf_predictions + 0.5*gbm_predictions
)

write.csv(test %>% 
            dplyr::select(average_predictions, prediction_number),
          file="jared_gbm_predictions.csv", 
          row.names=FALSE)
