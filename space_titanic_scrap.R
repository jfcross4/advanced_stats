library(tidyverse)

train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/train.csv")

test = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/test.csv")

test$Transported = NA

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
        ifelse(Name=="", 1, 0)
        
    )
}


train = cleanship(train)

test = cleanship(test)

sampled_rows = sample.int(nrow(train), 
                          round(nrow(train)/2))

model_set = train[sampled_rows, ]
test_set = train[-sampled_rows, ]

RMSE = function(x,y){sqrt(mean((x-y)^2))}
MAE = function(x,y){mean(abs(x-y))}

library(rpart)
library(rpart.plot)

mytree <- rpart(
  Transported ~     
    HomePlanet + 
    deck + 
    side + 
    Destination + 
    Age + 
    VIP + 
    FoodCourt + 
    ShoppingMall + 
    Spa + 
    VRDeck, 
  data = model_set, 
  method = "anova",
  maxdepth=4,
  cp = 0.0001
)

test_set$tree_preds =
  predict(mytree,
          newdata = test_set)
library(randomForest)

mForest <- randomForest(Transported ~     
                          HomePlanet + 
                          deck + 
                          side + 
                          Destination + 
                          Age + 
                          VIP + 
                          FoodCourt + 
                          ShoppingMall + 
                          Spa + 
                          VRDeck +
                          tot_exp +
                          name_missing, 
                        data = model_set,
                        ntree=100, 
                        mtry=4,
                        na.action = na.omit)


test_set$forest_preds2 =
  predict(mForest,
          newdata = test_set, 
          type="response")

test_set = 
  test_set %>%
  mutate(
    forest_preds2 = 
      ifelse(is.na(forest_preds2), tree_preds, forest_preds2)
  )

test_set %>%
  summarize(
    RMSE(tree_preds, Transported),
    #RMSE(forest_preds, Transported),
    RMSE(forest_preds2, Transported)
  )

###
library(xgboost)

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
            "num"
             
)

Vars <- train %>% 
  dplyr::select(all_of(GBM_VARS)) 

numericVars <- which(sapply(Vars, is.numeric)) #index vector numeric variables
numericVarNames <- names(numericVars)
DFnumeric <- Vars[, names(Vars) %in% numericVarNames]
DFfactors <- Vars[, !(names(Vars) %in% numericVarNames)]
DFdummies <- DFfactors %>% mutate_all(as.factor) %>%
  mutate_all(as.numeric)
combined <- cbind(DFnumeric, DFdummies) #combining all (now numeric) predictors into one dataframe 

###

params <- list(booster = "gbtree", 
               objective = "binary:logistic", 
               eta=0.05, gamma=0, 
               max_depth=4, 
               min_child_weight=5, 
               subsample=0.5, colsample_bytree=0.5
               )

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


##### when you're done
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

write.csv(test %>% 
            select(PassengerId, Transported),
          "gradient_boosted_tree_preds.csv",
          row.names=FALSE)
