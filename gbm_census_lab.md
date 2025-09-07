Gradient Boosted Trees for School Census Data
-----------------------------------------------------

# Clean the Census Data

These first sections of code is the same code we've used before to clean the training and test sets.

```r
#loading packages, you may need to install these first!:
library(tidyverse)
library(xgboost)
library(randomForest)
library(caret)
library(mice)
```

```r
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
```

```r
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
```


# Random Forest Models... Again

Here, once again, is the code to random forest models using either all variables or only numeric variables.

```r
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
                                     ntree=200, mtry=19)
```

and here's code for doing cross-validation of random forest models to find the best value of mtry.

```r
my_control <- 
  trainControl(method="cv", number=5, verboseIter = TRUE)

random_forest_grid = expand.grid(
  mtry = seq(6, 30, 3)
)

rf_caret <- train(x=train %>% 
                    select(-Sleep_Hours_Schoolnight, 
                           -prediction_number) %>%
                    select_if(is.numeric), 
                  y=train$Sleep_Hours_Schoolnight, 
                  method='rf', 
                  trControl= my_control, 
                  tuneGrid=random_forest_grid,
                  ntree=200) 

plot(rf_caret)
rf_caret$results
rf_caret$bestTune
```

# Gradient Boosted Trees

Finally, something completely new!

For gradient boosted trees, we'll need to transform the data into data matrices as shown below.  Gradient boosted trees should handle the categorical variables with many levels better than the random forest models did so I won't limit this to using only numeric variables.

```r
train_x = train %>% 
  select(-Sleep_Hours_Schoolnight, 
         -prediction_number)
  data.matrix()

xgb_train = xgb.DMatrix(data = train_x, 
                        label = train$Sleep_Hours_Schoolnight)

test_x = test %>% 
  select(-Sleep_Hours_Schoolnight, 
         -prediction_number)
  data.matrix()

xgb_test = xgb.DMatrix(data = test_x, 
                        label = test$Sleep_Hours_Schoolnight)
```

# Cross-Validation of Gradient Boosted Trees

There are three parameters to play with here.  Let's start with perhaps the most important parameter, eta.  Eta is the learning rate.  In a way this is similar to the mutation rate for our genetic algorithms.  With a higher learning rate each tree makes a larger improvement on the work of previous trees and you'll "get there" faster.  The downside is that you might over fit the data.  The maximum learning rate, eta, is 1 where everything seen in the data is taken as the absolute full truth.  The minimum is 0, where the model never learns anything.  With an eta of 0.5, the results of each layer of tree is taken as half-truth and your model is adjusted half as much as that tree suggests.

Try doing cross-validation with an eta of 1.  The in sample RMSE (train-rmse) should drop way down very quickly but the out-of-sample RMSE might be terrible.

```r
watchlist = list(train=xgb_train, test=xgb_test)

model = xgb.train(data = xgb_train, 
                  params = list(eta=1),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70)
```

Now, compare that to a lower learning rate...

```r
model = xgb.train(data = xgb_train, 
                  params = list(eta=0.1),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70)
```

... or an even lower learning rate.

```r
model = xgb.train(data = xgb_train, 
                  params = list(eta=0.01),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 70)
```

With a learning rate of 0.01, the good news is that the out-of-sample RMSE is nearly as good as the in-sample RMSE.  The bad news is that they're both terrible!  With a low learning rate we need to learn for much longer which means more rounds of trees.  Let's stick with a learning rate of 0.01 but use 500 tree instead of 70 trees.  We do this by changing nrounds.  In general, the lower the learning rate the greater nrounds will need to be.  The cross-validation results show RMSE's by round and if you use too many round, you'll see that the RMSE's start to go back up.

```r
model = xgb.train(data = xgb_train, 
                  params = list(eta=0.01),
                  max.depth = 3, 
                  watchlist=watchlist, 
                  nrounds = 500)
```

The other parameter you can play with is "max.depth".  max.depth is how many layers of branches there will be in each of the "nrounds" of trees you are making.

When you've settled on the best combination of eta, nrounds and max.depth you can make the gradient boosted tree model as follows:

```r
final = xgboost(data = xgb_train, max.depth = 3, 
                nrounds = 500, 
                params = list(eta=0.01),
                verbose = 0)
```
and you can see the importance of each variable in this model as follows:

```r
xgb.plot.importance(xgb.importance(colnames(xgb_train), model = final), 
                    rel_to_first = TRUE, xlab = "Relative importance")
```


# Making Predictions

The following code makes predictions on the test set from your gradient boosted tree model.

```r
test$gbm_predictions = predict(final, newdata=xgb_test)
```

You can also make predictions from your random forest model and compare the predictions:

```r
test$rf_predictions = predict(mForest_numeric_only, newdata=test)

test %>% ggplot(aes(rf_predictions, gbm_predictions))+
  geom_point()
```

If you want to get fancy, you can make predictions that are some weighted average of the random forest predictions and the gradient boosted tree predictions.  Maybe there's room to benefit from the wisdom of a (very small) crowd?

```r
test = 
test %>% mutate(
  average_predictions = 0.5*rf_predictions + 0.5*gbm_predictions
)
```

Lastly, you can write your predictions to a .csv file and once again send them to your teacher for evaluation and the chance to win an R sticker.

```r
write.csv(test %>% 
            dplyr::select(average_predictions, prediction_number),
          file="jareds_best_predictions_for_real_this_time.csv", 
          row.names=FALSE)
```
