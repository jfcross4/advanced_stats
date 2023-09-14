02 Titanic Day One 
================
Advanced Statistics

In this lab, we'll work on finding the best way to predict who lived and who died on the Titanic according to RMSE and MAE.

First, let's read in the data:

```r
titanic <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")
```

and take a look...

```r
View(titanic)
```

Here's an explanation of the data:

![](titanicdesc.png)

Let's load one of our favorite packages...

```r
library(tidverse)
```
... and add a couple of functions for evaluating predictions which we used when analyzing box office gross predictions.

```r
MAE <- function(x,y){mean(abs(x-y))}
RMSE <- function(x, y){sqrt(mean((x-y)^2))}
```

To test our metrics, let's start with a dismal prediction.  I'll predict that everyone on the Titanic dies.  To make this prediction, I'll use the **mutate** function.  Notice that I'm starting this code with "titanic = ..." in order to overwrite the titanic data frame with a new one that includes our predictions.

```r
titanic = titanic %>% 
  mutate(pred = 0)
```

We can see use the RMSE and MAE functions within the summarize function to evaluate these dismal predictions.

```r
titanic %>% 
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))
```

Is it possible to make better predictions?  (Yes.)  It might help to look at a summary of the data.

```r
titanic %>% 
  summarize(n=n(),
            sum(Survived),
            mean(Survived))
```

In this sample of data (which, by the way, doesn't include everyone who was on the Titanic) there are 891 passengers of whom 342 or 38.4% survived.  

Let's predict that everyone has a 38.4% chance of Survival and see how that effects our MAE and RMSE...

```r
titanic %>% 
    mutate(pred = 0.384) %>%
    summarize(mae = MAE(pred, Survived),
              rmse = RMSE(pred, Survived))
```
Did one or both of MAE and RMSE improve?

Can we do better still?  Let's split the data into groups and look at survival rates by group.  To do this, we'll use the "group_by" function.

```r
titanic %>% 
      group_by(Sex) %>%
      summarize(n=n(),
                mean(Survived))
```
In this sample, 74.2% of women survived and 18.9% of men.  We could use the **ifelse** function to make our predictions reflect this split.  If *Sex=="female"* we'll predict a 74.2% of survival, otherwise ("else") we'll predict an 18.9% chance of survival.

```r
titanic %>% 
    mutate(pred = ifelse(Sex=="female", 
                          0.742, 
                          0.189)) %>%
    summarize(mae = MAE(pred, Survived),
              rmse = RMSE(pred, Survived))
```
Did this improve our projections?  What about using age?  Let's split the data based on whether passengers are 18 years old or older.

```r
titanic %>% 
      group_by(Age >= 18) %>%
      summarize(n=n(),
                mean(Survived))
```
This actually splits the data into 3 groups because some passenger's ages are missing (or *NA*).  If we want to split the data into more than 2 groups we might want to use the **case_when** function rather than the **ifelse** function.  For instance, based on our last data summary, let's predict that kids have a 54.0% chance of survival, known adults have a 38.1% chance of survival and people with a missing age have a 29.4% chance of survival:

```r
titanic %>% 
    mutate(pred = case_when(
              Age < 18 ~ 0.540,
              Age >= 18 ~ 0.381,
              is.na(Age) ~ 0.294
    )) %>%
    summarize(mae = MAE(pred, Survived),
              rmse = RMSE(pred, Survived))
```

We can also use a combination of variables to help improve our predictions.  Were women and children given the best chance to make it into life boats?  Let's try making a "women and children" variable. (Note: the code below effectively assumes that people with unknown ages aren't children.)

```r
titanic = titanic %>% 
  mutate(woman_or_child = 
           ifelse((Age >= 18 | is.na(Age)) & 
                        Sex =="male",
                  0,
                  1))
```

Now, we can see how the survival rate depends on being in this group:

```r
titanic %>% 
  group_by(woman_or_child) %>%
  summarize(n=n(), 
            mean(Survived))

```

Since, 68.8 % of the women and children in this sample survived and only 16.6% of others survied, we'll use that to make predictions:

```r
titanic %>% 
  mutate(pred = 
           ifelse(woman_or_child == 1,
                  0.688,
                  0.166)) %>%
  summarize(mae = MAE(pred, Survived),
            rmse = RMSE(pred, Survived))
```

# Challenge 1: 

Devise a system for making "Survived" predicitons with the goal of minimizing RMSE.  You can use any of the following variables: *Sex*, *Age*, *Pclass*, *SibSp*, *Parch*, *Fare*, *Embarked*.  (In other words, for now, you may not use Name, Ticket and Cabin.)

# Challenge 2: 

Devise the system for making the "Survived" predictions that minimizes MAE (with the same restriction on which variables you use).

# Question: 

What have you learned about the difference between predicting RMSE and predicting MAE?

**Please save your code!  You will be asked to describe your methods and your results.**
