Examining Senate Election Polling Data
----------------------------------------------

The New York Times maintains up to date polling data [here](https://www.nytimes.com/interactive/polls/senate-polls-2026.html?eafs_enabled=false).

We can read their senate polling data directly into an R data.frame by doing the following:

```r
polls = read.csv("https://www.nytimes.com/newsgraphics/polls/senate.csv")
```

Then we can view the data using:

```r
View(polls)
```

In this lab, we'll write code to examine this data and even make simple election predictions... and here's the good news.  In the future we can simply rerun the same code starting with the line above to run the data.  Since our data set updates on its own (or at least we don't have to update it), when we run the same code in the future, we'll get an updated analysis.  If we wanted to, we could use R to make a website that uses this data and create a forecasts and consistently updates the forecast as new polling data comes in, without ever changing our code.

# dplyr tools

In this lab, we'll make use of some of the "dplyr" tools we've started to learn on DataCamp and my hope is that this will serve as a review.  I'll also introduce some new functions/"verbs" that we'll need to analyze the data.

Here are some of the dplyr verbs we'll use.  Try to remind yourself what each verb does before moving on:

* select
* filter
* arrange
* mutate
* group_by
* summarize

# Examining the Data

First, to use all of these tools, we need to load the tidyverse package:

```r
library(tidyverse)
```

This data set is somewhat large and has more than 50 columns so R won't show it all to you at once.  Some columns that might be useful to us later contain information that we can ignore for now.  Let's slim down the data set to make it easier to look at.  We'll do this by using the select function.

```r
polls = 
  polls %>% 
    select(poll_id, pollster_id, pollster, 
    numeric_grade, pollscore, methodology, 
    state, start_date, end_date, question_id, 
    stage,
    sample_size, population, partisan,party, 
    answer, candidate_id, candidate_name, pct)
    
View(polls)
```

The next thing I want to do is to tell R what types of data it's dealing with. Some of these variables, like "population" are *factor* variables, which is another term for a categorical variable.  The *populations* of these polls are are either "a" (adults), "lv" (likely voters), "rv" (registered voters) or "v" (voters, I believe).

There are also two columns, "start_date" and "end_date" which contain dates (of when the poll was conducted) but R just treat these columns as strings of text unless we tell it that they are dates.  We'll tell R what it's dealing with use a variant of the *mutate* function as the functions "as.factor" and "as.Date":

```r
factor_variables = 
  c("poll_id", "pollster_id", "pollster", "methodology", 
    "state", "population",
    "partisan", "party", "answer", "candidate_id",
    "candidate_name", "stage")

date_variables = c("start_date", "end_date")

polls = polls %>%
  mutate_at(factor_variables, as.factor) %>%
  mutate_at(date_variables, as.Date,
            tryFormats = c("%m/%d/%y"))

```

Now, take another look at the data.  You can use "View" again or try "summary" or "glimpse" as shown below:

```r
glimpse(polls)

summary(polls)
```

The formatting of the polling data might not be what you expect.  Each rows of data isn't a full poll.  Each row is one *response* from one poll, so each polls is represented by multiple rows -- one for each candidate.  The (now) final column, pct, shown the percentage of respondents who supported that candidate in the poll.  

Let's remove polls from too long ago and polls that have populations other than likely voters.  We'll use the *filter* verb to make this happen:

```r
polls = 
polls %>%
  filter(partisan == "",
         start_date > "2026-07-21",
         population == "lv",
         stage == "general",
         party %in% c("DEM", "REP")) 
  
```
Now, let's calculate some averages!

Election predictions models are (mostly) just thoughtful weighted averages.  

# State Polling Averages

Let's start by looking at national polls.  These are polls where the "state" column is blank.  We'll filter by state, group by candidate and find the number of national polls each candidate is in and there average vote share in those polls.  We'll also use the arrange function to sort candidates in descending order of vote share:

```r
polling_averages = 
polls %>%
  group_by(state, candidate_name) %>%
  summarize(num_polls=n(), 
            avg_vote = mean(pct),
            party = first(party)) %>%
  arrange(state, desc(avg_vote))
  
View(polling_averages)

```

# State Polls

Let's look at Maine.  We can do this with just a slight alteration to the code we used above:

```r
polls %>%
    filter(state == "ME") %>%
    group_by(candidate_name) %>%
    summarize(num_polls=n(), 
              avg_vote = mean(pct)) %>%
    arrange(desc(avg_vote))

```

Try finding polling averages for a couple of other states.

If you're interested in how much poll results vary, you also find the standard deviation in each candidate's polling results:

```r
polls %>%
  filter(state == "ME") %>%
  group_by(state, candidate_name) %>%
  summarize(num_polls=n(), 
            avg_vote = mean(pct),
            sd_vote = sd(pct)) %>%
  arrange(desc(avg_vote))

```

# Weighted Averages?

Maybe some polls should get more weight than others.  We could give more weight to recent polls, to polls from higher quality pollsters, to polls with larger sample sizes or base our weights on a combination of these factors as well as others.  Let's try weighting polls based on their sample size (because that is relatively straight forward).  We'll need to filter out polls where the sample_size column is NA (missing).

```r
polls %>%
  filter(state == "ME",
      !is.na(sample_size)) %>%
  group_by(candidate_name) %>%
  summarize(num_polls=n(), 
            weighted_avg_vote = 
            sum(pct*sample_size)/sum(sample_size)) %>%
  arrange(desc(weighted_avg_vote))

```

# Improving your Election Prediction

What other factors would you want to consider if you were using polls to make an election prediction?  Would you like to eliminate some polls that we have included or include some polls that we've eliminated?  Would you like to use a weighted average?  What factors would you like to use to make your weights?  Please investigate one state and make a prediction for that state's result.  Here are some things to consider:

## Recency

We might want to give more recent polls more weight.  I'll make a poll receive 5% less weight for every day since it was conductive using the following formula:

$$recency\ weight = .95^{days\ ago}$$

This means that a poll that is two weeks old will receive roughly half as much weight as a poll that was just conducted:

```r
.95^14
```

## Sample Size

We might want polls with more respondents to receive more weight.  Sample size has diminish returns, however (as we'll see), and a poll of thousands of people could still be biased.  So, instead of letting weights get larger and larger with sample size, I'll use the following formula:

$$ sample\ size\ weight = 
      \frac{sample\ size}{1000 + sample\ size} $$
      
According to the formula, the sample size weight can never be larger than 1 regardless of the size of the poll.  It could be near zero for a very small poll and would be 0.5 for a poll with 1000 respondents.

## Poll Quality

We could look at which pollsters were most accurate historical and give more weight to pollsters with a good track record.  Unfortunately, this is more than we can accomplish in one day.


## Putting it all together

In order to have a good weight, a poll will need to be recent and have a good sample size.  I'll try to achieve this by making the overall weight the product of two factors:

$$ overall\ wt = 
      recency\ wt \cdot sample\ size\ wt $$

Here's R code to achieve all this:

```r
polls = 
polls %>%
  mutate(
    days_ago = as.numeric((Sys.Date() - 
      end_date)),
    recency_weight = .95^days_ago,
    sample_size_weight = 
      sample_size/(1000 + sample_size),
    overall_weight = 
      recency_weight*sample_size_weight
  ) %>% 
  filter(!is.na(overall_weight))
  
polls %>%
  filter(state == "ME") %>%
  group_by(candidate_name) %>%
  summarize(num_polls=n(), 
            weighted_avg_vote = 
            sum(pct*overall_weight)/sum(overall_weight)) %>%
  arrange(desc(weighted_avg_vote))
```
