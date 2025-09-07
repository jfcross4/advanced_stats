Titanic Lab 3: Kaggle!
-------------------------------------

Please return to your rstudio.cloud titanic project.

# Kaggle

Kaggle is a website where data scientists make predictions and win prizes.  The data we've been using on the Titanic was taken from a Kaggle competition where folks predicted who survived the Titanic.  

It's finally time for us to compete against other stats whizzes.  Let's start by going to <a href="https://www.kaggle.com/" target="_blank">Kaggle</a> and creating an account.  You can register with Google.

Next, go to "Competitions" and enter the Titanic Competition (by selecting "Join Competition".

Kaggle provides two data sets.  One is the "training" set with 891 passengers along with their characteristics and whether they lived or died.  This is the data set we've been using and is intended for "training" (or building) your models.  The other data set is the test set.  This data set has passengers and their characteristics but does not include whether they lived or died.  You are supposed to making (out-of-sample) predictions on this data set and submit them to Kaggle and see how your predictions did relative to other competitors.

# Getting the Data and Loading Packages

Now let's go back to our rstudio.cloud project and grab the data so that we can make winning predictions.  This time, we'll read in both the training data and the test data (and give them different names).

```r
titanic_train <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

titanic_test <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_test.csv")

library(tidyverse)
library(rpart)
library(rpart.plot)
```

# Building a Model Using the Training Set

When building your model you should use "titanic_train" as your data set.  You can use your results from yesterday to choose appropriate "max_depth" and "cp" values.  Remember, you want the best out-of-sample predictions!  The code should look something like the following with, of course, your choices for max_depth and cp.

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic_train, 
  method = "anova", #for minimizing RMSE*
  maxdepth=2,
  cp = 0.01
)
```

# Making Predictions on the Test Set

Just like in our previous lab, we want to use this model to make out of sample predictions.  Today we want to make predictions using the test set and, for our Kaggle submission, we need to assign them to a variable named "Survived".  

There's one more twist!  Kaggle, is expecting your predictions to be a series of 0's and 1's and is going to grade you on accuracy. As we saw the other day, this is equivalent to grading you based on Mean Absolute Error (MAE).  We can adjust for this by simply rounding our prediction either down to 0 or up to 1 depending on whether our model believes that someone was more likely to die or survive.  The following code will do the trick:

```r
titanic_test$Survived = round(predict(mytree, 
                        newdata=titanic_test))
```

# Submitting Data to Kaggle

Kaggle wants a file with only passenger ID's and our predicted values for "Survived" so we should now make a data frame with only those values:

```r
my_submission = titanic_test %>% 
  select(PassengerId, Survived)
```

Kaggle also wants us to upload a .csv (comma separated values) file, so we'll need to write our predictions to a .csv as follows:

```r
write.csv(my_submission, 
          file="titanic_predictions.csv",
          row.names = FALSE)
```

Lastly, go back to the Titanic competition within Kaggle and click on "Submit Predictions".  Then you can upload this .csv file.

How did you do?!?!  Please keep in mind that: 

1) There are almost 14,000 competitors
2) Some of them are simply cheating by looking up who lived and who dies (anyone with a score of 1.0000 is cheating).
3) We've barely scratched the surface of techniques we can use to make good predictions.

If you have time, try tweaking the parameters that you used when creating the decision tree and then, make a new tree, make new predictions on the test set, create a new .csv file and submit this new file to Kaggle.  Were you able to do better?