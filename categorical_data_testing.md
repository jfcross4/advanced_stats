Hypothesis Testing For Categorical Data
----------------------------------

# 1. One Proportion

# 2. Comparing Two Proportion

# 3. Chi Square Test for Goodness of Fit

Our example, results from possibly unfair dice:
```{r}
side <- 1:6
num_times <- c(80, 103, 93, 105, 96, 123)
die_results = data.frame(side, num_times)
kable(die_results)
```

### Full Calculations:
```r
num_times <- c(80, 103, 93, 105, 96, 123)
expected <- rep(100, 6)
differences = num_times-expected
chi_square = sum((differences^2)/expected)
1 - pchisq(chi_square, df=5) # to find the p-value
```

### Easy Way:

```r
num_times <- c(80, 103, 93, 105, 96, 123)
chisq.test(x = num_times, p=rep(1/6, 6))
```

# 4. Chi Square Test for Independence

# 5. Test Statistics (a general solution)
