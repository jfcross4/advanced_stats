Uncertainty and Bootstrap Samples
-----------------------------------

# Bootstrapping

Bootstrapping is a way of estimating the uncertainty in data from the data itself.  It's useful because we can estimate many different types of uncertainties this way, uncertainties in means and medians and in correlations, and (as we'll see later in this semester) best fit lines and all sorts of things.

There are also formulas we can use to estimate uncertainty which each work in **particular situations**.  These formulas contains bits of insight and we can compare our results using the formulas to our results using bootstrapping.  The power of bootstrapping is that it works more generally including in situations were we have more formula for calculating the uncertainty.

# Example 1: Standard Deviation in Successess

Earlier this year, we learned formulas for the expected value and variance in the number of successes for a binomial random variable:

$E[X] = np$

$Var[X] = np(1-p)$

which means that:

$SD[X] = \sqrt{np(1-p)}$

In other words, if I roll 120 six-sided dice and count up the number of 4's I expect...

$E[X] = np = 120 \cdot \frac{1}{6} = 20$ fours
give or take
$SD[X] = \sqrt{np(1-p)} = \sqrt{120 \cdot \frac{1}{6} \cdot \frac{5}{6}} \approx 4.08$ fours

# What if we didn't have that rbinom?

We could use bootstrap random samples!

**Bootstrap Random Samples** are samples, drawn with replacement that are the same size as your result.  The variance in bootstrap random samples tells you the uncertainty in your result 

# Bootstrapping Example

Let's start by creating a vector of 120 values with $\frac{1}{6}$ of 4's.

```r
die_rolls <- c(rep(1, 20), rep(0, 100))
die_rolls
```

We can take a bootstrap sample of this vector by doing:

```r
sample(die_rolls, size=120, replace=TRUE)
```

# Bootstrapping Example (continued)

We can do this 100,000 times using replicate:

```r
boot_samples <- 
  replicate(1e5, sample(die_rolls, size=120,
                        replace=TRUE))
```

and then count up the number of 4's in each batch of 120 rolls:

```r
num_fours <- apply(boot_samples, 2, sum)
mean(num_fours); 
sd(num_fours)
```

How well do these numbers match our formulas (as calculated above)?

We can also use the bootstrapped sampled to get "quantiles".

For instance what is an 80th percentile result in the number of 4's?

```r
quantile(num_fours, 0.8)
```

We could also solve for this theoretically, first I would determine what z-score corresponds to 80th percentile:

```r
qnorm(.8)
```

Then I would figure use the expected value and standard deviation to turn that z-score into a number of 4's:

```r
20 + 4.08*qnorm(.8)
```
# Example 2: Weighting a Kangaroo

Suppose that we're trying to weight a kangaroo but it's jumping up and down.  Like good statisticians, we decide to weigh it a number of times and take the average.

We weight the kangaroo ten times and get the following weights in pounds:

```r
k_weights <- c(93, 77, 62, 78, 75, 85, 66, 83, 91, 72)
```

A good estimate of the weight of the kangaroo is simply the average of these 10 numbers:

```r
mean(k_weights)
```

But how good is this estimate?  This is where bootstrapping can help!

I can take bootstrap samples of these 10 weights.  Remember that each bootstrap sample will have 10 weighings but since the samples are *with replacement* each sample is likely to have some repeat values and some values that aren't included at all.  The standard deviation in the means of these bootstrap samples is a good estimate of the uncertainty in the weight of this kangaroo.

```r
sample_means <- 
  colMeans(replicate(500, sample(k_weights, 
                          size=10, replace=TRUE)))

sd(sample_means)
```

This means that the kangaroo might easily be 3 pounds heavily or lighter than the average of these weights but it's very unlikely to be 10 pounds heavier than the average.

Is it plausible that this kangaroo really weighs 91 pounds?  91 pounds wasn't even the hight weight recorded, after all.  To answer this let's find out what proportion of bootstrap samples had an average of 91 or higher.

```r
mean(sample_means >= 91)
```
Another way to think about this is that 91 pounds is a whopping 4 standard deviations above the mean!  

# Example 3: A Cubit and Foot Length Correlation

Suppose that we measure the cubit and foot lengths of 12 students.  We get the following results (in centimeters):

```r
cubit <- c(45.7, 44, 53.3, 40.6, 42, 44.4, 
           47.7, 44, 42, 36.8, 43.2, 35)

foot <- c(25.4, 28, 24, 22.86, 24, 25.4, 
          29.9, 26.5, 26, 23.6, 24.9, 23.5)
```

It's important to note that these results are paired.  The first student had a cubit length of 45.7 cm and a foot length of 25.4 cm, for instance.

What is the correlation between foot length and cubit length?

```r
cor(cubit, foot)
```

But could this correlation be a fluke in this sample?  Might the true correlation between foot and cubit length be much higher or much lower?  Once again, we can lean on bootstrapping for an answer.

Since the data comes is pairs, I have to be careful.  I can't take bootstrap samples of feet and, separately, take bootstrap samples of cubits.  I have to take bootstrap samples of students and compare their feet and cubits.  I can do this as follows:

```r
sample_correlations <- replicate(10000, 
    {students <- sample.int(12, size=12, replace=TRUE);   
      cor(cubit[students], foot[students])}
            )

mean(sample_correlations)
sd(sample_correlations)
```

According to my bootstrap samples, the uncertainty in the correlation is substantial!

Might the true correlation be negative?  We can find out the proportion of the bootstrap sample in which the correlation was negative:

```r
mean(sample_correlations < 0)
```

It's a bit unlikely but (based on this sample of 12 students alone) I couldn't rule out that the true correlation between cubit length and foot length is negative.

# Example 4: Shooting Free Throws!

We see someone hit 30 of 50 free throws (60% or p=0.6).  What is the uncertainty in their true free throw shooting percentage?  You know how to answer this using the binomial formula but try answering it using bootstrapping.  You will probably want to use and adapt code from above.  
