Spaceship Titanic
------------------------

Ultimately, we will make predictions in the Kaggle [Spaceship Titanic](https://www.kaggle.com/competitions/spaceship-titanic/overview) competition.  For today, however, we're simply going to explore the data while practicing creating and interpreting logistic regression models.

Please write your answers to the questions below on a sheet of paper.

## Data and Packages

```r
library(tidyverse)

train = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/spaceship-titanic/train.csv")

View(train)

```

You can learn about these variables [on Kaggle](https://www.kaggle.com/competitions/spaceship-titanic/data).

The variable that we are trying to predict is "Transported" which is "whether the passenger was transported to another dimension".

# Booleans and "mutate_at"

The transported column is supposed to be "Boolean" or "logical" meaning that it contains trues and falses... and it does, but R read these in as characters/text, so the first thing we should do is tell R that these are Boolean values.  

We want do the same thing to the columns named "Cryosleep" and "VIP" which also contain trues and falses.  Instead of mutating each column individually, we can use "mutate_at" and use the same function on all three columns as follows:


```r
train = 
train %>%
  mutate_at(c("Transported", "VIP", "CryoSleep"),
           as.logical)
```

# Factor Variables

It's also true that at least a couple of these variables are categorical/factor variables, namely "HomePlanet" and "Destination".  These columns are just text, these are categories that passengers below to.  We'll let R know that these are factors the same way:

```r
train = 
train %>%
  mutate_at(c("HomePlanet", "Destination"),
           as.factor)
```

"PassengerId" and "Cabin" are more complicated variables. They each contains multiple pieces of information unfortunately jammed into one column and we'll want to split these pieces of information into separate columns but we'll save that for another day.

# Right-skewed Numeric Variables

The columns called "RoomService" through "VRDeck" contain the "amount the passenger has billed at each of the Spaceship Titanic's many luxury amenities."  Let's take a look at the distribution of one of these variables using a histogram:

```r
train %>% 
  ggplot(aes(FoodCourt)) + 
  geom_histogram()
```

The distribution of money spent at the food court has a long right tail (we'd say it's "right skewed") with some passengers spending orders of magnitude more than the typical passenger.  That makes this variable difficult to use in a linear model (or a generalized linear model).  One solution is to create columns which contain the logarithm of the amount of money spent at each of these locations.  I'll actually compute the log of amount plus one to avoid take the log of zero.  We'll use "mutate_at" again but in this case I don't want to overwrite the existing variables but rather create new columns in addition to the existing ones.  We can do that as follows:

```r
train = 
train %>%
  mutate_at(vars(RoomService:VRDeck),
           list(log = ~log(.x + 1)))
```

You can see the new variables we created:

```r
View(train)
```

and we can look at the distributions:

```r
train %>% 
  ggplot(aes(RoomService_log)) + 
  geom_histogram()
```

or look at the distributions split by whether passengers were transported or not:

```r
train %>%
    ggplot(aes(RoomService_log)) +
    geom_histogram()+ facet_wrap(~Transported)
```

**Question 1**
Is there a relationship between amount spend on room service and being transported?

# Logistic Regression

## Room Service

Now, we're finally reading to build logistic regression models.

First let's build a logistic regression model to predict the log odds of being transported based on the log of amount spent on room service.  

```r
m = glm(Transported ~ 
  RoomService_log, 
  data=train, 
  family="binomial")

summary(m)

coef(m)

exp(coef(m))
```

**Question 2:** If the null hypothesis is that there's no relationship between amount spent on room service and the chance of being transported, is there enough evidence for you to feel confortable rejecting the null hypothesis?  Please explain.

**Question 3:**
Write an equation for the **log odds** of being transported (as a function of the log of room service).

**Question 4:**
Write an equation for the **odds** of being transported (as a function of the log of room service).

**Question 5:**
Please interpret the equation that you wrote for question #4.


## CryoSleep

**Question 6:**
Please build a logistic regression model to predict the log odds of being transported from "CryoSleep". 

**Question 7:**
Determine whether you can reject the null hypothesis of no relationship between being transported and "CryoSleep".

**Question 8:**
Please write an equation for the **odds** of being transported as a function of CryoSleep and interpret this equation.

# Explore!

If you have time please explore which other variables may help you predict Transported.

