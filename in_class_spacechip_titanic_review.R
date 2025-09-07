library(tidyverse)
library(rpart)
library(rpart.plot)


train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/train.csv")


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
             extra = "drop")
}

train = cleanship(train)


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
  data = train, 
  method = "anova",
  maxdepth=3,
  cp = 0.001
)

rpart.plot(mytree)

m_logistic = 
  glm(
  Transported ~     
    HomePlanet + 
    deck + 
    side + 
    Destination + 
    Age + 
    VIP + 
    FoodCourt_log + 
    ShoppingMall_log + 
    Spa_log + 
    VRDeck_log, 
  data = train,
  family="binomial"
)

summary(m_logistic)


sampled_rows = sample.int(nrow(train), 
           round(nrow(train)/2))

model_set = train[sampled_rows, ]
test_set = train[-sampled_rows, ]


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

m_logistic = 
  glm(
    Transported ~     
      HomePlanet + 
      side + 
      Destination + 
      Age + 
      VIP + 
      FoodCourt_log + 
      ShoppingMall_log + 
      Spa_log + 
      VRDeck_log, 
    data = model_set,
    family="binomial"
  )

predict(mytree,
        newdata = test_set)

predict(m_logistic,
        newdata = test_set)

predict(m_logistic,
        newdata = test_set, 
        type="response")

test_set$tree_preds =
  predict(mytree,
          newdata = test_set)

test_set$glm_preds =
  predict(m_logistic,
          newdata = test_set,
          type="response")

test_set = 
test_set %>%
  mutate(
    glm_preds = 
    ifelse(is.na(glm_preds), tree_preds, glm_preds)
  )

RMSE = function(x,y){sqrt(mean((x-y)^2))}
MAE = function(x,y){mean(abs(x-y))}

test_set %>%
  summarize(
    RMSE(glm_preds, Transported),
    RMSE(tree_preds, Transported)
  )

test_set %>%
  summarize(
    MAE(glm_preds, Transported),
    MAE(tree_preds, Transported)
  )


# stop here for random forests

library(randomForest)

mForest <- randomForest(Transported ~     
                          HomePlanet + 
                          deck + 
                          side + 
                          Destination + 
                          Age + 
                          VIP + 
                          FoodCourt_log + 
                          ShoppingMall_log + 
                          Spa_log + 
                          VRDeck_log, 
                        data = model_set,
                        ntree=500, 
                        mtry=4,
                        na.action = na.omit)


test_set$forest_preds =
predict(mForest,
        newdata = test_set, 
        type="response")

test_set = 
  test_set %>%
  mutate(
    forest_preds = 
      ifelse(is.na(forest_preds), tree_preds, forest_preds)
  )

test_set %>%
  summarize(
    RMSE(glm_preds, Transported),
    RMSE(tree_preds, Transported),
    RMSE(forest_preds, Transported)
  )

test_set %>%
  summarize(
    MAE(glm_preds, Transported),
    MAE(tree_preds, Transported),
    MAE(forest_preds, Transported),
  )
