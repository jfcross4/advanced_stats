Random Forests of School Census Lab
--------------------------------------

Today we'll build random forest models to how many hours kids sleep on school nights.  Let's see if these models are more accurate than our decision trees and linear models!

Open up your *school_census* project on rstudio cloud


First let's load the packages and code we'll need:

```r
library(tidyverse)
library(randomForest)
library(caret)
library(mice)
source("clean_census.R")
```

Next, read in the school census training set and test set data.
```r
train = read.csv("all_states_all_grades_all_years_sample500.csv")
test_no_sleep = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/census_sleep_test_set.csv")
```
To save coding time, we'll combine the training in test sets into one data frame so that we can sleep them in one fell swoop.  Then we can separate them out when we need to.  This has a second benefit in that it will ensure that each feature is coded the same way in the training and test set which is necessary for our random forest models to make predictions on the test set.


In order to bind two data frames together one on top of the other they need to have all the same columns in the same order.  In this case, we'll need to add a "prediction_number" column to the training set.  It doesn't matter what the values are, so I'll make them all zeroes.

```r
all = rbind(train %>% mutate(prediction_number=0), 
            test_no_sleep)

all_clean = clean_census(all)
all_clean[all_clean ==""] = NA #replacing blanks with NA

```

# Mice!

MICE stands for "Multivariate Imputation by Chained Equations". We'll use it to replace all of the missing/NA values.  There are numerous ways to do this, but the code we'll use will go through the columns one at a time and fill in values in place of every NA but predicting what the value would be based on all of the other columns.  It will use decision trees (classification and regression trees, known as "cart") to make these predictions:

```r
imputed_data <-  mice(all_clean, method="cart", maxit=1, m=1)
full_data <- complete(imputed_data) 
```

Now we can split the data back into training and test sets.  Let's take a look at the test set!

```r
train = full_data[1:500, ]
test = full_data[-c(1:500),]
summary(test) #notice sleep hours school night
```

Notice that the "Sleep_Hours_Schoolnight" columns is full (not NA) in the test set.  These aren't reel values!  These were completed by our "mice" process above.  We could view these as a set of predictions... but they're probably not very good predictions!  We can do better.

# Random Forest

Let's make 200 imperfect decision trees (or one random forest)!  I'm choosing 200 only because it seems like, hopefully, enough that funky individual decision trees will get averaged out and it's not so many that it will take our computers a long time to make them.  Our training set (assigned to x) will be the full "train" data frame with the "Sleep_Hours_Schoolnight" and "prediction_number" columns removed.  The y variable is what we're trying to predict and that's "Sleep_Hours_Schoolnight". The other thing you'll see in the code is "mtry = 19".  This means that every time our decision trees are making a new branch, they'll *randomly* consider only 19 features out of the 59 columns in the training data. 

```r
mForest <- randomForest(x=train %>% 
                        dplyr::select(-Sleep_Hours_Schoolnight, 
                                      -prediction_number), 
                        y=train$Sleep_Hours_Schoolnight, 
                        ntree=200, mtry=19)
```

What does this model look like?  That's really hard to say!  We could go through each of the 200 decision trees one at a time (although there's no each way to do this) or we can look at what variables were used more often when making our trees.  The following plots the most important variables:

```r
varImpPlot(mForest)
```

Strangely, or not so strangely, this reports that "Region" is the most important variable.  I'm deeply suspicious of this!  Region is the stats in which the student lives.  46 states are represented by at least one student in the training set.  That means that region gives our decision trees *many* possible ways to split states into two groups!  Just by chances one of these splittings may have a strong association with Sleep_Hours_Schoolnight!   Region may often provide a way to split the data that appears to be fruitful in sample even if Region and sleep have no *true* relationship that we could reasonable expect to be present in the test set.  This, I think, reveals one draw back of decision trees and random forest -- they don't deal well with factor/categorical variables with many levels (many possible values).
If we think that where someone lives in the country is important we could do some feature engineering and replace Region with a new variable with only several larger regions ("Northeast", "South", "Midwest"...) or we could replace it with one or more numeric variables (latitude and longitude, for instance).

