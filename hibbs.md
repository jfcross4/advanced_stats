Best Fit Lines to Predict Election Winners
----------------------------------

Today, we're going to draw best fit lines to build a model to predict the winners of presidential elections.  In the process, we'll hopefully gain an understanding of linear models and the uncertainty of linear models.

# The Data

A political scientist named Douglas Hibbs created the "bread and peace" model for forecasting elections based on only economic conditions (and later added a correction for wartime).  

Let's read in some data on presidential elections and the economy and take a look:

```r
file = "https://raw.githubusercontent.com/avehtari/ROS-Examples/master/ElectionsEconomy/data/hibbs.dat"
hibbs <- read.table(file, header=TRUE)
View(hibbs)
```

* "growth" is the annualized average personal income growth in portion of the president's term prior to the election.  

* "vote" is the portion of the two-party vote share won by the incumbent party (the party that was in office at the time of the election).  "two-party vote share" means the candidate's portion of all of the votes that went to either a Republican or Democratic candidate.  For example, if in an election the Democratic candidate won 50% of the vote, the Republican candidate won 45% of the vote and some combination of third-party candidates won 5% of the vote, the Democratic candidate won 50/95 = 52.6% of the two party vote share and the Republican candidate won 45/95 = 47.4%.

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

# Linear Models

A simple one variable model fits a line, like good old $y = mx + b$ the model only in Statistics class we often call it $y = \beta_1 \cdot x + \beta_0$, to the data.

The best-fit line passes through the point $(\mu_x, \mu_y)$ and has a slope equal to $r \cdot \frac{\sigma_y}{\sigma_x}$ where $\mu_x$ and $\mu_y$ are the means of the x and y variables, $r$ is the correlation between the x and y variables, and $\sigma_x$ and $\sigma_y$ are the standard deviations of the x and y variables.

We can calculate the slope and y-intercept as follows:

```r
hibbs %>% 
  summarize(m = cor(vote, growth)*sd(vote)/sd(growth),
            b = mean(vote) - m*mean(growth))
```

In other words, our best-fit line has the equation:

$$vote = 3.06 \cdot growth + 46.2$$

The best-fit line is also a *prediction* line.  In this case it is an equation that allows us to predict vote shares for the incumbent party candidate based on income growth in previous years.  

In fact, the best-fit line is the line that minimizes the root mean squared error of the predicted vote shared compared to the actual vote shares.

**Question 1:**. According to this best fit line, what vote share would an incumbent party candidate be expected to get if there was 0 income growth?

**Question 2:**. According to this best fit line, what vote share would an incumbent party candidate be expected to get if there was 5% income growth?

**Question 3:**. According to this best fit line, how much income growth does an incumbent candidate need to be predicted to win 50% of the two-party vote share?

We can add the best fit line to our plot as follows:

```r
hibbs %>% ggplot(aes(growth, vote))+
  geom_text(aes(label=inc_party_candidate)) +
  geom_smooth(method="lm", se=FALSE)
```

**Question 4:**. Which incumbent party candidate(s) exceeded the predictions of this best-fit line by the most?

**Question 5:**. Which incumbent party candidate(s) fell short of expectations by the largest margin?

# Is this for real?

You might be asking yourself whether this relationship between income growth and presidential vote share could be a fluke.  Might we see a relationship this large (or larger) by chance?

Let's investigate this using the *infer* package we've practiced using in our DataCamp classes.  You'll need to install the infer package first.

First, let's build this simple model using the infer package.  This should yield the same result as our calculations above:

```r
library(infer)

observed_fit <- hibbs %>%
  specify(vote ~ growth) %>%
  fit()
  
observed_fit
```

Now, let's "shuffle" the data, randomly pairing vote shares with growths.  We'll create 1000 random shuffles (permutations).  For each of these shuffles we'll create a best fit line to predict vote share from growth.

```r
null_fits <- hibbs %>%
  specify(vote ~ growth) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  fit()
```

Here are histograms of the slopes and intercepts of the best fit lines of this randomly shuffled data.  The red lines represent the observed slope and intercept from the unshuffled data.

```r
visualize(null_fits) + 
  shade_p_value(observed_fit, direction = "both")
```

**Question 6:**
Do the observed slope and intercept stand out relative to the slopes and intercepts of the shuffled data?  What does this mean?

Note, we can also use our permutations to get p-values for the observed slopes and intercepts.

```r
get_p_value(null_fits, observed_fit, "two-sided")
```

# Bootstrap Samples for Uncertainty

We can use bootstrapping to estimate the uncertainty in the slope and intercept of our best-fit line.  We'll created 1000 bootstrap samples of the data (while keeping the pairings between vote share and growth intact) and for each bootstrap sample create a best-fit line.

```r
bootstraps <- hibbs %>%
  specify(vote ~ growth) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  fit()
```

and find 95% confidence intervals for the slope and intercept:

```r
get_confidence_interval(
  bootstraps, 
  point_estimate = observed_fit, 
  level = .95
)
```

And visualize the slopes and intercepts of our bootstrap samples.

```r
visualize(bootstraps) + 
  shade_p_value(observed_fit, direction = "both")
```

**Question 7:**. Please describe the distribution of best-fit-line slopes from these bootstrap samples.

# Fitting the model with lm

In R the easiest way to create a best fit line is using the "lm" function which stands for "linear model".

It works as follows:

```r
lm(vote ~ growth, data=hibbs)
```

We can get a fuller look at this model but saving it as an object and then looking at that object.


```r
m = lm(vote ~ growth, data=hibbs)
summary(m)
```

It's worth taking a look at this summary and trying to make sense of some of these numbers.  First, look at the "Estimate" column.  This column shows the estimated y-intercept and slope of the best fit line.  These numbers should match the ones we calculated above.

Now, let's look at the "Std. Error" column.  Instead of using bootstrap samples, R uses the following formula to find the standard error in the slope of the best fit line:

$$SE = \sqrt{\frac{1}{n-2} \cdot \frac{\Sigma{(y_i - \hat{y_i})^2}}{\Sigma{(x_i - \bar{x})^2}}}$$

where $n$ is the sample size, $y_i$'s are the actual vote shares, $\hat{y_i}$'s are the vote shares predicted by the best fit line, $x_i$'s are the actual growth rates and $\bar{x}$ is the mean growth rate.  

We are dividing by $n-2$ rather than n, because two points define a line and, given the equation for the line, there are only n-2 degrees of freedom.  

This equation gives a standard error of the slope of 0.6963. R then calculates a t-value by dividing the slope (3.0605) by the standard error in the slope.

```r
t = 3.0605/0.6963
t
```

The calculation above returns the t value that you see in the summary for growth.

You can find the p-value shown in the summary by looking up that t-value in a t table with $n-2 = 14$ degrees of freedom.  We'll multiply this by 2 to get a two-tailed p-value:

```r
2*(1-pt(t, df=14))
```

The number above should match the number you see in the "Pr(>|t|)" column for growth (the slope).

The other numbers in the model summary will be more meaningful later, when we build more complex models, and we'll return to them then.

**Question 8:**
What **p-value** does R return for the **slope** of the best-fit line and how would you interpret it?

The t-value and p-value for the **y-intercept** are fairly meaningless in this case because R is comparing the observed y-intercept to a null hypothesis that y-intercept is zero (which makes no sense!).

# What about the "Bread and Peace" model?

**Question 9:**
After looking at all of this, what do you make of Hibbs's model to predict presidential vote shares using income growth?  Are you convinced that this relationship is meaningful?

