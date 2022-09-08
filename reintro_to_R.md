01 Re-Introduction to R
================
Advanced Statistics

With parts taken from [Regression and Other Stories](https://users.aalto.fi/~ave/ROS.pdf)


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

# ifelse

Comparisons can be used in combination with the ifelse function. The first argument takes a
logical statement, the second argument is an expression to be evaluated if the statement is true, and
the third argument is evaluated if the statement is false. Suppose we want to pick a random number
between 0 and 100 and then choose the color red if the number is below 30 or blue otherwise:

```r
number <- runif(1, 0, 100)
color <- ifelse(number<30, "red", "blue")
```

# Reading in Data 
(titanic)

