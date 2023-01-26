Titanic Lab 4: Now with Multiple Regression
----------------------------------

Early in the year, we worked through three labs that involved using decision trees to predict which passengers would survive the sinking of the Titanic.  We even submitted out out-of-sample predictions on Kaggle.

Here are links to those labs if you'd like to take another look:

[Lab 1: Minimizing MAE and RMSE in sample](https://github.com/jfcross4/advanced_stats/blob/master/titanic_day_one.md)

[Lab 2: Decision Trees and Out of Sample Predictions](https://github.com/jfcross4/advanced_stats/blob/master/titanic_day_two.md)

[Lab 3: Submitting Prediction to Kaggle](https://github.com/jfcross4/advanced_stats/blob/master/titanic_day_three_kaggle.md)

In this lab, we're going to make predictions using multiple regression and see how their out-of-sample accuracy compares to the decision trees and, hopefully, in the process learn something about the advantages of each type of model.

# The Data and Packages

First, let's grab the data and load the relevant libraries.  Notice (or possibly recall?) that we're really loading two data sets.  The "training set" has passengers whose survival status is known.  We'll use this set to build our model.  The "test set" does not include the passengers survival status.  We'll use this set to make our out-of-sample predictions.

```r
titanic_train <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

titanic_test <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_test.csv")

library(dplyr)
library(rpart)
library(rpart.plot)
library(ggplot2)
```

## Building Models

Here is code we used to build a decision tree to predict "Survived" using Sex, Age, Pclass and Fare.

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic_train, 
  method = "anova", #for minimizing RMSE*
  maxdepth=2,
  cp = 0.01
)
```

Notice the similarities in the code to build a linear (multiple regression) model:

```r
my_linear_model =
  lm(Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic_train)

```

We can use the example same code we used before to make out-of-sample predictions on our test set.

```r
titanic_test$Survived = round(predict(my_linear_model, 
                        newdata=titanic_test))
```

... but there's a problem!

```r
summary(titanic_test$Survived)
```

87 of the predictions are NA!  This is because some passengers ages and missing and in one case a passenger's fare is missing.  Our decision trees had no trouble with this and simple considered NA another possible age.  Our linear models can't handle it!

We'll try to work around this by making up the ages of passengers who ages are missing.  We can do this building a model to predict ages from the other predictor variables:

```r
my_age_model =
  lm(Age ~ Sex + Pclass + SibSp, 
  data = titanic_train)
```

Let's see how our predicted ages compared with actual ages where ages aren't missing:

```r
titanic_train$predicted_age = 
predict(my_age_model, newdata=titanic_train)


ggplot(titanic_train, aes(predicted_age, Age))+geom_point()+
geom_smooth()
```

Our predicted ages leave something to be desired but since most passenger ages are known, this will do for now.  Let's add a new column to both the test and training sets called *Age2* that uses the passenger's actual age where available and our predicted age where there actual age is missing:

```r
titanic_train = 
titanic_train %>%
  mutate(Age2 = ifelse(is.na(Age), predicted_age, Age))

titanic_test$predicted_age = 
predict(my_age_model, newdata=titanic_test)

titanic_test = 
titanic_test %>%
  mutate(Age2 = ifelse(is.na(Age), predicted_age, Age))
```

Now, let's try the same thing with passenger fares.

```r
my_fare_model =
  lm(Fare ~ Sex + Pclass + Age2 + SibSp + Parch, 
  data = titanic_train)
  
titanic_train$predicted_fare = 
predict(my_fare_model, newdata=titanic_train)

ggplot(titanic_train, aes(predicted_fare, Fare))+geom_point()+geom_smooth()

```

There's room to to better here but since only one passenger's fare is missing, let's keep moving.  We'll make a variable care Fare2 using the same logic as Age2.

```r


titanic_train = 
titanic_train %>%
  mutate(Fare2 = ifelse(is.na(Fare), predicted_fare, Fare))

titanic_test$predicted_fare = 
predict(my_fare_model, newdata=titanic_test)

titanic_test = 
titanic_test %>%
  mutate(Fare2= ifelse(is.na(Fare), predicted_fare, Fare))
```

Now, we're finally ready to make a linear model to predict Survived!

```r
my_linear_model =
  lm(Survived ~ Sex + Age2 + Pclass + Fare2, 
  data = titanic_train)
  
summary(my_linear_model)
```

How did we do?  Should some variables be dropped from the model?  Please model your model as you see fit and then, when you're ready, use it to make predictions to the test set:

```r
titanic_test$Survived = round(predict(my_linear_model, 
                        newdata=titanic_test))

```

You can use this predictions to make a .csv file which you can submit Kaggle:

```r
my_linear_submission = titanic_test %>% 
  select(PassengerId, Survived)
  
write.csv(my_linear_submission, 
          file="titanic_lm_predictions.csv",
          row.names = FALSE)
```

# Back to Kaggle

Lastly, go back to the Titanic competition within Kaggle and click on "Submit Predictions". Then you can upload this .csv file.

Did these predictions do better or worse than your decision tree predictions?  What advantages and disadvantages do each type of model have?  Are there ways we could improve these models or use them in combination?  Please write down a few ideas to share with the class when we discuss our models.
