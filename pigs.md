08 When Should you Pass the Pigs?
----------------------------------

Today's lab involves learning from the data gathered from 6000 rolls of "Pass the Pigs".

The data comes from [this experiment](https://jse.amstat.org/v14n3/datasets.kern.html) and we can read it into R and view it with the following code:

```r
pigs = 
  read.table("https://jse.amstat.org/datasets/pig.dat.txt", 
             sep=" ", header = TRUE)
View(pigs)
```

For help understanding what it all means, you should read [this explanation](https://jse.amstat.org/datasets/pig.txt).

# 1. When to pass the pigs

Let's keep it simple (for now) and assume that you want to pass the pigs 
when the expected value of your next roll is negative.  (Perhaps in a later lab, we can consider the role of variance and whether in a large game or when you are behind it makes sense to be "risk loving".)  
If you have a small number of points, you have less to lose and the expected value of your next roll is positive.  When you have already accrued a large number of points, you risk losing a lot and the expected 
value of rolling again is negative.  But, how many points must you have before the expected value turns negative?  

Let's find out. We'll start by determining how often each score occurred.

```r
library(tidyverse)

pigs %>% 
  count(score)
```

There are (at least!) a few things worth noting:

* The score of -1 means that the pigs were touching (an "oinker"!) and points from all rounds were lost.  In other words, this might in fact be much more costly than -1.
* A score of 0 means that they "pigged out" and points from the current round were lost.  This is worse than 0.
* There was *exactly* one score of 60 -- a double leaning jowler!  What a moment!

We want to calculate the expected value of a roll (the weighted average of scores with scores weighted by their frequencies) but to do that we need to know how many points were at risk (the true costs of oinkers and pigging out).  
Let's first pretend that no points were at risk and calculate the expected value:

```r
results_table = 
  pigs %>% 
  count(score)

results_table[1,1] = 0 # no points lost by an oinker
results_table[2,1] = 0 # no points lost by a pig out

# the expected value of the next roll:

results_table %>%
  summarize(sum(score*n)/sum(n))

```
Now, let's put some points at risk.  
Let's pretend that the player has 50 total points (all of which they'd lose with an oinker) and 10 points in the current round (which they'd lose with just a pig out):

```
results_table[1,1] = -50 # 50 points lost by an oinker
results_table[2,1] = -10 # 10 points lost by a pig out
```

Then, let's calculate the expected value again:

```r
results_table %>%
  summarize(sum(score*n)/sum(n))
```

Q1: Based on your result, does it make sense for a player to keep rolling when they have 50 total points and 10 points in the current round?

We can keep changing these values (total points and points in the current round) and computing the expected value.  For instance, let's stick with 50 total points but give the player 15 points in the current round:

```r
results_table[1,1] = -50 # 50 points lost by an oinker
results_table[2,1] = -15 # 15 points lost by a pig out

results_table %>%
  summarize(sum(score*n)/sum(n))
```

Q2: The expected value is much more sensitive to changing one of these point values than the other.  
Which is it and why?

Q3: Keep fiddling with the values until you determine the best criteria for when and when not to pass the pigs.
**Alternative: Use algebra to write an equation for when to pass the pigs.**

# 2. Really, a double leaning jowler!  Was that a miracle?

As mentioned earlier, there was exactly *one* double leaning jowler in 6000 rolls so we could estimate the probability of a double leaning jowler as 1/6000 or 
$1.67 \times 10^{-4}$.  But can we do better?

Let's assume that the dice are independent and calculate the overall chance of a leaning jowler.  
We'll start by making a new version of this data where all the outcomes (from black and pink pigs) are in one column:

```r
individual_rolls = 
  rbind(pigs %>% select(height, pig="pink", outcome=pink),
        pigs %>% select(height, pig="black", outcome=black))

individual_rolls %>%
  count(outcome)
```

This new summary shows that there were 73 leaning jowlers in 12,000 individual pig rolls.

Q4: Calculate the chance of a double leaning jowler using this data.  
Is the chance (calculated this way) higher or lower than 1/6000?  
Which method of calculating the chance of a double leaning jowler do you think is more accurate?

# Does the pig matter?  Does the roll matter?

We could also look at the frequencies of each outcome for each pig:

```r
individual_rolls %>%
  count(pig, outcome)
```

Q4: Do the results look different for the two pigs?  Where they do look a bit different, could these differences easily be explained by chance (this is a tricky question)?

Let's also split the results by roll height:

```r
individual_rolls %>%
  count(height, outcome)
```

Q5: Do the results look different for the two roll heights?  Where they do look a bit different, could these differences easily be explained by chance?

# Bonus

Q6: For one of our double leaning jowler calculations, we assumed that the pigs are independent.  Does the data collected refute that assumption?  How might we show whether the assumption of independence is consistent with this data?  (This is a question that we'll explore as a class soon, but I'm interested in how you'd go about this.)