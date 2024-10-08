Spaceship Titanic (Day 2, Simple Decision Trees)
------------------------
[Spaceship Titanic](https://www.kaggle.com/competitions/spaceship-titanic/overview)

Please write your answers to the questions below on a sheet of paper.

## Data and Packages

This time, let's load both the test set and the training set:

```r
library(tidyverse)

train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/train.csv")

test = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/test.csv")
  
test$Transported = NA

```

# Data Clean-up Function

Let's start by doing all the data cleanup and column creation that we did in last week's lab (this time in one fell swoop), but let's build a function to do it.  We can later run this function on both the training set and the test set.

Here's an example of a function that would make all of the same manipulations we made in the first spaceship lab.

```r
cleanship = function(df){
df %>%
  mutate_at(c("Transported", 
        "VIP", 
        "CryoSleep"),
           as.logical) %>%
  mutate_at(c("HomePlanet",  
            "Destination"),
           as.factor) %>%
  mutate_at(vars(RoomService:VRDeck),
           list(log = ~log(.x + 1)))
}

```

# Other Variables

We mentioned last time that "PassengerId" and "Cabin" are more complicated variables. They each contains multiple pieces of information jammed into one column.  Let's split them up!  Let's also split names of passengers into first and last names.  Passengers with the same last name might be family members and this might carry information that helps us make predictions.  We'll use the "separate" function to do this for us.  We'll specify which character we want to split a column by and the names of the new columns it will be split into.  We'll add this to our "cleanship function":



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

Now let's run "cleanship" on both the training and test sets (you can ignore the warning messages):

```r
train = cleanship(train)

test = cleanship(test)

```

# Decision Trees

Way back at the beginning of the year [we used decision trees to predict who survived the Titanic](https://github.com/jfcross4/advanced_stats/blob/master/titanic_day_two.md).  We can use them now to predict who was transported on the Spaceship Titanic!

```r
library(rpart)
library(rpart.plot)

```

Let's allow our decision trees to use all of the variables but to only make a simple tree (with at most three levels) and see which variables it chooses to use.

```r
mytree <- rpart(
    Transported ~     
        HomePlanet + 
        CryoSleep + 
        deck + 
        side + 
        Destination + 
        Age + 
        VIP + 
        RoomService + 
        FoodCourt + 
        ShoppingMall + 
        Spa + 
        VRDeck, 
    data = train, 
    method = "anova",
    maxdepth=3
)

rpart.plot(mytree)

```

Take some time to make sure that you understand this decision tree plot.  Each node has both a proportion and a percentage.  What do they mean?

# Making Predictions on the Test Set

The following line of code will take the simple decision tree and make a prediction for every passenger in the test set, by finding the branch that they fall on.    

```r
predict(mytree, newdata=test) 
```
After running these code below, summarizing the results on the test set, look back at the plot of your decision tree, to help make sense of these predictions.  I've rounded the predicted probabilities of being transported to the 2 digits to make them easier to look at.

```r
table(round(predict(mytree, newdata=test),2)) 
```

For Kaggle, we simply need to predict "True" or "False" for whether every passenger was transported.  Kaggle will grade us based on the proportion of our predictions that are correct.  So, let's predict "True" for everyone who has a greater than 0.5 chance of being transported and "False" for everyone else.

```r
test$Transported = 
ifelse(predict(mytree, newdata=test) > 0.5, "True", "False")
```
How many of these predictions can we expect for be correct?  Well, if our predictions are well calibrated, when we predict that someone has a 66% chance of being transported, they really do have a 66% chance of being transported.  Therefore, if we estimate a 66% chance of being transported our True/False prediction has a 66% of being correct.  If we estimate a 16% chance of being transported, we'll predict "False" and we have an 84% chance of being correct. How often should we be correct overall?  We can estimate that with the following code:

```r
x = predict(mytree, newdata=test) 
mean(ifelse(x>0.5, x, 1-x))
```
This tells us that if our probability predictions are well-calibrated, our true/false predictions should be correct about 73% of the time.

Let's write our predictions to a .csv file, submit them to Kaggle and see if that holds true!

```r
write.csv(test %>% 
  select(PassengerId, Transported),
  "my_simple_tree_preds.csv",
  row.names=FALSE)
```

You can submit this file to Kaggle. Were our predictions well calibrated?  How did you do?  What would have to be true in order for our predictions to do better?

The current top score on Kaggle appears to be invalid and my guess is that the best we could possible do is to make correct predictions for ~82% of passengers.  By making different trees (perhaps more complex trees) can you get closer to 82%?  Try making different trees to see how well you can do.  I also recommend checking whether these predictions are well calibrated.  (Note: you may want to up the complexity of your trees incrementally because making more complex trees will take more time.)
