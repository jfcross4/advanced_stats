02 Titanic Lab 2: Decisions Trees
-------------------------------------

Please return to your rstudio.cloud titanic project.

# Getting the Data and Loading Packages

For today's code you'll need to install the *rpart* and *rpart.plot* packages.

```r
titanic <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

library(tidyverse)
library(rpart)
library(rpart.plot)
```

# Recursive Partioning

*rpart* stands for recursive partitioning.  Partioning means splitting the data into non-overlapping groups.  Recursive means doing it over and over again (splitting these groups into subgroups).

R can search through one or more variables and, for each one, all the possible ways to split them into two branches and find the one that minimizes either RMSE or MAE.

For instance, there are many ways to split passengers into two groups based on age.  The following code will find the split that makes the two groups that are the most different in the rate of survival:

```r
mytree <- rpart(
  Survived ~ Age, 
  data = titanic, 
  method = "anova", #for minimizing RMSE*
  maxdepth=1
)

rpart.plot(mytree)
```
The tree that you printed out shows that we can reduce the RMSE of our predictions by the most by splitting Age at 6.5 years.  The branch to the left is where the question "Age >= 6.5" is answered in the affirmative.  93% of people in this data set are >= 6.5 years of age and only 39% of them survived.  Meanwhile 7% of passengers were < 6.5 years of age and 70% of them survived.  (Note: rpart is simply ignoring people whose Age is missing.) Make sure that you understand what this plot is showing before moving on.


# The "Women and Children First" Model

We can also give *rpart* two variables to choose from, Sex and Age.  rpart will look at all choices of how to split up passengers using either one these variables and find the one that would make the predictions that minimize RMSE.  Which variable do you think it will choose: Sex or Age?  First make a guess and then find out:

```r
mytree <- rpart(
  Survived ~ Age + Sex, 
  data = titanic, 
  method = "anova", #for minimizing RMSE*
  maxdepth=1
)

rpart.plot(mytree)

```

Recall that the “r” in rpart stands for recursive meaning that we can keep doing this partitioning.

After finding the best branching we can treat each branch as its own dataset and find the best branch within that branch! 

(And then we can keep doing this!)

The models we’re making are called **decision trees**.

Here's a decision tree with 2 layers (notice that in the code, the parameter "maxdepth" is set to 2):

```r
mytree <- rpart(
  Survived ~ Age + Sex, 
  data = titanic, 
  method = "anova", #for minimizing RMSE*
  maxdepth=2
)
rpart.plot(mytree)
```
*Questions:*

**1.** Based on this tree, what is the survival rate for males who are 6 years old or younger?

**2.** Based on this tree, what percentage of the passengers were female?

# Going Further

Let's give rpart more variables to use.  In the following code, we'll allow it to partitioning passengers using their Sex, Age, Pclass and Fare.  We'll also change maxdepth to 3 so that the decision tree can have up to 3 layers:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE*
  maxdepth=3
)

rpart.plot(mytree)
```

**3.** Based on this decision tree, describe the group that had the **highest** rate of survival.  Please include what % of passengers fit into this group and the overall rate of survival of this group.

**4.** Based on this decision tree, describe the group that has the **lowest** rate of survival.  Please include what % of passengers fit into this group and the overall rate of survival of this group.

## Making and Testing Predictions

We can use the predict function to make predictions using the more complicated tree that we just built. 
"titanic$prediction" is creating a new column in our titanic dataset with the predictions based on our decision tree.

```r
titanic$prediction = predict(mytree)
```

Now, let's evaluate these predictions the same way we did in our previous lab.

```r
MAE <- function(x,y){mean(abs(x-y))}
RMSE <- function(x, y){sqrt(mean((x-y)^2))}

titanic %>% 
  mutate(mae_prediction = round(prediction)) %>%
  summarize(mae = MAE(mae_prediction, Survived),
            rmse = RMSE(prediction, Survived))
```

Notice that we round our predictions to 0 or 1 to predict the median (best for MAE) value of Survived rather than the mean value of Survived (best for RMSE) for each group.

**5.** How do the RMSE and MAE of these predictions compare to the RMSE and MAE of the best predictions that you made without decision trees?  (It's okay if you don't remember.)

# Complexity Parameter

Let's try to build an enormous tree!  We'll set maxdepth to 5:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=5
)

rpart.plot(mytree)
```

Disappointed?  This tree still has only 3 levels.  That's because, by default, rpart will not add branches if adding those branches doesn't improve the predictions by more than 1%.  1% is the default "complexity parameter".  If we change the complexity parameter (cp) to 0, rpart has no restraint and will keep adding branches until it reaches the maxdepth (maximum number of levels) we chose.

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=5, cp=0 # this cp is a “complexity parameter”
)

rpart.plot(mytree)
```

**Task #1:** Try making and plotting decision trees with 4 and 7 layers.

**Task #2:** Find the RMSE and MAE for decision trees with 4 and 7 layers.  Which model has lower RMSE and MAE?  How will RMSE and MAE change as you add more and more layers?
