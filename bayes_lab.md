05 Bayes Lab (using binomial random variables)
-------------------------------------

As you may (possibly) recall, it's possible to take Bayes theorem (which helps us find condition probabilities):

$$ P(A|B) = 
\frac{P(A)\cdot P(B|A)}{P(A)\cdot P(B|A) + P(\bar{A})\cdot P(B|\bar{A})} $$

and rearrange it into a formula to help up find relative odds.

Recall that:

$$ odds(A) = \frac{P(A)}{P(\bar{A})} $$

then we can say that 

$$ odds(A|B) = \frac{
\frac{P(A)\cdot P(B|A)}{P(A)\cdot P(B|A) + P(\bar{A})\cdot P(B|\bar{A})}
}{
\frac{P(\bar{A})\cdot P(B|\bar{A})}{P(\bar{A})\cdot P(B|\bar{A}) + P(A)\cdot P(B|A) }
}$$ 

or, more simply:

$$ odds(A|B) = \frac{P(A)\cdot P(B|A)}{P(\bar{A})\cdot P(B|\bar{A})} $$ 

or, even:

$$ odds(A|B) = odds(A) \cdot \frac{P(B|A)}{P(B|\bar{A})} $$ 

This is now a system for updating our beliefs or hypotheses (H) based on new evidence (E):

$$ odds(H|E) = odds(H) \cdot \frac{P(E|H)}{P(E|\bar{H})} $$

The "posterior" odds of this hypothesis being true (in light of the evidence) is equal to the "prior" odds of this hypothesis being true (prior to the evidence) multiplied by the likelihood of seeing this evidence/result given this hypothesis is true divided by the likelihood of seeing this evidence/result if the hypothesis is false.

AND, we can adapt this formula when there are more than two (or even an infinite number of) possible hypotheses!

$$ Relative\ Posterior\ Odds = Relative\ Prior\ Odds \cdot Relative\ Likelihoods $$

That's what we'll do in today's lab!

# 1. Unfair Coins

Imagine a large barrel of coins.  Half of them are fair coins which comes up heads 50% of the time.  The other half is split evenly between coins that come up heads 60% of the time and coins that come up heads 40% of the time.  You pluck out a coin at random and flip it 50 times and see 30 heads.  We're interested in known the probability that we have each type of coin and the expected value of the number of heads if we flip it again.  Let's start with our prior:

The possible values are 0.4, 0.5, 0.6 representing the chances of different types of coins from this barrel coming up heads.  The relative prior odds are 1:2:1 since the fair coins are twice as plentiful as either of the other two types of coins.

```r
values = c(0.4, 0.5, 0.6)
rel_prior = c(1, 2, 1)
```

Here's a graph of our prior:


The "relative likelihood" is how likely we would be to see our results (30 heads in 50 flips) given each of the different types of coins:

```r
rel_lik = 
  dbinom(30, 50, prob = values)
```

We could plot this:

```r
plot(x=values, y=rel_lik, type="h")
```

This graph shows us that our results are much more likely given a coin that comes up heads 60% of the time than given a coin that comes up heads 40% of the time.

Lastly, we can calculate the relative posterior odds by multiplying the prior odds by the relative likelihoods:

```r
rel_posterior = rel_prior * rel_lik
```
We can plot these too:

```r
plot(values, rel_posterior, type="h")
```

Notice that these values don't add to one.  These aren't probabilities!  We can turn them into probabilities by "normalizing" them so that they do add to 1, however.  We just divide each relative posterior by the sum of the relative posteriors.

```r
posterior_probs = rel_posterior/sum(rel_posterior)

posterior_probs
```
This tells us there's slightly less than a 1% chance than we have a coin that comes up heads 40% of the time and a roughly 57% chance that we have a coin that comes up heads 60% of the time.

If we're interested in predicting the chance that our coin will come up heads in the next toss, we can calculate this as an expected value in the usual way -- by summing the products of probabilities and values.

```r
sum(posterior_probs*values)
```

