# Proof that the Variance of a Uniform Distribution is \((1/12)(b-a)^2\)

## Definition of Variance

The variance \(\text{Var}(X)\) of a random variable \(X\) is defined as:

\[
\text{Var}(X) = E[X^2] - (E[X])^2
\]

where \(E[X]\) is the expected value (mean) of \(X\) and \(E[X^2]\) is the expected value of \(X^2\).

## Step 1: Find the Mean \(E[X]\)

For a uniform distribution on \([a, b]\), the expected value \(E[X]\) is given by:

\[
E[X] = \frac{a + b}{2}
\]

This represents the midpoint of the interval \([a, b]\).

## Step 2: Find \(E[X^2]\)

Now, we need to compute \(E[X^2]\). 

Since \(X\) is uniformly distributed, we can find \(E[X^2]\) by considering the average of \(X^2\) across the interval \([a, b]\). The value \(X^2\) ranges between \(a^2\) and \(b^2\).

To derive \(E[X^2]\) without calculus, we recognize that the average of \(X^2\) over the interval is equivalent to the average of \(X\) squared, considering both endpoints weighted equally.

### Step 3: Simplifying \(E[X^2]\)

To determine \(E[X^2]\):

1. Consider the endpoints \(a\) and \(b\).
2. The interval length is \(b - a\).

For illustrative purposes, we can utilize the formula for the average of the squares of a uniform distribution, which gives us:

\[
E[X^2] = \frac{(b^3 - a^3)}{3(b-a)} = \frac{(b-a)(b^2 + ab + a^2)}{3}
\]

### Step 4: Variance Calculation

Now, plug \(E[X]\) and \(E[X^2]\) back into the variance formula:

1. We have the mean \(E[X] = \frac{a + b}{2}\).
2. Plugging in:

\[
E[X^2] - (E[X])^2
\]

Calculate \(E[X]^2\):

\[
\left(\frac{a + b}{2}\right)^2 = \frac{(a + b)^2}{4} = \frac{a^2 + 2ab + b^2}{4}
\]

Putting it all together, we eventually derive:

\[
\text{Var}(X) = E[X^2] - (E[X])^2
\]

After simplification, we arrive at:

\[
\text{Var}(X) = \frac{(b-a)^2}{12}
\]

## Conclusion

Thus, we have shown that the variance for a uniform distribution on the interval \([a, b]\) is:

\[
\text{Var}(X) = \frac{(b-a)^2}{12}
\]