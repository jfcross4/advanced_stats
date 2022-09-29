04 Random Variables Lab
-------------------------------------

# Rolling the Dice

Let's making a random variable for rolling one die:

```r
values = 1:6
probs = rep(1/6, 6)

values
probs
```

We can get the expected value of this random variable:

$$E[X] = \Sigma x_i \cdot P(X=x_i)$$

```r
sum(values*probs)
```

and the variance of this random variables:

$$Var[X] = \Sigma (x_i - \mu_x)^2 \cdot P(X=x_i)$$

```r
EX = sum(values*probs)

sum(probs*(values-EX)^2)
```

We can do this even more easily using the discreteRV package for discrete random variables.

First, let's load the package (you may need to install it first) and create a die roll random variable.

```r
library(discreteRV)

X = RV(outcomes=1:6, probs=rep(1/6, 6))

X
```

Now, we can find the expected value, variance and standard deviation using functions in the discreteRV package.

```r
E(X)

V(X)

SD(X)

```

This package also have a nice function for making multiple *draws* from a random variable.  For instance, I might want to roll two dice and add up the results.  These two rolls are independent and identically distributed (iid, for short) meaning that one die roll tells us nothing about the other and the outcomes and their associated probabilities are the same.

Let's create a new random variable called "two_rolls" than the sum of two iid die rolls:

```r
two_rolls = SofIID(X, n=2)

two_rolls
```

We can also find the expected value and variance of this new two dice random variable.

```r
E(two_rolls)

V(two_rolls)
```

**Question 1:** How do the expected value and standard deviation of the sum of 100 rolls compare to the expected value and standard deviation of one roll?

# Plotting Discrete Random Variables

We can also plot each of these random variables with the possible values on the x-axis and their associated probabilities on the y-axis:

```r
plot(X)

plot(two_rolls)
```
**Question 2:** Try plotting the results of different numbers of die rolls (you can create these random variables using the SofIID function that you used above).  How do the shapes of these distributions compare?

# The Probabilities of Outcomes

If we rolls 100 dice, how often is the sum of the dice greater than 370?  We can answer this question by first creating a random variable of 100 die rolls:

```r
one_hundred_rolls = SofIID(X, n=100)
```

and then using the probability function:

```r
P(one_hundred_rolls > 370)
```

**Question 3:** How often would you roll a sum of more than 190 in 50 fifty die rolls?


Let's make a new random variable for one possession from each of two basketball teams.

```r
stanns = RV(outcomes=0:3, probs=c(0.55, 0.05, 0.3, 0.1))

packer = RV(outcomes=0:3, probs=c(0.6, 0.05, 0.2, 0.15))
```

Let's assume for now that all possessions in this game are independent and that in Saint Ann's v. Packer basketball each team has 70 possessions (in regulation).

```r
stanns_game = SofIID(stanns, n=70)

packer_game = SofIID(packer, n=70)
```

We can generate random variables for the total points scored in a game and for St. Ann's margin of victory (or loss) as follows.

```r
total = SofI(stanns_game, packer_game)

margin = SofI(stanns_game, -1*packer_game)
```

and we can plot the random variable that is Saint Ann's margin of victory as follows:

```r
plot(margin)
```

**Question 4:**

a. What is the expected value of St. Ann's' margin of victory?
b. What is the standard deviation in St. Ann's' margin of victory?
c. What is the chance that Saint Ann's will win (in regulation)?
d. What is the chance that the game will go to overtime?
e. Our model of reality (like all models) is imperfect in a number of ways.  Do you think a Saint Ann's/Packer basketball is more or less likely to go to overtime than our model predicts?  Why?

**Question 5:**

In NBA games, teams typically have about 100 possessions a piece and they score, on average, about 1.1 points per possession.  Using random variables, try to estimate the chance that an underdog will win a game in which the favorite is favored (expected to win) by 10 points.  Please describe how you made your estimate. 
