Uncertainty, More Bootstraps and the t Distribution
-----------------------------------

# Re-Weighing a Kangaroo

Do you remember our kangaroo weights from last week?  We imagined weighing the same jumping kangaroo ten times and averaging the noisy measurements to estimate its weight.

```r
k_weights <- c(93, 77, 62, 78, 75, 85, 66, 83, 91, 72)
mean(k_weights)
```

We also use bootstrapping to estimate the uncertainty in its weight:

```r
sample_means <- 
  colMeans(replicate(50000, sample(k_weights, 
                                 size=10, replace=TRUE)))

var(sample_means)
```

There is another way to do this!  We'll start by using the variance of our measured kangaroo weights to determine the inaccuracy of our measurements.  

**Which variance?!?!**  (you now know to ask)

If we're interested in how accurate are measurements are, we looking for the variance in the imaginary population of all possible measurements (or some very large number of measurements if you prefer).  We only have a sample of that population.  To estimate the variance in the full population we should use the (Bessel corrected) variance of the same.  This the one that divides by $n-1$ instead of $n$. This is also the default of the "var" function in R.  This gives us an unbiased estimate (*but still just an estimate*) of the variance in my kangaroo measuring.

```r
var(k_weights)
```

Since variances add, the variance is the sum of 10 measurements would be 10 times this large.  The mean of 10 measurements is 1/10th of the sum of 10 measurements but that actually means that the variance in the mean of 10 measurements is 100 smaller than the variance in the sum of 10 measurements (from our law of linear transformations from earlier in the year):

$$var(aX) = a^2 var(X)$$

There's the variance in the mean of 10 measurements in 1/10th the variance in measurements.  More generally:

$$\sigma^2(mean\ of\ n\ measurements) = \frac{\sigma^2(measurments)}{n}$$

In our case:

```r
var_mean_k_weight = var(k_weights)/length(k_weights)

var_mean_k_weight
```

Lastly, we can find the "standard error" (a term for the standard deviation of an estimate) in the mean kangaroo weight by:

```r
se_mean_k_weight = sqrt(var_mean_k_weight)

se_mean_k_weight
```

This means that we think the actual weight of the kangaroo is the mean of our measurements give or take 3 pounds.

# the t distribution

Suppose that we want to find an 95% confidence interval in the mass of the kangaroo. 

## First, the not quite right way:

I might start by realizing the the 95% confidence interval extends from 2.5% to 97.5%.  The I would figure out what z scores correspond to 2.5 percentile and 97.5 percentile.  I could do with with qnorm:

```r
qnorm(c(0.025, 0.975))
```

This means that the 95th percentile confidence interval extends from 1.96 standard deviations below the mean to 1.96 standard deviations above the mean.

To convert the range of z-scores to a range in kangaroo weights, I'll multiply by the standard error in my estimate of the kangaroo's weight and add in the mean:

```r
mean(k_weights) + qnorm(c(0.025, 0.975))*se_mean_k_weight
```

According to that math, there's a ~95% chance that the kangaroo's actual weight is between 72.0 and 84.4.  

But is that right?

## The right way

No, not quite!  It would be right if we knew for certain the variance in our measurements.  There are two sources of uncertainty here, uncertainty due to the limited number of measurements (and the variance in the measurements we do have) and uncertainty in how inherently varied my kangaroo weight measurements really are.  This added source of variance is why statisticians use the *t* distribution rather than the standard normal distribution.  The t distribution accounts for the uncertainty in my estimate of the variance in the measurements.

The shape of the t distribution depends on the number of "degrees of freedom".  With 10 datapoints and a given mean, there are 9 degrees of freedom (indepedent wiggles), because after you known 9 of the data points, you could determine the 10th using the mean.

```r
# instead of:
qnorm(c(0.025, 0.975))

# we use:

qt(c(0.025, 0.975), df=9)
```

Due to the uncertainty in the variance, our 95% confidence interval must extend from 2.26 standard errors below the mean to 2.26 standard errors above (rather than -1.96 to +1.96).  We can convert these t scores to kangaroo weights the same way we did with z scores:

```r
mean(k_weights) + 
  qt(c(0.025, 0.975), df=9)*se_mean_k_weight
```
My 95% confidence interval extends from 71.0 pounds to 85.4 pounds.  This is wider than I would have assume using the standard normal distribution.

## Problem # 1

You land on the planet Stannsus and meet the Stanni who live there.  You find the masses of 6 Stanni in kilograms:

63.6, 80.8. 56.5, 64.0, 89.0, and 43.7

Estimate:

a. The average mass of a Stanni.

b. The standard deviation in the masses of Stanni.

c. The standard error in the mean mass of Stanni.

d. A 90% confidence interval for the mean mass of Stanni.

e. An 80% confidence interval for the mean mass of Stanni.

# Problem # 2

The statistics teacher at a high school is curious to know if students in the statistics class are taller on average than the general student population at the school. The average height of students at the school is known to be 165 cm.

Data Collection:

The teacher measures the height of a random sample of 6 students from a statistics class. The heights (in cm) are as follows:

168, 172, 167, 171, 164, 170

Does this data provide evidence that statistics students are taller than the school average?

