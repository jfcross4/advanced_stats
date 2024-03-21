Best Fit Lines to Predict Election Winners
----------------------------------

Today, we're going to draw best fit lines to build a model to predict the winners of presidential elections.  In the process, we'll hopefully gain an understanding of linear models and the uncertainty of linear models.

# The Data

A political scientist named Douglas Hibbs created the "bread and peace" model for forecasting elections based only on economic conditions (and later added a correction for wartime).  

Let's read in some data on presidential elections and the economy and take a look:

```r
file = "https://raw.githubusercontent.com/avehtari/ROS-Examples/master/ElectionsEconomy/data/hibbs.dat"
hibbs <- read.table(file, header=TRUE)
View(hibbs)
```

* "growth" is the annualized average personal income growth in portion of the president's term prior to the election.  

* "vote" is the portion of the two-party vote share won by the incumbent party (the party that was in office at the time of the election).  "two-party vote share" means the candidate's portion of all of the votes that went to either a Republican or Democratic candidate.  For example, if in an election, the Democratic candidate won 50% of the vote, the Republican candidate won 45% of the vote and some combination of third-party candidates won the remaining 5% of the vote, the Democratic candidate won 50/95 = 52.6% of the two party vote share and the Republican candidate won 45/95 = 47.4% of the two party vote share.

Let's start by graphing the data:

```r
library(tidyverse)

hibbs %>% ggplot(aes(growth, vote))+
  geom_point()
```

We could use labels instead of points:

```r
hibbs %>% ggplot(aes(growth, vote))+
  geom_text(aes(label=year))
  
hibbs %>% ggplot(aes(growth, vote))+
  geom_text(aes(label=inc_party_candidate)) 
```

*How would you describe the relationship between growth and vote share?  Is this surprising?*

# Linear Models

A simple one variable model fits a line, like good old $y = mx + b$. In Statistics class, instead of $y = mx + b$ we often call it $y = \beta_1 \cdot x + \beta_0$.  This change in naming convention will make more sense when we start to build more complex models.

The best-fit line passes through the point $(\mu_x, \mu_y)$ and has a slope equal to $r \cdot \frac{\sigma_y}{\sigma_x}$ where $\mu_x$ and $\mu_y$ are the means of the x and y variables, $r$ is the correlation between the x and y variables, and $\sigma_x$ and $\sigma_y$ are the standard deviations of the x and y variables.

We can calculate the slope and y-intercept of the best-fit line as follows:

```r
hibbs %>% 
  summarize(m = cor(vote, growth)*sd(vote)/sd(growth),
            b = mean(vote) - m*mean(growth))
```

In other words, our best-fit line has the equation:

$$vote = 3.06 \cdot growth + 46.2$$

The best-fit line is also a *prediction* line.  In this case it is an equation that allows us to predict vote shares for the incumbent party candidate based on income growth in previous years.  

In fact, the best-fit line is the line that minimizes the root mean squared error of the predicted vote shares compared to the actual vote shares.

**Question 1:**. According to this best fit line, what vote share would an incumbent party candidate be expected to get if there was 0 income growth?

**Question 2:**. According to this best fit line, what vote share would an incumbent party candidate be expected to get if there was 5% income growth?

**Question 3:**. According to this best fit line, how much income growth does an incumbent candidate need in order to be predicted to win at least 50% of the two-party vote share?

We can add the best fit line to our plot as follows:

```r
hibbs %>% ggplot(aes(growth, vote))+
  geom_text(aes(label=inc_party_candidate)) +
  geom_smooth(method="lm", se=FALSE)
```

**Question 4:**. Which incumbent party candidate(s) exceeded the predictions of this best-fit line by the most?

**Question 5:**. Which incumbent party candidate(s) fell short of expectations by the largest margin?

# Is this for real?

You might be asking yourself whether this relationship between income growth and presidential vote share could be a fluke.  Might we see a relationship this large (or larger) by chance?  Let's use R to get an equation for this line as well as some other numbers of interest.  In R the easiest way to create a best fit line is using the "lm" function which stands for "linear model".

```r
m = lm(vote ~ growth, data = hibbs)
summary(m)
```

It's worth taking a look at this summary and trying to make sense of some of these numbers.  First, look at the "Estimate" column.  This column shows the estimated y-intercept and slope of the best fit line.  These numbers should match the ones we calculated above.

Now, let's look at the "Std. Error" column.  R uses the following formula to find the standard errors:

$$SE = \sqrt{\frac{1}{n-2} \cdot \frac{\Sigma{(y_i - \hat{y_i})^2}}{\Sigma{(x_i - \bar{x})^2}}}$$

where $n$ is the sample size, $y_i$'s are the actual vote shares, $\hat{y_i}$'s are the vote shares predicted by the best fit line, $x_i$'s are the actual growth rates and $\bar{x}$ is the mean growth rate.  

We are dividing by $n-2$ rather than n, because two points define a line and, given the equation for the line, there are only n-2 degrees of freedom. 

The standard error in the slope is 0.6963 and we can see that in the summary.  

R also calculates a t-score for the slope (the estimate slope divided by the standard error in the slope):

```r
3.0605/0.6963
```

and gets 4.396.

Then R tests the null hypothesis that this slope is zero.  It does a two-sided t-test with 14 degrees of freedom (since there are 16 elections in this data set and there are n-2 degrees of freedom).

```r
2*(1-pt(3.0605/0.6963, df=14))
```
The p-value of 0.00061 should match the number you see in the "Pr(>|t|)" column for growth (the slope).

**Question 6:**
Based on these results, are you convinced that there's a real relationship between growth and vote share.

The t-value and p-value for the **y-intercept** are fairly meaningless in this case because R is comparing the observed y-intercept to a null hypothesis that y-intercept is zero (which makes no sense!).

The other numbers in the model summary will be more meaningful later, when we build more complex models, and we'll return to them then.

# More Complex Models to Predict Elections

We can also build more complex **Multiple Regression** models to predict Presidential Election vote shares.  In addition to the Hibbs data we used above, we'll use Ray Fair's data.

## The Data

You can find a description of Ray Fair's model and, most importantly for our purposes, a description of the meaning of his variables [here](https://pollyvote.com/en/components/models/retrospective/fundamentals-only-models/fair-model/).  It's worth taking a few minutes to read this.

Notable, while Hibbs' data is set up to predict the *imcumbent party's* vote share, Ray Fair's data is designed to predict the *Democratic party's* vote share.

You should start by taking a look at the two data sets:

```r
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

And, if we want we can combine the Hibbs and Fair data.  The Hibbs data covers fewer elections and this join will include only elections included in the Hibbs data:

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

**Question 7:** Which appears to be a better predictor of the vote share?

## Multiple Regression

Instead of trying to predict the two-party vote share using only one variable, we can try to predict it using two variables.  Geometrically, one variable regression looked like finding a best-fit line to points on a plane.  Two variable regression is try to find a best-fit plane for points in three dimension (which is much harder to picture!).

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

**Question 8:** According to this model, would you rather been an incumbent with 4% growth, who's party had been in office for 3 consecutive terms or an incumbent with 0% growth, who's party had been in office for only 1 term?



