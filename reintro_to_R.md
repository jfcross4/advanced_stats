01 Re-Introduction to R
================
Advanced Statistics

With parts taken from [Regression and Other Stories](https://users.aalto.fi/~ave/ROS.pdf)

# Using R as a calculator

R can be used for computation, data manipulation, visualizations and simulations (among other things) but, mostly simply, R can be used like a calculator.

The following are some common arithmetic operators (symbols) you can use in R:

* add using +
* subtract using -
* divide using /
* multiply using *
* exponentiate using ^
    ...and many more!

Type the following lines into the console below, and hit "return" after each expression like you would on a calculator.

```r
3*2
4^2
5/2
5 %/% 2
5 %% 2
5*(3+7)^2
sqrt(25)
25^(1/2)
```

**Question 1: How are /, %/% and %% different from each other? Try some computations to find out!**

# Assignment

The assignment operator "<-" is the same as "="

```r
x <- 3
print(x)

y = 12
print(y)

```

This is different from "==" which compares values and returns TRUE if they are equal and false if they are not

```r
x == 4
x == 3
```

You can also make comparisons with ">", "<", ">=" and "<="

```r
x < 3
x <= 3
```


# Creating Vectors

The function c() concatenates numbers together into a vector.

```r
x <- c(4,10,-1,2.4)
print(x)

x == 4
```

You can also create vectors in other ways.

```r
1:5

seq(-1, 9, 2)

c(1:5, 1, 3, 5)

c(1:5, 10:20)

2*(1:5)

2*(1:5) < 5
```

**Challenge 1: Make a sequence from 1 through 10.**

**Challenge 2: Square this entire sequence to create a sequence of the first 10 perfect squares.**

**Challenge 3: Create a sequence of 10 powers of 2 (eg. 2, 4, 8 ...)**


# Sampling

Here’s how to get a random number, uniformly distributed between 0 and 100:

```r
runif(1, 0, 100)
```

And now 50 more random numbers:

```r
runif(50, 0, 100)
```
Suppose we want to pick one of three colors with equal probability:

```r
color <- c("blue", "red", "green")
sample(color, 1)
```

Or suppose we want to sample with unequal probabilities:

```r
color <- c("blue", "red", "green")
p <- c(0.5, 0.3, 0.2)
sample(color, 1, prob=p)
```

# Question: What is the difference between the following two sections of code?

```r
# section 1
color <- c("blue", "red", "green")
p <- c(0.8, 0.1, 0.1)
sample(color, 3, prob=p)
```

```r
# section 2
color <- c("blue", "red", "green")
p <- c(0.8, 0.1, 0.1)
sample(color, 3, prob=p, replace=TRUE)
```

# ifelse

Comparisons can be used in combination with the ifelse function. The first argument takes a
logical statement, the second argument is an expression to be evaluated if the statement is true, and
the third argument is evaluated if the statement is false. Suppose we want to pick a random number
between 0 and 100 and then choose the color red if the number is below 30 or blue otherwise:

```r
number <- runif(50, 0, 100)
color <- ifelse(number<30, "red", "blue")
print(color)
table(color)
```

# Sums and Means

Try the following (and pause to make sure that you understand what each line of code is doing):

```r
sum(1:100)

mean(1:100)

mean(runif(50, 0, 100))

2^(1:10)

2^(1:10) < 100

sum(2^(1:10) < 100)

```

# Simulation

Let's put some of these ideas together to simulation someone rolling two 6-sided dice 1000 times:

```r
red.die = sample(1:6, 1000, replace=TRUE)

red.die

blue.die = sample(1:6, 1000, replace=TRUE)

blue.die

total.of.two.dice = red.die + blue.die

table(total.of.two.dice)

hist(total.of.two.dice, 
  breaks=seq(1.5, 12.5, 1))
```

**Challenge: Try using R to simulate the possible sums of rolling 4 dice.**