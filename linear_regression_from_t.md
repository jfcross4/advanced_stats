Linear Regression (like t tests but better)
------------------------------------

# Getting the Data

```r
library(datarium)
library(tidyverse)
library(openintro)
```

# 1. Surviving the Titanic

```r
data("titanic.raw", package = "datarium")

View(titanic.raw)
```
"titanic.raw" has data on 2201 passengers on the Titanic.  It has their ticket class, sex, age and whether they survived.  Which characteristics were good predictors of who lived and died on the titanic?  We can build models (that, you'll see) have much in common with t tests, to find out.  First, to make it easier to work with, we'll turn the survived "yes"/"no" column into a TRUE/FALSE column which mathematically will act as 1's and 0's:

```r
titanic.raw <- titanic.raw %>% mutate(SurvivedTF = Survived=="Yes")
```

Next, we'll build a model to predict survival from age:

```r
lm(SurvivedTF ~ Age, data=titanic.raw)
```

This simple model tells give us an equation to predict changes of survival:

$Survived = 0.523 - 0.210 \cdot Adult$

Or, in other words, children had a 52.3% chance of survival and adults had 
a $0.523 - 0.210 = 31.3\%$ chance of survival.

We can get more information about the model as follows:

```r
m = lm(SurvivedTF ~ Age, data=titanic.raw)
summary(m)
```
This full summary gives us not only the equation we used to make predictions before, if also gives us the uncertainty (standard error) in these numbers.

The model summary shows that adults had a 21% lower chance of survival with a standard error of 4.6%.  It also gives us a t score!  The 21% reduction in survival was 4.6 standard errors away from zero.  After that, it gives us a two-tailed p-value.

We know how to generate this output by other means.  We would have to first split the data into adult and child vectors and then perform a t-test.  We could do that as follows and get the same t-score and p-values:


```r
adults = titanic.raw[titanic.raw$Age=="Adult",]$SurvivedTF
children = titanic.raw[titanic.raw$Age=="Child",]$SurvivedTF

t.test(adults, children, var.equal = TRUE)
```

We're just getting started, however.  These models can do far than our t-tests! 

Let's make a model to predict survival from ticket class.  Note that ticket class has 4 options: 1st, 2nd, 3rd and Crew.

```r
m = lm(SurvivedTF ~ Class, data=titanic.raw)
summary(m)
```

Our model chooses one of the options (in this case 1st class) as the default.  Then it effectively performs three t-tests, comparing each of the other passenger classes to 1st class.  What can you say about the chances of surival for different passenger classes?

Better yet, we can combine predictors:

```r
m = lm(SurvivedTF ~ Class + Age, data=titanic.raw)
summary(m)

```

What prediction does this model make for the survival chances of an adult with a third class ticket?

Let's use all three predictors!

```r
m = lm(SurvivedTF ~ Class + Age + Sex, data=titanic.raw)
summary(m)

```

What does this model tell you?

We can also use interactions between predictors.  Try to figure out how the following model differs from the last one:

```r
m = lm(SurvivedTF ~ Class + Age*Sex, data=titanic.raw)
summary(m)
```

Please write down a couple of notes about what this model says about surviving the titanic.

(Question: Does this model make an impossible prediction?!?  What is it?)


# 2. Why do some mammals sleep more than others?

```r
data("mammals", package = "openintro")
View(mammals)
```


Our goal is to predict total_sleep from some combination of life_span, gestation, predation, exposure, danger, body_wt and brain_wt (it would be cheating to use “non_dreaming” and “dreaming” sleep because these are amounts of two types of sleep).

You should start by reading a description of the data: [Mammals Description]("https://www.openintro.org/data/index.php?data=mammals")

Then let’s start building our model by predicting total_sleep from predation.

```r
colnames(mammals)
m <- lm(total_sleep ~ predation, data=mammals)
summary(m)
```

This gives us the following equation:

$sleep = 14.1 - 1.27 \cdot predation$

This means that if an animal experiences a predation level of 1 we predict about 12.9 hours of sleep but if they are subject to a predation level of 5, we predict only 7.8 hours of sleep.

Is this relationship likely to be due to chance?  Take a look at the model summary before answering.

We might also be interested in using mammals’s brain weights to predict sleep. There’s a bit of a problem with this, however, which is that the animals that are big (and big-brained) are orders of magnitude bigger than the smaller animals and the differences between smaller animals are irrelevant by comparison. We can see this in a histogram of brain weights and in a plot of sleep versus brain weight.

```r
mammals %>% 
  ggplot(aes(brain_wt)) + 
  geom_histogram()
```

... and in a scatter plot of sleep versus brain weight:

```r
mammals %>% 
  ggplot(aes(brain_wt, total_sleep)) + 
  geom_point()+
  geom_smooth(method="lm", color="red")
```
We can address this issue by creating a new variable which is the logarithm of brain weight. 
We are creating a new variable, log_brain_wt, such that:

$$10^{log_{10}(brain\ wt)}=brain\ wt$$

so that if log_brain_wt is 2, then brain_wt must be $10^2$
 or 100 grams (the information page says that these brain weights are in kilograms but that’s ridiculous, these numbers must be grams).

```r
mammals <- mammals %>% 
  mutate(log_brain_wt = log(brain_wt, base=10))
```
Now, let's create those graphs again with log brain weight:


```r
mammals %>% ggplot(aes(log_brain_wt))+geom_histogram()
```


```r
mammals %>% 
ggplot(aes(log_brain_wt, total_sleep)) + 
  geom_point()+
  geom_smooth(method="lm", color="red")
```

```r
mammals %>% 
  ggplot(aes(log_brain_wt, total_sleep, label=species)) + 
  geom_label()+
  geom_smooth(method="lm", color="red")
```

Now, we can add log_brain_wt to our prediction model:

```r
m <- lm(total_sleep ~ log_brain_wt + predation, data=mammals)

summary(m)
```

# Challenge 
Are any other variables important?  What are they?  Let the t values be your guide and try to build the best model you can.