So, there's almost a 56% chance our next toss will be a head.

**Task 1:**  If you select a coin from a barrel with 80% fair coins, 10% coins that comes up heads 60% of the time and 10% coins that come up heads 40% of the time and then flipped 55 heads in 100 tosses, what is the chance that your next flip will be a head?

# 2. Free Throws

Let's imagine high school basketball shooters hit free throws at a 70% clip.  Some players are better than others, of course, and the standard deviation in free throw shooting ability is 10%.  We walk into a high school gym and see a player hit 9 of 10 free throws.  What is the chance that they will hit their next shot?

Once again, we'll start with our prior.  This is what our guess looks like before we see this player shoot and our guess is based only on what we know about high school basketball players in general.

We'll let players have free throw shooting abilities between 0 and 1 with a mean of 0.7 and a standard deviation of 0.1.  I'll use a normal distribution but *technically* this is wrong!  A normal distribution extends indefinitely in both directions and probabilities can only be between 0 and 1. (We'd be better off using some other distribution like the Beta distribution -- but we won't worry about that for now.)

```r
values = seq(0, 1, 0.01)
rel_prior = dnorm(values, mean=0.7, sd=0.1)
```
Let's take a look at what this looks like:

```r
plot(values, rel_prior, type="h")
```
The expected value of our distribution isn't exactly 0.7 since a bit of the right tail (and a smaller bit of the left tail) are chopped off but it's pretty close:

```r
sum(values*rel_prior)/sum(rel_prior)
```

Now let's determine how likely every type of shooter is to hit 9 of 10 free throws and calculate our posterior in the same way that we did with the coins:

```r
rel_lik = 
  dbinom(9, 10, prob = values)

rel_posterior = rel_prior * rel_lik

posterior = rel_posterior/sum(rel_posterior)

plot(values, posterior, type="h")

#Expected value and chance of making the next free throw
sum(values*posterior) 
```

We see that this shooter has a 76.7% chance of making their next free throw which is better than the population average of 70% but not as good as their recent 90% (9 of 10) shooting.

**Task 2:**  If you observed this shooter make 90 of 100 shots, what would your posterior distribution look like (please describe it in words) and what is their chance of making their next shot?

# 3. Surely you saw this coming... more ESP

Imagine that someone is agnostic on whether college students have ESP and will be able to predict the locations of images in Bem's study.

In fact, while they believe that there's a 50% chance that students have no ESP, they also think that there's a 50% chance that there *is* some ESP effect but they don't know how big that effect will be.

Their prior for student imagine locating ability looks like the following:

```r
values = seq(0, 1, 0.01)
rel_prior = ifelse(values==0.5, 0.5, 0.005)
```

We can see that their prior assigns half of the probability to "no ESP" by calculating the following:

```r
rel_prior[values==0.5]/sum(rel_prior)
```

and graph their prior with:

```r
plot(values, rel_prior, type="h")
```

Now, they observe Bem's result where roughly 53% (850 of 1600) guesses are correct and they update their beliefs about ESP.

```r
rel_lik = 
  dbinom(850, 1600, prob = values)

rel_posterior = rel_prior * rel_lik

plot(values, rel_posterior, type="h")
```

We can also calculate how much probability they assign to "no ESP" now that they've witnessed Bem's results:

```r
rel_posterior[values==0.5]/sum(rel_posterior)
```

Interestingly, this observer now assigns a greater probability to "no ESP"!  They went from thinking that there's a 50% chance to ESP doesn't exist to thinking that there's a nearly 59% chance that it doesn't exist.

**Task 3**: These two analysis of the ESP data may appear to be conflicting.  One way of the analysis, from our previous lab, may have lead us to believe that Bem found strong evidence for ESP and, yet, in this lab our agnostic observer assigns a lower probability to ESP after observing Bem's result.  

a. How would you explain this difference?  Which analysis do you think is more revealing?

b. Try to devise your own prior for ESP.  Adapt the code above to determine how are your beliefs are effected by Bem's results and describe your findings.
