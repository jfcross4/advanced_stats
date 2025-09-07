What are the chances that the Chiefs win the Superbowl?
----------------------------

The 49ers are favored over the Chiefs by 1.5 points.  Quite a bit of statistical work likely went in to work coming up with an initial line for this game and some gamblers likely did more statistical work deciding which side to bet on (perhaps shifting the line in the process).  For our part, we're going to accept the 1.5 point spread as the truth and assume that the Niners are 1.5 points better than the Chiefs right now.  But does that mean that the Niners will win?  Do the Chiefs have a chance?  Today, we'll use three methods to try to estimate the Chief's chance of victory.

# 1. Random Variables

Let's first try to solve this problem using random variables!

I'm going to start by making a random variable for each possession.  I'm going to use a very simply model.  I'm going to assume that in each possesion the Niner have a 57% chance of getting no points, a 14% chance of getting 3 points and a 29% chance of getting 7 points.  I'll make the Chief's less likely to score a touchdown and then give each team 10 possessions in the game.  First of all, this is clearly an oversimplification.  There are no safeties in the model, no two-point conversions and we're totally neglecting field position.  I have, however, been careful about two things, the model has the Niners scoring an average of 1.5 points more than the Chiefs and the two teams are expected to score 47.5 points total (which is the over-under in the game).  Maybe by getting those two things right we can afford to ignore other complications?  

First, let's load the discreteRV package and then create random variables for one possession for both the Niners and the Chiefs:

```r
library(discreteRV)
niners = RV(c(0,3,7), probs=c(.57, .14, .29))
chiefs = RV(c(0,3,7), probs=c(.58, .16, .26))
```

Next, we'll create random variables for each team's total points scored in the game by assuming each team gets 10 *independent* possessions (no "hot hand" for these teams!).

```r
chiefs_tot = SofIID(chiefs, n=10)
niners_tot = SofIID(niners, n=10)
````
We can look at plots of the possible scores for each team according to this model:

```r
plot(chiefs_tot)
plot(niners_tot)
```
Since, we're really just interesting in the difference between the two teams' score, I'll create yet another random variable representing the Chief's margin of victory.

```r
chiefs_margin = chiefs_tot - niners_tot
```
What should the expected value of this random variable be?  Let's find out and then plot the random variable.

```r
E(chiefs_margin)
plot(chiefs_margin)
```

So, how often to the Chief's score more points?

```r
P(chiefs_margin>0)
```
Have we forgetten something?  Yes, we have!  If the two teams score the same number of points the game will go to overtime.  How often does this model expect the game to go to overtime?

```r
P(chiefs_margin==0)
```

There are reasons to expect this estimate of the chance of seeing overtime isn't particularly good.  Team's aren't independent draws from a random variable and a team simply isn't going to settle for a field goal if they are down 7 late in the game.  Nonetheless, this may not make much difference.  To figure out the Chief's total chance of winning, we'll give them all of their regular season wins and have them win half of the games that go to overtime:

```r
P(chiefs_margin>0)+0.5*P(chiefs_margin==0)
```
According to this method, the Chiefs have a 45.5% chance of winning the game.  Does this seem reasonable?

**Question 1**
Using the "chiefs_margin" random variable we created, estimate the Chief's chance of winning by 10 or more points.


# 2. Similar Games

Our first method was highly theoretical.   Perhaps we should try something more empirical (meaning based more closely on the data).  We can look at similar games and see how they turned out.

Let's start by loading data on a large number of games:

```r

View(games)
```

This "games" dataframe you just created contains information on all NFL games between 1999 and 2021 (inclusive).  

To find similar games, I'm going to find all games where one team was favored by 1.5 points.

```r
library(tidyverse)

similar_games = 
games %>% 
  filter(spread_line == -1.5 | 
        spread_line == 1.5)

View(similar_games)
```
There have been 137 games with the same spread as this year's Super Bowl.

We can first do a quick check on our previous estimate of how likely this game is to go into overtime.  What proportion of these games went to overtime:

```r
mean(similar_games$overtime)
```

When the spread is -1.5 it means the first team listed (typically the away team) is favored by 1.5 points and when the spread is 1.5 it means that the other team is favored to win.

How often does the underdog win?  For that we need to also use the "result"" column.  The result column shows the margin of victory for the second team listed (or if it's negative, the margin of loss).  So, the favorite won whenever spread_line and result have the same sign and the underdog won whenever spread_line and result have different sign (or put another way, whenver the product of spread_line and result is negative).

The following calculation shows how often the underdog won in these 137 games:

```r
similar_games %>% 
  summarize(sum(spread_line*result < 0))
```
and we can also calculate this as a propotion:

```r
similar_games %>% 
  summarize(mean(spread_line*result < 0))
```

The underdog has won 68 out of 137 of these games.  That's *very* slightly less than half.  Does this mean that the Chiefs are essentially a coin flip to win?

# 3. A Normal Curve

Perhaps 137 games is too few games on which to form a firm conclusion.  Let's instead use all of the games.

For each game, I'm going to calculate the difference between the actual result and the spread and call it "miss".

```r
games = 
  games %>% 
  mutate(miss = result - spread_line)
```

Let's make a histogram of the misses:

```r
hist(games$miss, breaks=seq(-80, 80, 4))
```

These misses look roughly normally distributed.  Let's find the mean and standard deviation of this distribution.

```r
games %>%
summarize(
  mean_miss = mean(miss),
  sd_miss = sd(miss)
)
```

The mean miss is very close to zero, as it should be, meaning that misses are roughly equally likely to be in either direction.  If this weren't true, it would mean that we found a bias in the spread which perhaps we could take advantage of. The standard deviation, of 13 points, is perhaps, more telling.  If the misses really are normally distributed this would be that ~68% of the time, the spread is different from the results by 13 points of less.

Let's find out how often this happens in reality.  I'll check the proportion of games in which the absolute value of the miss is less than 13.3

```r
games %>%
  summarize(
  mean(abs(miss) < 13.3) 
  )
```

It's not perfect, but it's not terrible.

For the Chiefs to win, they need to outperform the spread by more than 1.5 points.  To figure out how likely this is, we can start by finding the z-score of 1.5 points of miss.

```r
z_chiefs_win = (1.5 - 0)/13.3

z_chiefs_win
```

The z score tells us that the Chiefs need to do .113 standard deviations better than expected.  How often does that happen?  You could use your paper standard normal table here but R will also do this for us:

```r
1 - pnorm(.1128)
```

According to this model, the Chiefs have a 45.5% chance of victory... which is actually the same number we came up with using random variables.

*More Questions:*

2. Which of these methods do you think is the best?  Which is the worst?  Please explain.

3. Imagine that in next year's Super Bowl, one team is favored by 7 points.  What do you think is the underdog's chance of winning that game?  (Try using one of thse methods to answer that question.)

4. For the second and third method which were based on data, do you think it would be useful to limit the analysis to only Super Bowl games?  Why or why not?
