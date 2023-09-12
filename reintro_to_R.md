01 Re-Introduction to R
================
Advanced Statistics

With parts taken from [Regression and Other Stories](https://users.aalto.fi/~ave/ROS.pdf)


# Assignment

The assignment operator "<-" is the same as "=".  Your first assignment is to use the assignment operator.

```r
x <- 3
print(x)

y = 12
print(y)

```

"=" is different from "==" which compares values and returns TRUE if they are equal and false if they are not.

```r
x == 4
x == 3
```

Try to predict the result of the following code before you run it:

```r

z = 4 == 8/2
print(z)

q = 4 == 6/2
print(q)

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
```

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

You can also randomly sample values from other distribution! For example, the number of heads in 100 coin tosses follows a binomial distribution with 100 opportunities each with 1/2 probability of success.  I can simulate the number of heads in 100 coin tosses by doing:

```r
rbinom(n=1, size=100, prob=1/2)
```

(If you run the line above multiple times, you will get different results.)

If you want 1000 simulations of 100 coin tosses, you can do:

```r
rbinom(n=1000, size=100, prob=1/2)
```

If I want to determine for each result whether there were 60 or more heads, I could do:

```r
rbinom(n=1000, size=100, prob=1/2) >= 60
```

And if I want to count up how many times there were 60 or more heads, I could do the following (since TRUE values count as 1's):

```r
sum(rbinom(n=1000, size=100, prob=1/2) >= 60)
```

If I simply want the true probability of a sequences of 100 coin flips having 60 or more heads, I could use dbinom instead of rbinom:

```r
sum(dbinom(60:100, size=100, 1/2))
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

# Reading in Data 

I've added data on some of the passengers on the titanic to an Advanced Stats Github page.  You can find it [here](https://github.com/jfcross4/advanced_stats/blob/master/titanic_train.csv)

This data is in .csv (comma separated values) form and you can read it into R as follows:

```r
titanic <- read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")
```

and then take as look at it as follows:

```r
View(titanic)
```

Here's a brief description of the variables


![](titanicdesc.png)

We'll be building models to explain and predict* who lived and who died.  How should we begin?  Which variables do you think will be the best predictors or who lived and who died?

*It's true, we already know!


