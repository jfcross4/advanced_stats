Spaceship Titanic (Day 3, Random Forests)
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

Here's the function we created in our last spaceship lab:

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
          extra = "drop")
}

```

and putting it to use:

```r
train = cleanship(train)

test = cleanship(test)

```

Now, let's split the data into training ("model_set") and test sets like we did in class and create the RMSE and MAE functions:

```r
sampled_rows = sample.int(nrow(train), 
           round(nrow(train)/2))

model_set = train[sampled_rows, ]
test_set = train[-sampled_rows, ]

RMSE = function(x,y){sqrt(mean((x-y)^2))}
MAE = function(x,y){mean(abs(x-y))}
```

Now, let's make a decision tree to predict Transported:

```r
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

```

and make predictions with the decision tree:

```r

test_set$tree_preds =
  predict(mytree,
          newdata = test_set)

```

Now, let's try a random forest (of decision trees):

```r
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
                        ntree=100, 
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
```

Let's see how these predictions performed out of sample:

```r
test_set %>%
  summarize(
    RMSE(tree_preds, Transported),
    RMSE(forest_preds, Transported)
  )

```

Try fiddling with the parameters of your models (maxdepth and cp for the decision tree and mtry for the random forest) and find values that make good predictions out-of-sample.

When you have those, you can make predictions to the *true* test set, the one you'll use to submit predictions to kaggle:

```r
test$tree_preds =
  predict(mytree,
          newdata = test)

test$forest_preds =
predict(mForest,
        newdata = test, 
        type="response")

test = 
  test %>%
  mutate(
    forest_preds = 
      ifelse(is.na(forest_preds), tree_preds, forest_preds)
  )
```

For Kaggle, we simply need to predict "True" or "False" for whether every passenger was transported.  Kaggle will grade us based on the proportion of our predictions that are correct.  So, let's predict "True" for everyone who has a greater than 0.5 chance of being transported and "False" for everyone else.

```r
test$Transported = 
ifelse(predict(mytree, newdata=test) > 0.5, "True", "False")
```

The code below creates a csv that you can submit to Kaggle.

```r
write.csv(test %>% 
  select(PassengerId, Transported),
  "random_forest_preds.csv",
  row.names=FALSE)
```



