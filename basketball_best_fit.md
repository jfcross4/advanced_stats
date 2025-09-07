Basketball Best-Fit Lines and Linear Regression
______________________________________________

In this lab, we're going to learn about best-fit lines and linear regression... and a little bit more about college basketball.  We're building up towards learning about multiple regression and logistic regression.

First, let's load our favorite package and some data on games from the 2024-2025 college basketball season and then take a look at the data.

```r
library(tidyverse)

games = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/cross/ncaa_basketball_games_2025.csv")

View(games)

```

This data is from Kaggle.  You may recognize the teamID's.  Each row represents one game... but each game is represented by two rows, one from the perspective of each team.  Here are some of the abbreviations used in the data set:

* OR: Offensive Rebounds
* DR: Defensive Rebounds
* Ast: Assists
* TO: Turnovers
* Stl: Steals
* Blk: Blocks
* PF: Personal Fouls
* FGM: Field Goals Made
* FGA: Field Goals Attempted
* FGM3: 3-pointers Made
* FGA3: 3-pointers Attempted

The "margin" columns show team 1's total minus team 2's total.  *PT_margin* is how many points team 1 won (or lost) by.  We will build models to predict this column.

# Histograms

It's always a good idea to graph your data as a way of understanding it.

Let's start with univariate graphs: histograms!

```r
games %>%
  ggplot(aes(PT_margin)) +
  geom_histogram(binwidth=1)
  
games %>%
  ggplot(aes(TO_margin)) +
  geom_histogram(binwidth=1)
```

**Question #1**
What do you see in these histograms?  How would you explain it?

# Scatterplots

Now, let's try a bivariate plot.

```r
games %>%
  ggplot(aes(TO_margin, PT_margin))+
  geom_point()
```

We can add a linear (ordinary least squares) best-fit line.  The "least squares" part refers to this fact minimizes the sum of the squared differences between the points and the line.  If we think of this as a prediction line (predicting point margin from turnover margin), the line minimizes the root mean square error.

```r
games %>%
  ggplot(aes(TO_margin, PT_margin))+
  geom_point()+
  geom_smooth(method="lm")
```

**Question #2**
Looking at the best-fit line, if a team had 10 more turnovers than their opponents, roughly how many points would you expect them to win (or lose) by?

**Question #3**
Try creating a best-fit line for predicting PT_margin from DR_margin.  How many points would you expect a team to win/lose by if they outrebounded their opponents by 10?

# Equations

We can also get the equations for these best-fit lines.  The following code produces the intercept and slope of the best-fit line to predict PT_margin from TO_margin.

```r
lm(PT_margin ~ TO_margin, data=games)
```
**Question #4**
Looking at this slope and intercept, how would you explain the relationship between turnovers and points in words?  How would you describe the y-intercept?

**Question #5**
Look back at your answer to question #2.  Now, try making a more precise prediction using this equation (if a team had 10 more turnovers than their opponents, roughly how many points would you expect them to lose by?).

We can get more information on the best fit line by saving it as an object (I'll call it "m") and then looking at the object.

```r
m = lm(PT_margin ~ TO_margin, data=games)

summary(m)
```

The left-most column, called "Estimate" shows you the intercept and slope of the best-fit line again.  

The "Std. Error" shows the standard error in the slope and y-intercept (how much uncertainty there is in our estimates of these values).  

The "t value" column is the Estimate divided by the Standard Error and tells us how many standard errors away from 0 our estimate is.  

Lastly, the "Pr(>|t|)" is a p-value.  It tells you how likely we would be to get a t-value this large or larger if the true value was zero.

**Question #6**
Looking at the summary of this best-fit line, can you reject the null hypothesis of no relationship between turnover margin and point margin?


**Question #7**
Try creating a best-fit line to predict PT_margin from PF_margin.  Based on this line (and the previous line), which is most costly a turnover or a foul?  (Or can these lines not answer that question?)
```r
m = lm(PT_margin ~ PF_margin, data=games)
summary(m)
```

# Multiple Regression

It's possible to build models based on more than one variable.  For instance here's a model to predict point margin from both offensive rebound and defensive rebound margins:

```r
m = lm(PT_margin ~ OR_margin + DR_margin, data=games)

summary(m)
```

Try comparing that model to one based only on offensive rebounding margin:

```r
m = lm(PT_margin ~ OR_margin, data=games)

summary(m)

```

**Question #8**
How does the importance of offensive rebounding margin change once defensive rebounding margin is included in the model?  Can you explain this (tricky!)?

Lastly, let's also include the field goals attempted margin:

```r
m = lm(PT_margin ~ OR_margin +FGA_margin + DR_margin, data=games)

summary(m)
```

**Question #9**
How does the relationship between offensive rebounding margin and point margin change when both defensive rebounding margin and field goal attempt margin are included in the model?  Can you explain this?  (It might help to remember that these slopes are like correlations in that they don't imply causation!)
