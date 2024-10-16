05 Binomial Random Variable Lab
-------------------------------------

# Soccer Player Birthdays

Researchers recorded the birth months of 2,768 elite youth soccer players (on youth teams in the Spanish Professional Football League) from 2008-2009.  They found that 1,024 of them were born in the first 3 months of the year.  

<a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3761747/" target="_blank">Journal Article Here</a>

If players were equally likely to be born in each month, we'd expect a quarter of players (or 692 players) to be born in the first three months of the years.  1,024 is clearly larger than 692!  Our question is whether it's so much greater that *something* must be going on here.

Let's try to answer this question using a binomial random variables!

In the language of binomial random variables we had 1024 successes in 2,768 independent trials (assuming none of the players were twins).

We can use dbinom to tell us the chance of exactly 1024 successes in 2768 trials with a 0.25 chance of success.

```r
dbinom(1024, 2768, prob=0.25)
```

That's pretty small!

Of course, we should compare it to something.  Here's the chance of 692 successes in 2768 trials also given a 0.25 chance of success.

```r
dbinom(692, 2768, prob=0.25)
```

That's small, but not nearly so small!  In fact, it's many (many many) times larger.

```r
dbinom(692, 2768, prob=0.25)/dbinom(1024, 2768, prob=0.25)
```

Another way to think about this is to determine how likely it is we'd have 1024 *or more* births in the first 3 months if player's only had a 25% chance of being born in those months.  To do this, we'll find the chance of every number of successes between 1024 and 2768 and add them all up:

```r
sum(dbinom(1024:2768, 2768, prob=0.25))
```

This (also really small) number is called a p-value.  The (at times dubious) logic sometimes used is that if this number of successes (or more) is very unlikely given a p of 0.25 then p is really unlikely to be 0.25 (or something very close to that).

# Extrasensory Perception (ESP)

Daryl Bem, a Cornell psychology, professor, tested the ability of students to identify which of two curtains hid an erotic image.  The images were randomly assigned to curtains, so we might expect students to succeed half the time.  And yet, out of 1600 guesses (16 guesses from each of 100 different students), 850 guesses were correct.

<a href="https://psycnet.apa.org/buy/2011-01894-001" target="_blank">ESP Article Here</a>

**Task 1:** Analyze this data using the techniques we used to analyze the birth months of soccer players (as well as any other calculations you think are relevant) and report on your results.


# Comparing Two Proportions

Did having a sibling or spouse on board make adults more likely to survive on the Titanic?


Let's first read in our favorite data set:
```r
titanic = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/titanic_train.csv")
```

Then take a look at the numbers:

```r
library(dplyr)

titanic %>% filter(Age>=18) %>% group_by(SibSp>=1) %>% summarize(n=n(), NumSurvived = sum(Survived), SurvivalRate=mean(Survived))
```
Our training set contains 428 adults without a spouse or sibling on board of whom 147 (or 34.3%) survived and 173 adults riding with at least one spouse of sibling or whom 82 (or 47.4%) survived.

So, at first blush, having a sibling helped!  But, might this be a fluke?  Could we easily see a difference this large just by chance (even if folks with spouses/siblings were no more likely to survive)?

Let's look at the overall numbers:

```r
titanic %>% filter(Age>=18) %>% summarize(n=n(), NumSurvived = sum(Survived), SurvivalRate=mean(Survived))
```

There are 601 adult passengers (in this sample) and 229 (or 38.1%) survived.  Let's pretend that both adults with siblings/spouses and folks without had a 38.1% chance of survival, how often would we see a difference between groups as large as the 47.4%-34.3% = 13.1% difference in survival rates?

Let's find out by simulating 1000 titanics!  On each titanic, we'll give each of the 428 adults without a spouse or sibling and each of the 173 adults riding with at least one spouse of sibling a 38.1% chance of survival and look at the difference in survival rates between groups.

```r
loners_survived = rbinom(1000, 428, 0.381)
sibsp_survived = rbinom(1000, 173, 0.381)

loner_survival_rate = loners_survived/428
sibsp_survival_rate = sibsp_survived/173

difference_in_survival_rate = sibsp_survival_rate - loner_survival_rate

hist(loner_survival_rate)

hist(sibsp_survival_rate)

hist(difference_in_survival_rate)
```

How often does the SibSp group out survive the "loner" group by the 13.1% we saw in the data (or more)?

```r
mean(difference_in_survival_rate>0.131)
```

Not often!  (You can run more simulations if you want a more precise number)  This is called a one-tailed p-value because it's the chance of getting a result this extreme or more extreme in one direction.  If we want to know how often we'd see a 13.1% survival but one of the two groups we can calculated a two-tailed p-value as:

```r
mean(abs(difference_in_survival_rate)>0.131)
```

**Task 2:** Analyze whether we can be confident that children with a sibling on board had a better chance of survival.  You can modify code used above.  Explain your findings.



# Was Kobe Bryant Streaky (and thus not just a binomial random variable)?

We'll try to answer this by looking at shots Kobe took during the 2009 NBA Finals.  (I should acknowledge that if we were seriously investigating this question we'd both want to use data from throughout Kobe entire career and attempt to control for the difficulty of the shots Kobe was taking.)

```r
kobe = readRDS(url("https://github.com/jfcross4/advanced_stats/blob/master/kobe_basket.rds?raw=true"))

View(kobe)
```

I'm really only interested in whether Kobe made the shot, so I'm going to grab that column of hits and misses ("H"'s and "M"'s) and discard the rest:

```r
shots = kobe$shot
table(shots)
```
Kobe made 58 shots and missed 75.  

```r
mean(shots=="H")
```

Put another way, he made 43.6% of his shots...
but how did he do after makes and after misses.  

He took 133 shots, and we can use the following code to get the numbers of the shots he made:

```r
which(shots=="H")
```

The code above tells use that Kobe made his 1st, 4th and 5th shots and must have missed his 2nd and 3rd shots of the series.

Let's get the numbers of shots that followed hits and the numbers of shots that followed misses:

```r
shots_after_hits = which(shots[-133]=="H")+1
shots_after_misses = which(shots[-133]=="M")+1

shots_after_hits; shots_after_misses
length(shots_after_hits); length(shots_after_misses)
```

Kobe had 57 shots following hits (not 58 because one of his hits was his final shot) and 75 shots following misses.  How often did he make each kind of shot?

```r
sum(shots[shots_after_hits]=="H")
mean(shots[shots_after_hits]=="H")
```

He made 21 (36.8%) of his shots after makes.

```r
sum(shots[shots_after_misses]=="H")
mean(shots[shots_after_misses]=="M")
```

He made 36 (52.0%) of his shots after misses.

**Task 3:** Are we confident that Kobe was really a better shooter after misses or could this easily be a fluke?  Try using an analysis similar to the Titanic analysis above (or something else if you prefer!) to answer this question.

# Buy Low, Sell High

The following data set describes whether Apple stock went up on every day trading day between January 1st, 2000 and October 11th, 2022.

```r
apple = readRDS(url("https://github.com/jfcross4/advanced_stats/blob/master/apple.rds?raw=true"))
```

```r
mean(apple)
```

We can see that Apple stock when up on 53.5% of days.

Let's find the days that followed an up day and the days that followed a down day:


```r
days_after_up = which(apple[-5730]==TRUE)+1
days_after_down = which(apple[-5730]==FALSE)+1
```

**Task 4:**  Is Apple Stock streaky?  Or does Apple have a tendency to bounce back after a down day?  Try using an analysis similar to what you used to analyze Kobe's shooting.
