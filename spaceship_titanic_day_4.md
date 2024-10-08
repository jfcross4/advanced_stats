Spaceship Titanic (Day 4, Gradient Boosting and Cross Validation)
------------------------
[Spaceship Titanic](https://www.kaggle.com/competitions/spaceship-titanic/overview)

## Data and Packages

First, load both the test set and the training set:

```r
library(tidyverse)

train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/train.csv")

test = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/test.csv")
  
test$Transported = NA

```

# Data Clean-up Function

Here's the function similar to the one we created in our last spaceship lab.  I've added a column of total expenditures, converted num to a numeric value and added an indicator for whether the passenger's name is missing.

```r
cleanship = function(df){
  df %>%
    mutate_at(c("Transported", "VIP", 
                "CryoSleep"),
              as.logical) %>%
    mutate_at(c("HomePlanet",  
                "Destination"),
              as.factor) %>%
    mutate_at(vars(RoomService:VRDeck),
              list(log = ~log(.x + 1))) %>%
    separate(Name, 
             c("FirstN", "LastN"), 
             " ", 
             remove = FALSE, 
             extra = "drop") %>%
    separate(PassengerId, 
             c("Party","PartyNr"), 
             "_", 
             remove = FALSE, 
             extra = "drop") %>%
    separate(Cabin, 
             c("deck","num", "side"), 
             "/", 
             remove = FALSE, 
             extra = "drop") %>%
    mutate(
      num = as.numeric(num),
      tot_exp = RoomService + FoodCourt + ShoppingMall+ 
        Spa + VRDeck,
      name_missing = 
        ifelse(Name=="", 1, 0))
}

```

and putting it to use:

```r
train = cleanship(train)

test = cleanship(test)

```

This time we won't create a model_set and a test_set since we're going to let our gradient boosted tree model do cross validation.

First, install and load the package:

```r
library(xgboost)
```

Next, we need to prepare the data for modelling.  This take a little work:

```r
label <- as.numeric(train$Transported) 

GBM_VARS = c("HomePlanet", 
             "CryoSleep", 
             "deck", 
             "side", 
             "Destination", 
             "Age",
             "VIP", 
             "RoomService", 
             "FoodCourt", 
             "ShoppingMall", 
             "Spa", 
             "VRDeck",
             "tot_exp",
            "name_missing",
            "LastN",
            "num")
            
Vars <- train %>% 
  dplyr::select(all_of(GBM_VARS)) 

numericVars <- which(sapply(Vars, is.numeric)) 
numericVarNames <- names(numericVars)
DFnumeric <- Vars[, names(Vars) %in% numericVarNames]
DFfactors <- Vars[, !(names(Vars) %in% numericVarNames)]
DFdummies <- DFfactors %>% mutate_all(as.factor) %>%
  mutate_all(as.numeric)
combined <- cbind(DFnumeric, DFdummies) 
```

This next part is crucial.  We list the parameters we'd like to use in our model.  This is the part that you might later want to tweak:

```r
params <- list(booster = "gbtree", 
               objective = "binary:logistic", 
               eta=0.05, gamma=0, 
               max_depth=4, 
               min_child_weight=5, 
               subsample=0.5, colsample_bytree=0.5
               )

```
Next, we'll run our cross-validation.  The model will tell us the number of trees which produced the most accurate out-of-sample predictions.

```r
xgbcv <- xgb.cv( params = params, 
                 data = as.matrix(combined),
                 label = label,
                 nrounds = 1000, 
                 nfold = 10, 
                 showsd = T, 
                 stratified = T, 
                 print_every_n = 10, 
                 early_stopping_rounds = 20, 
                 maximize = F)

```

You can alter the "params" in the code above and try the cross-validation again and find the best out-of-sample predictions.  Where you're ready use those parameters to make your model (changing the values of the parameters in the code below):

```r
gbm_model <- 
  xgboost(data = as.matrix(combined), 
          label = label, 
          max.depth = 4, 
          eta = 0.05, 
          min_child_weight=5, 
          subsample=0.5, 
          colsample_bytree=0.5,
          nrounds = 450, 
          objective = "binary:logistic")

```

Lastly, make predictions on the test set:

```r
Vars <- test %>% 
  dplyr::select(all_of(GBM_VARS)) 

numericVars <- which(sapply(Vars, is.numeric)) #index vector numeric variables
numericVarNames <- names(numericVars)
DFnumeric <- Vars[, names(Vars) %in% numericVarNames]
DFfactors <- Vars[, !(names(Vars) %in% numericVarNames)]
DFdummies <- DFfactors %>% mutate_all(as.factor) %>%
  mutate_all(as.numeric)
combined_test <- cbind(DFnumeric, DFdummies) #combining all (now numeric) predictors into one dataframe 

test$Transported = 
  ifelse(predict(gbm_model, 
                 as.matrix(combined_test)) > 0.5, 
         "True", "False")

```

The code below creates a csv that you can submit to Kaggle.

```r
write.csv(test %>% 
            select(PassengerId, Transported),
          "gradient_boosted_tree_preds.csv",
          row.names=FALSE)
```



