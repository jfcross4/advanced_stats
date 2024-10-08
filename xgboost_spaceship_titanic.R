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
             "VRDeck"
  
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



params <- list(booster = "gbtree", 
               objective = "binary:logistic", 
               eta=0.1, gamma=0, 
               max_depth=3, 
               min_child_weight=1, 
               subsample=1, colsample_bytree=1)

xgbcv <- xgb.cv( params = params, 
                 data = as.matrix(combined),
                 label = label,
                 nrounds = 300, 
                 nfold = 5, 
                 showsd = T, 
                 stratified = T, 
                 print.every.n = 10, 
                 early.stop.round = 20, 
                 maximize = F)
##best iteration = 79

bstSparse <- 
  xgboost(data = as.matrix(combined), 
          label = label, 
          max.depth = 3, 
          eta = 0.1, 
          min_child_weight=1, 
          subsample=1, 
          colsample_bytree=1,
          nrounds = 275, 
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

x = predict(bstSparse, as.matrix(combined_test))
mean(ifelse(x>0.5, x, 1-x))

test$first_pass = 
  predict(bstSparse, as.matrix(combined_test))

test$Transported = 
  ifelse(predict(bstSparse, as.matrix(combined_test)) > 0.5, "True", "False")

write.csv(test %>% 
            select(PassengerId, Transported),
          "xgboost_preds.csv",
          row.names=FALSE)

###

train$Transported_first_pass = 
  predict(bstSparse, 
              as.matrix(combined))

train = 
train %>%
  mutate(first_pass_miss = 
           Transported - Transported_first_pass)

##

wider_GBM_VARS = c("HomePlanet", 
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
             "Party",
             "PartyNr",
             "num",
             "LastN",
             "Transported_first_pass"
             
)


Vars <- train %>% 
  dplyr::select(all_of(wider_GBM_VARS)) 

numericVars <- which(sapply(Vars, is.numeric)) #index vector numeric variables
numericVarNames <- names(numericVars)
DFnumeric <- Vars[, names(Vars) %in% numericVarNames]
DFfactors <- Vars[, !(names(Vars) %in% numericVarNames)]
DFdummies <- DFfactors %>% mutate_all(as.factor) %>%
  mutate_all(as.numeric)
combined <- cbind(DFnumeric, DFdummies) #combining all (now numeric) predictors into one dataframe 

params <- list(booster = "gbtree", 
               eta=0.01, gamma=0, 
               max_depth=3, 
               min_child_weight=1, 
               subsample=1, colsample_bytree=1)

xgbcv <- xgb.cv( params = params, 
                 data = as.matrix(combined),
                 label = train$first_pass_miss,
                 nrounds = 3000, 
                 nfold = 5, 
                 showsd = T, 
                 stratified = T, 
                 print.every.n = 10, 
                 early.stop.round = 20, 
                 maximize = F)
# 414 out of sample
second_pass <- 
  xgboost(data = as.matrix(combined), 
          label = train$first_pass_miss, 
          max.depth = 3, 
          eta = 0.01, 
          min_child_weight=1, 
          subsample=1, 
          colsample_bytree=1,
          nrounds = 745)


test = 
test %>% rename(Transported_first_pass=first_pass)

Vars <- test %>% 
  dplyr::select(all_of(wider_GBM_VARS)) 

numericVars <- which(sapply(Vars, is.numeric)) #index vector numeric variables
numericVarNames <- names(numericVars)
DFnumeric <- Vars[, names(Vars) %in% numericVarNames]
DFfactors <- Vars[, !(names(Vars) %in% numericVarNames)]
DFdummies <- DFfactors %>% mutate_all(as.factor) %>%
  mutate_all(as.numeric)
combined_test <- cbind(DFnumeric, DFdummies) #combining all (now numeric) predictors into one dataframe 

#y = predict(second_pass, as.matrix(combined_test))+x
#mean(ifelse(x>0.5, x, 1-x))

test$second_pass = 
  predict(second_pass, as.matrix(combined_test))

summary(test)

test = 
test %>% 
  mutate(combined_pred = Transported_first_pass + second_pass)

test %>%
ggplot(aes(Transported_first_pass))+
  geom_histogram()

test %>%
  ggplot(aes(second_pass))+
  geom_histogram()

test %>%
  ggplot(aes(combined_pred))+
  geom_histogram()

y = test$combined_pred
mean(ifelse(y>0.5, y, 1-y))

x = test$first_pass
mean(ifelse(x>0.5, x, 1-x))

test$Transported = 
  ifelse(test$combined_pred > 0.5, 
         "True", "False")

write.csv(test %>% 
            select(PassengerId, Transported),
          "xgboost_two_layer_preds.csv",
          row.names=FALSE)

y = test$combined_pred
y = ifelse(y>1, 1, ifelse(y<0, 0, y))
mean(ifelse(y>0.5, y, 1-y))
