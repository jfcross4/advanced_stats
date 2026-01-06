Chi Square Goodness of Fit Lab
---------------------------------------------

In this lab, we'll use R to solve a couple of would-be homework problems.  We'll also review the ideas of test statistics, chi square and degrees of freedom.

## 1. A Fruit Tree Cross

In an experiment, two different species of fruit trees were crossbred. The resulting fruit from this crossbreeding experiment were classified by the color of the meat of the fruit and the color of the skin of the fruit, into one of four groups, as shown in the table below.

|Fruit Type Result | Number Observed  |
|---|---|
|I: Red meat with orange skin |65|
|II: Red meat with yellow skin |37|
|III: Yellow meat with orange skin |24|
|IV: Yellow meat with yellow skin |24|

A botanist expected that the ratio of 5:2:2:1 for the color types I: II: III: IV, respectively, would result from this crossbreeding experiment. 
Are the observed results inconsistent with the expected ratio at the 1 percent level of significance?

First let's calculate how many fruit the botanist expected in each category based on that 5:2:2:1 ratio...

```r
ratio_expected = c(5,2,2,1)

prop_expected = ratio_expected/sum(ratio_expected)

prop_expected

observed = c(65, 37, 24, 24)

total_observations = sum(observed)

expected = prop_expected*total_observations

expected
```
There are 150 total fruit trees and our botanist expects 75, 30, 30, and 15 in each the four categories.

## Alex

Next, it's time to calculate a test statistic!  
We could (and ultimately will) choose $\chi^2$ 
as our test statistic, but, for fun, let's first try to use 
"Alex" which we defined in class as:

$$Alex = \Sigma \frac{|observed - expected|}{\sigma_{expected}}$$

```r
sd = sqrt(total_observations*prop_expected*(1-prop_expected))

alex = sum(abs(observed-expected)/sd)

alex
```

Alex is 6.7!  Is that surprising according to our Botanist's null hypothesis?  

We don't know yet!

Let's simulate 150 fruit trees with a 5:2:2:1 ratio of falling into these categories:


```r
sample_fruits = 
sample.int(4, 150, replace=TRUE, prob=c(5,2,2,1))

sample_totals = table(sample_fruits)

sample_totals
```

Now, we can calculate "Alex" for the sample totals;

```r
sum(abs(sample_totals-expected)/sd)
```

Is the "Alex" for this sample smaller or larger than the "Alex" for the actual fruit trees?  (Note: everyone has a different simulation so your answer might differ from your neighbor's answer.)

Of course, one simulation isn't enough, let's do 10,000 simulations:

```r
simulated_alex_values = replicate(10000, 
{sample_fruits = sample.int(4, 150, replace=TRUE, prob=c(5,2,2,1))

sample_totals = table(sample_fruits)
sum(abs(sample_totals-expected)/sd)
}
)

```

and we can make a histogram of the simulation results:

```r
hist(simulated_alex_values)
```

What proportion of our simulated Alex values are at least 6.7 (the actual value)?

```r
mean(simulated_alex_values >= alex)
```
Not that many!  Only 1.3% (for me, your simulation might have turned out a bit differently!).  This is a p-value.  If the botanist is right, a result this far from their expectations (or further) should only happen 1.3% of the time, using "Alex" as a measure of that distance.

## Chi Square

Alex isn't the classic choice of test statistics here, chi square is!  Let's redo this analysis using a chi square test statistic.

$$ \chi^2 = \Sigma{ {\frac{(observed - expected)^2}{expected}}} $$

```r
chi_square = sum(((observed-expected)^2)/expected)
chi_square
```

chi_square is 9.57.  How often would this happen according to the botanist theory?

Let's first do this the hard way!  10,000 simulations!

```r
simulated_chi_square_values = 
replicate(10000, 
  {sample_fruits = 
  sample.int(4, 150, replace=TRUE, prob=c(5,2,2,1))

  sample_totals = table(sample_fruits)
  sum(((sample_totals-expected)^2)/expected)
})

mean(simulated_chi_square_values >= chi_square)
```
My simulation gives a p-value of 2.2%. Using the chi square test statistic results of the fruit tree cross seem slightly less surprising given the botanist theory than using the Alex test statistic.  

## An Easier Way

Since the distribution of chi-square is well understood, I don't have to run 10,000 simulations.  In this case our chi square distribution has 3 degrees of freedom (since there are 4 categories of fruit but the total number of observations is fixed at 150).  

We'll talk about degrees of freedom in class tomorrow but, for now, just know the the degrees of freedom is one less than the number of categories.

How often is chi square greater than 9.57 with 3 degrees of freedom? The "pchisq" function works like "pbinom" and tells me the percentile of a chi square value.  Since we want the chance that a value would be *greater than* 9.57 we'll do 1-pchisq:

```r
1 - pchisq(9.57, df=3) # to find the p-value
```

This 2.26% matches (or should nearly match) what we found with our simulation.

## An Even Easier Way

It's possible to make R do even more of the work and be even lazier!  We don't even have to calculate the chi square value ourselves.  We could just use the numbers and proportions from the original problem:

```r
ratio_expected = c(5,2,2,1)
observed = c(65, 37, 24, 24)
prop_expected = ratio_expected/sum(ratio_expected)

chisq.test(x = observed, 
  p = prop_expected)
  
```

*Are the observed results inconsistent with the expected ratio at the 1 percent level of significance?*

No!  2.26% > 1%, so while this would be significant at the 5% level it is not significant at the 1% level.

## 2. For the Birds

An ornithologist researching four bird species in Zilker Park of Austin, Texas is concerned that grackles are overtaking the habitat. Previous studies have shown that the proportions of the population including just these four species contains 8% parakeets, 16% warblers, 35% grackles, and 41% doves and the ornithologist is concerned that the proportion of grackles has grown since those earlier studies were conducted.

A team visited the park and randomly selected (this would be a challenge, but let’s pretend) 238 bird sightings of these four species with the results listed below.

|Species|Number|
|---|---|
|parakeets|20|
|warblers|33|
|grackles|100|
|doves|85|

Please analyze this data in light of the ornithologist's concerns.  

Does this data provide strong evidence that grackles have increased as a proportion of the bird population?  

**Try at least two of the methods described above** (you could use two different test statistics or just two methods of performing a chi square tests) and compare what you find.

## 3. Jelly Beans

A candy company claims that the distribution of colors in their bags of jelly beans is as follows:

30% Red
20% Green
20% Yellow
15% Blue
15% Orange
A customer suspects that the company's claim about the distribution is inaccurate. They purchase a large bag of jelly beans and count the colors of 94 randomly selected jelly beans. The observed counts are:

Red: 22
Green: 22
Yellow: 18
Blue: 15
Orange: 17

Using a significance level of 0.05, test whether the observed distribution differs significantly from the company's claimed distribution.