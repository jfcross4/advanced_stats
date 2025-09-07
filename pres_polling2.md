Presidential Election Polling Data... Lab 2
----------------------------------------------

Let's once again read in polling data collected by fivethirtyeight.com.

We can read their polling data directly into an R data.frame by doing the following:

```r
library(tidyverse)

pres_polls = read.csv("https://projects.fivethirtyeight.com/polls-page/data/president_polls.csv")

View(pres_polls)
```

This data has been updated since we last used it so even if we ran the same code as last time, we'd get different results.  This week, I want you to be sure to save your code in an R script.  Then you can run this code again next Tuesday morning (election day) to make up-to-date predictions.

Let's clean the data in the same way we did a couple of weeks ago:

```r
pres_polls = 
pres_polls %>% 
  select(poll_id, pollster_id, pollster, numeric_grade, pollscore,
         methodology, state, start_date, end_date, question_id,
         sample_size, population, partisan, party, answer,
         candidate_id, candidate_name, pct)

factor_variables = 
  c("poll_id", "pollster_id", "pollster", "methodology", 
    "state", "population",
    "partisan", "party", "answer", "candidate_id",
    "candidate_name")

date_variables = c("start_date", "end_date")


pres_polls = pres_polls %>%
  mutate_at(factor_variables, as.factor) %>%
  mutate_at(date_variables, as.Date,
            tryFormats = c("%m/%d/%y"))

```

However, this time, we'll rearrange the data so that instead of having one row for each *poll response* we'll have one row for each poll and one column for each response.  

```r
pres_polls_wider = 
pres_polls %>%
  filter(answer %in% c("Trump", "Harris", "Stein", "Oliver",
                       "West", "Kennedy")) %>%
  pivot_wider(
    id_cols = poll_id:partisan,
    names_from = answer,
    values_from = pct
  )
```

Take a look at "pres_polls_wider" to make that you understand what we've done:

```r
View(pres_polls_wider)
```

Let's remove polls where Trump or Harris were missing as well as old polls and partisan polls:

```r
pres_polls_wider = 
  pres_polls_wider %>%
  filter(partisan == "",
         start_date > "2024-07-21",
         population == "lv",
         !is.na(Harris),
         !is.na(Trump))
```

Next, let's add columns where we calculate the two-party vote share for the leading candidates.  One advantage of using two-party vote share is that if a candidate is over 50%, they were winning in the poll and, if not, they were losing.

```r
pres_polls_wider = 
pres_polls_wider %>%
  mutate(
    Harris_share = Harris/(Harris + Trump),
    Trump_share = Trump/(Harris + Trump)
  )
```

Finally, let's look at the average two-party vote shares in National polls:

```r
pres_polls_wider %>%
  filter(state == "") %>%
  summarize(num_polls=n(), 
            avg_Harris = mean(Harris_share),
            avg_Trump = mean(Trump_share))
```

and we can use ggplot to look at how those polls have changed over time:

```r
pres_polls_wider %>%
  filter(state == "") %>%
  ggplot(aes(start_date, Harris_share), col="blue") +
  geom_smooth()
```

We can do the same analyses for individual states.  For instance, here's Pennsylvania:

```r
pres_polls_wider %>%
  filter(state == "Pennsylvania") %>%
  summarize(num_polls=n(), 
            avg_Harris = mean(Harris_share),
            avg_Trump = mean(Trump_share))

pres_polls_wider %>%
  filter(state == "Pennsylvania") %>%
  ggplot(aes(start_date, Harris_share), col="blue") +
  geom_smooth()       
            
```

# Weighting Polls

In this section, I want you to use your own creatively.  I'll walk through a system for weighting polls but you may want to alter the system to create your own weights.

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

538 assigns grades to pollsters based on their estimated quality.  The highest grade is 3.0 and the lowest is 0.5.  I'll simply weigh polls by the pollster quality.

## Putting it all together

In order to have a good weight, a poll will need to be recent, have a good sample size and a quality pollster.  I'll try to achieve this by making the overall weight the product of three factors:

$$ overall\ wt = 
      recency\ wt \cdot sample\ size\ wt \cdot poll\ quality\ wt $$

Here's R code to achieve all this:

```r
pres_polls_wider = 
pres_polls_wider %>%
  mutate(
    days_ago = as.numeric((Sys.Date() - 
      end_date)),
    recency_weight = .95^days_ago,
    sample_size_weight = 
      sample_size/(1000 + sample_size),
    poll_quality_weight = numeric_grade,
    overall_weight = 
      recency_weight*sample_size_weight*poll_quality_weight
  ) %>% 
  filter(!is.na(overall_weight))
```

Remember, I'm encouraging to devise your own system of weights.  You don't need to use mine.

Now, let's see the weighted average of the polls both nationally and in Pennsylvania using our new weights:

```r
pres_polls_wider %>%
  filter(state == "") %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris_share*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump_share*overall_weight)/
              sum(overall_weight))

pres_polls_wider %>%
  filter(state == "Pennsylvania") %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris_share*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump_share*overall_weight)/
              sum(overall_weight))
```

We could also get the weighted average of a number of swing states all at once:

```r
swing_states =
  c("Pennsylvania",
    "Michigan",
    "Wisconsin",
    "Nevada",
    "Georgia",
    "North Carolina",
    "Arizona")

pres_polls_wider %>%
  filter(state %in% swing_states) %>%
  group_by(state) %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris_share*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump_share*overall_weight)/
              sum(overall_weight)) %>%
  arrange(desc(avg_Harris))
```

# To Do

After devising your system of weights, save all of the code that you used to get a weighted average for each swing state in an R script.  Write comments (lines that start with #) briefly describing what each section of code does.  Next Tuesday, you can return to this code and re-create your weighted averages using the last week of polling data.