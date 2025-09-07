Titanic Numerical Inference Problem
---------------------------------------

1. Titanic 

Where people who survived the sinking of the Titanic on average younger than people who died?

First, get the data:

```r
install.packages("titanic")
library(titanic)
library(tidyverse)
View(titanic_train)
```

Next, let's get a vector of ages of survivors:

```r
ages_survived = 
  titanic_train %>% 
  filter(!is.na(Age), Survived==1) %>% 
  pull(Age)
  
  
ages_died = 
  titanic_train %>% 
  filter(!is.na(Age), Survived==0) %>% 
  pull(Age)
```

We can get the mean and standard deviation in the ages of survivors as follows:

```r
mean(ages_survived)
sd(ages_survived)
```

and the number of survivors (in this sample) as:

```r
length(ages_survived)
```

Questions:

1. Find the standard error in the mean age of survivors and the standard error in the mean age of those who died.

2. Find the difference between the mean age of survivors of the mean age of those who died.

3. Find the standard error in the difference between these means.

4. Calculate a t-score for the difference between these means relative to a null hypothesis of no difference between the means.

5. Calculate a p-value for the null hypothesis of no difference between the means using an alternative hypothesis that they are different ("two-sided").  Try this first using "pt" and then check your answer using "t.test"




