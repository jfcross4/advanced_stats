More Complex Models to Predict Election Winners
----------------------------------

Today we'll build more comples **Multiple Regression** models to predict Presidential Election vote shares.  In addition to the Hibbs data we used in our last lab, we'll use Ray Fair's data.

## The Data

You can find a description of Ray Fair's model and, most importantly for our purposes, a description of the meaning of his variables [here](https://pollyvote.com/en/components/models/retrospective/fundamentals-only-models/fair-model/).  It's worth taking a few minutes to read this.

Notable, while Hibbs' data is set up to predict the *imcumbent party's* vote share, Ray Fair's data is designed to predict the *Democratic party's* vote share.

You should start by taking a look at the two data sets:

```r
library(tidyverse)

file = "https://raw.githubusercontent.com/avehtari/ROS-Examples/master/ElectionsEconomy/data/hibbs.dat"
hibbs <- read.table(file, header=TRUE)


fair = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/fair.csv")

View(hibbs)
View(fair)

```

We can modify Ray Fair's data to predict the incumbent party vote share:


```r
fair = fair %>%
  mutate(incumbent_vote = 50 + I*(VP-50),
          incumbent_running_again = abs(DPER),
          length_party_control = abs(DUR))
```

And, if we want we can coin the Hibbs and Fair data.  The Hibbs data covers fewer elections and this join will include only elections included in the Hibbs data:

```r
fair_hibbs = left_join(hibbs, fair, by="year")
```

Let's compare models to predict the vote share using Hibbs's income growth (over a full presidential term) to Fair's income growth over only the first 9 months of the election year.

```r
m1 = lm(vote ~ growth, data=fair_hibbs)

m2  = lm(vote ~ G, data = fair_hibbs)

summary(m1)
summary(m2)
```

**Question 1:** Which appears to be a better predictor of the vote share?

## Multiple Regression

Instead of trying to predict the two-party vote share using only one variable, we can try to predict it using two variables.  Geometrically, one variable regression looked like finding a best-fit line to points on a plane.  Two variable regression is try to find a best-fit plane for points in three dimension (which is much hard to picture!).

```r
m3 = lm(vote ~ growth + length_party_control, data=fair_hibbs)

summary(m3)
```

In this case, the multiple regression model comes up with the following equation for the best fit plane:

$$vote = 49.7203 + 2.6228 \cdot growth - 4.6970 \cdot length\_party\_control$$

Let's look at a couple of example to see how this works!

First, let's use this model to create a function to predict two-party vote share.

```r
vote_predict = function(growth, length_party_control){
  49.7203 + 2.6228*growth - 4.6970*length_party_control
}
```

Now, let's imagine an election where there has been 2% growth, and the incumbent party has been in office for 3 consecutive terms (which makes length_party_control equal to 1.5).  Our model predicts:

```r
vote_predict(2, 1.5)
```

If the incumbent party had only been in the White House for one term it would predict:

```r
vote_predict(2, 0)
```

**Question 2:** According to this model, would you rather been an incumbent with 4% growth, who's party had been in office for 3 consecutive terms or an incumbent with 0% growth, who's party had been in office for only 1 term?


We can make see what this model would have predicted for past elections and look at the residuals of those predictions:

```r
fair_hibbs$predicted_vote_m3 = predict(m3)

fair_hibbs = fair_hibbs %>%
  mutate(residual = vote - predicted_vote_m3)
```

If you look at the data, you can sort by residuals and see which Candidates did better and worse than the model's predictions:

```r
View(fair_hibbs)
```

**Question 3:** Which election result was the biggest surprise according to this model and which candidate outperformed expecattions by the most?

**Question 4:** Looking back at the summary of this model, how much of the variance in two-party vote shares does it purport to explain?


## Throwing Everything in the Pot

Now, let's try adding in a whole slew of variables!  In order for the WAR variable to mean anything, we'll need to go back further in time.  To do this, we'll need to switch over to using Ray Fair's data.

Here's a model using all of Fair's predictors:


```r
m_fair = lm(incumbent_vote ~ G + 
                  WAR + 
                  P + 
                  Z +
              incumbent_running_again + 
              length_party_control, 
              data=fair)

summary(m_fair)
```

**Question 5:** Which variables appear to be the most important predictors of the two-party vote share and how do you know?

**Question 6:** Try exploring the least important variables and creating what you think is the best model to predict two-party vote share.  Please explains which variables you used and why you decided to use those variables.

**Question 7 (time permitting):** On Ray Fair's website used predictions for the values of G, P and Z heading into the 2024 presidential election to predict the Democratic party vote share in 2024 (which is also the incumbent party vote share in 2024).  You can see that [here](https://fairmodel.econ.yale.edu/vote2020/indeane2.htm).  Try using these values to make predictions for the 2024 Presidential Election using your model.  What does your model predict?  How does it differ from Ray Fair's prediction?

