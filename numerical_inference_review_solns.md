Numerical Inference Review Solutions
-------------------------------------------

1. 

$H_0$ = students have a true mean score of 75
$H_A$ = students have a true mean not equal to 75

Using a one-sample t-test for whether the mean is consistent with 75.

```r
mean(scores) #78.08

t.test(scores, mu=75, alternative = "two.sided")
```

* df = 29
* t = 3.89
* p-value = 0.0005356

Due to the small p-value, we can say this data is not consistent with the null hypothesis of a mean of 75 and reject the null hypothesis.  We believe that there is a difference for those taught with the new method.

2. 

$H_0$ = no different in treatment and control sleep amounts
$H_A$ = treatment sleep > control sleep

Since, these are the same people in the two conditions we'll use a *paired* test test.

One way:

```r
diffs = treatment_sleep - control_sleep
t.test(diffs, mu=0, alternative = "greater")
```

Another way:

```r
t.test(treatment_sleep, 
      control_sleep, 
      paired=TRUE, 
      alternative = "greater")
```

* df = 19
* t = 10.5
* p-value = 1.91e-09

Due to the (very) small p-value, we can say this data is not consistent with the null hypothesis of no different between treatment and control and reject the null hypothesis.  

3. 

$H_0$ = no different in mean productivity increase between groups
$H_A$ = mean productivity increases are not the same

Using a two-sample (unpaired) t-test for difference in the means.

```r
t.test(productivity_increase_A, 
        productivity_increase_B,
        alternative="two.side")
```

* df = 36.8 (this uses that ugly formula, but we knew that it would be between 19 and 38)

* t = -0.82 (or +0.82 if you swapped groups A and B)
* p-value = 0.42

We cannot reject the null hypothesis that there is no different in mean productivity increase between the groups.

4. 

$H_0$ = no different in mean exam scores between groups
$H_A$ = mean exam scores not the same

Using a two-sample (unpaired) t-test for difference in the means.

```r
se_a = 8/sqrt(90)

se_b = 10/sqrt(105)

se_diff = sqrt(se_a^2 + se_b^2)

t_score = (80-78)/se_diff
t_score

# p-value.. 
# the number of degrees of freedom must be
# between 89 and 193
2*(1- pt(t_score, df=89))
2*(1- pt(t_score, df=193))
```

* df between 89 and 193
* t = 1.55
* p-value = 0.125

We cannot reject the null hypothesis that there is no different in exam scores between the groups.
