02 Titanic Lab 2: Decisions Trees
-------------------------------------

Please return to your rstudio.cloud titanic project.

# Getting the Data and Loading Packages

```r
titanic <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")

library(dplyr)
library(rpart)
library(rpart.plot)

```
# Recursive Partioning

R can search through all of the variables and, for each one, all the possible ways to split them into two branches and find the one that minimizes either RMSE or MAE.

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE*
  maxdepth=1
)

rpart.plot(mytree)
```
The “r” in rpart stands for recursive meaning that we can see doing this partitioning.

After finding the best branching we can treat each branch as it’s one dataset and find the best brach within that branch! 

And then we can keep doing this!

The models we’re making are called **decision trees**.

Here's a decision tree with 2 layers:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=2, cp=0 # this cp is a “complexity parameter”
)

rpart.plot(mytree)
```
and one with 3 layers:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanic, 
  method = "anova", #for minimizing RMSE
  maxdepth=2, cp=0 # this cp is a “complexity parameter”
)

rpart.plot(mytree)
```

**Task #1:** Try making and plotting decision trees with 5 and 15 layers.

# Making Out-of-Sample Predictions

First we will split our titanic data into two roughly equally-sized sets.

```r
setA = sample(1:891, floor(891/2), replace=FALSE)

# set A is now a random sample of 445 integers between 1 and 891 without duplicates

# we can now take only these rows from the titanic data and make that titanic set A
titanicA = titanic[setA, ]

# and we can let all other rows be titanic set B
titanicB = titanic[-setA, ]
```

## The Plan: 
Build models (decision trees) using Titanic set A and then test their accuracy on Titanic set B.  This will tell us how well our models can make out-of-sample (**real**) predictions.

First, let's build a complex (15-layer) model using titanic set A (notice that we're using "titanicA" as our data and a maxdepth of 15):

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanicA, 
  method = "anova", #for minimizing RMSE
  maxdepth=15, cp=0
)

```
Then we can use this model (which we called "mytree") to make both in-sample (on titanic set A) and out-of-sample (on titanic set B) predictions:

```r
titanicA$pred = predict(mytree)
titanicB$pred = predict(mytree, newdata=titanicB) 
```

Lastly, let's look at the RMSE of these predictions on both set A and set B:

```r
titanicA %>% 
  summarize(rmse = RMSE(pred, Survived))

titanicB %>% 
  summarize(rmse = RMSE(pred, Survived))
```

**Question 1:** What are the RMSE's?  Are these predictions more accurate in-sample or out-of-sample?

Next, let's try the same thing but with a less complicated model.  We'll try just 5 layers:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanicA, 
  method = "anova", #for minimizing RMSE
  maxdepth=5, cp=0
)
```

Using your code above as a guide, first make predictions on both titanicA and titanicB using this new model.  Next, find the RMSE both in sample and out of sample.

**Question 2:** What are the in-sample and out-of-sample RMSE's of this simpler model?  How do they compare to the more complex model?

**Question 3:** Try making models with other numbers of layers.  What model performs the best in-sample?  What model performs the best out-of-sample?

# Try changing the the complexity parameter as follows:

The complexity parameter applies a punishment for making a more complex model.  The code below will stop (well) short of making 15 layers even though continuing to add layers would slightly reduce the in-sample RMSE:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanicA, 
  method = "anova", #for minimizing RMSE
  cp = 0.01, maxdepth = 15
)

rpart.plot(mytree)
```
The larger the cp value, the larger the punishment and thus the simpler the trees your code will produce.  The code below with a larger cp value will make a simple model:

```r
mytree <- rpart(
  Survived ~ Sex + Age + Pclass + Fare, 
  data = titanicA, 
  method = "anova", #for minimizing RMSE
  cp = 0.09, maxdepth = 15
)

rpart.plot(mytree)
```

The idea behind the cp value is that simpler model perform better out-of-sample.

**Question 4:** Try to find the cp value that produces the lowest out-of-sample RMSE.
