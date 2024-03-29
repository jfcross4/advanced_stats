Ray Fair Ridge Regression
----------------------------------

```r
library(tidyverse)
library(glmnet)

fair = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/fair.csv")
```

```r
fair = fair %>%
  mutate(incumbent_vote = 50 + I*(VP-50),
          incumbent_running_again = abs(DPER),
          length_party_control = abs(DUR))
```

Simple Linear Model

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

Creating the model matrix

```r
fair_x <- model.matrix(incumbent_vote ~ G + 
                  WAR + 
                  P + 
                  Z +
              incumbent_running_again + 
              length_party_control, fair)[, -1]
```

Graph of coefficients with different size lambda's:

```r
fair_ridge <- glmnet(
  x = fair_x,
  y = fair$incumbent_vote,
  alpha = 0
)

plot(fair_ridge, xvar = "lambda")

```

Mean Square Errors with different amount of shrinkage:

```r
fair_ridge_cv <- cv.glmnet(
  x = fair_x,
  y = fair$incumbent_vote,
  alpha = 0
)

plot(fair_ridge_cv)

```

Coefficients with different amounts of shrinkage


```r
coef(fair_ridge)
```

The coefficients based on the lambda that minimizes MSE out-of-sample (we can compare this to the simple linear model):

```r
coef(fair_ridge)[,fair_ridge_cv$lambda.min == fair_ridge_cv$lambda]
```