Instead, I'm going to be very lazy here simply remove every categorical variable from the training data (a number of the other categorical variables have a dozen or so possible values and appeared to be inexplicably important in the random forest we made).  Here's a random forest model using only numeric variables (notice the "select_if" clause added in):

```r
mForest_numeric_only <- randomForest(x=train %>% 
             select(-Sleep_Hours_Schoolnight, -prediction_number) %>%
                          select_if(is.numeric), 
                        y=train$Sleep_Hours_Schoolnight, 
                        ntree=200, mtry=19)
```

Now, let's look at this numeric variables are the most important:

```r
varImpPlot(mForest_numeric_only)
```

I also want to look at the standard deviation in the predictions made by a random forest using all variables and a random forest made using only numeric variables.

```r
sd(predict(mForest))
sd(predict(mForest_numeric_only))
```

The numeric variable forest ends up with more varies sleep predictions (a larger standard deviation).  Which forest do you think makes better predictions?

# Making Predicitons using a Random Forest
 
We can make predictions and write them to a .csv file just as we did with our decision trees.  Feel free to replace "mForest" in the code below with "mForest_numeric_only" if you think that the forest made using only numeric variables made better predictions.
 
```r
test$preds = predict(mForest, newdata=test)

write.csv(test %>% 
            dplyr::select(preds, prediction_number),
          file="jareds_random_forest_predictions.csv", row.names=FALSE)

```

# Cross Validation

We can use cross validation to see how well our models do out-of-sample using only the training set.  This will allow us to make better predictions for test set.

The trick is to split the training data into "folds".  We'll use 5 folds but someone might reasonable use 10 or 20 (more folds is better but it makes more computation time and there are diminishing returns).  Each of our five folds will have 1/5th of the training data.  We'll use the other 4/5th of the data to make prediction on that fifth and that do the same for every fold.  All of our predictions will be out-of-sample with the only downside that all of our predictions are only based on 80% of the training data.  

The cool thing about cross validation is that we can vary one of the parameters of the model and see which value makes the best out-of-sample predictions.  Here we'll vary "mtry", the number of variables that are randomly selected for consideration each time our tree makes a new branch.  We'll try "mtry" values of 6, 9, 12, 15, 18, 21, 24, 27 and 30 and which works best.  The "caret" package will cycles through these values as well as through our 5 folds for us.  The code is as follows.

First, setting up the number of folds and the values of mtry to consider:

```r
my_control <- 
  trainControl(method="cv", number=5, verboseIter = TRUE)

random_forest_grid = expand.grid(
  mtry = seq(6, 30, 3)
)
```

And then making all of the random forests!  We'll end up making 40 random forest, each with 200 trees so 8000 decision trees all told so this might take a minute or two.

```r
rf_caret <- train(x=train %>% 
                    select(-Sleep_Hours_Schoolnight, -prediction_number), 
                  y=train$Sleep_Hours_Schoolnight, 
                  method='rf', 
                  trControl= my_control, 
                  tuneGrid=random_forest_grid,
                  ntree=200) 

```

Try each of these lines of code for a different look at which value of mtry made the best out-of-sample predictions.

```r
plot(rf_caret)
rf_caret$results
rf_caret$bestTune
```

Now, let's try this all again with random forest that only use numeric variables.  You can see whether these forest are more or less accurate out of sample!

```r
rf_caret <- train(x=train %>% 
              select(-Sleep_Hours_Schoolnight, -prediction_number) %>%
                    select_if(is.numeric), 
                  y=train$Sleep_Hours_Schoolnight, 
                  method='rf', 
                  trControl= my_control, 
                  tuneGrid=random_forest_grid,
                  ntree=200) 
                  
plot(rf_caret)
```

Based on the results about are we better off with or without the categorical variables?  What is the best value of mtry?

# Another Prediction Contest

Using what you've learned and pieces of the code above, try to make the best predictions of Sleep_Hours_Schoolnight for the test set.  Then write these values to a .csv file and send them to me.  Once again, R stickers are at stake!

Will these predictions be better than your last set of predictions?  

Will they be well calibrated?
