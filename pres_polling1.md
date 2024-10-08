Examining Presidential Election Polling Data
----------------------------------------------

The website, fivethirtyeight.com maintains up to date presidential election polling data [here](https://github.com/fivethirtyeight/data/blob/master/polls/README.md).

We can read their polling data directly into an R data.frame by doing the following:

```r
pres_polls = read.csv("https://projects.fivethirtyeight.com/polls-page/data/president_polls.csv")
```

Then we can view the data using:

```r
View(pres_polls)
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
pres_polls = 
  pres_polls %>% 
    select(poll_id, pollster_id, pollster, 
    numeric_grade, pollscore, methodology, 
    state, start_date, end_date, question_id, 
    sample_size, population, partisan,party, 
    answer, candidate_id, candidate_name, pct)
    
View(pres_polls)
```

The next thing I want to do is to tell R what types of data it's dealing with. Some of these variables, like "population" are *factor* variables, which is another term for a categorical variable.  The *populations* of these polls are are either "a" (adults), "lv" (likely voters), "rv" (registered voters) or "v" (voters, I believe).

There are also two columns, "start_date" and "end_date" which contain dates (of when the poll was conducted) but R just treat these columns as strings of text unless we tell it that they are dates.  We'll tell R what it's dealing with use a variant of the *mutate* function as the functions "as.factor" and "as.Date":

```r
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

Now, take another look at the data.  You can use "View" again or try "summary" or "glimpse" as shown below:

```r
glimpse(pres_polls)

summary(pres_polls)
```

The formatting of the polling data might not be what you expect.  Each rows of data isn't a full poll.  Each row is one *response* from one poll, so each polls is represented by multiple rows -- one for each candidate.  The (now) final column, pct, shown the percentage of respondents who supported that candidate in the poll.  

One of the first things we might want to do is to remove polling data that didn't have Kamala Harris or Donald Trump as the candidate.  We can't just remove rows with the names of other candidates, since we don't want to use polling data on Trump from when he was competing against Biden.  So, let's find all polls where either Biden or Vance was listed as the candidate and remove all rows from those polls.

While we're at it, let's also going to remove polls that have populations other than likely voters, polls from before Biden dropped out of the race and partisan polls (which were funded by the Republican or Democratic party).  We'll use the *filter* verb to make this happen:

```r
polls_to_remove = 
pres_polls %>%
  filter(candidate_name == "JD Vance" |
           candidate_name == "Joe Biden") %>%
  pull(question_id) %>%
  unique()
  
pres_polls = 
pres_polls %>%
  filter(partisan == "",
         start_date > "2024-07-21",
         population == "lv",
         !(question_id %in% polls_to_remove)) 
  
```
Now, let's calculate some averages!

Election predictions models are (mostly) just thoughtful weighted averages.  

# National Polls

Let's start by looking at national polls.  These are polls where the "state" column is blank.  We'll filter by state, group by candidate and find the number of national polls each candidate is in and there average vote share in those polls.  We'll also use the arrange function to sort candidates in descending order of vote share:

```r
pres_polls %>%
  filter(state == "") %>%
  group_by(candidate_name) %>%
  summarize(num_polls=n(), 
            avg_vote = mean(pct)) %>%
  arrange(desc(avg_vote))

```

You may notice that these numbers add up to more than 100% !  This is made possible by the fact that the 3rd though 6th candidates shown aren't included in most polls and these are their average percentages in the polls in which they are included.  If you're so inclined, you can remove polls that include these candidates in the same way that we removed polls that include Biden or Vance.

# State Polls

Let's look at Pennsylvania, which some believe is the state most likely to swing the election.  We can do this with just a slight alteration to the code we used above:

```r
pres_polls %>%
    filter(state == "Pennsylvania") %>%
    group_by(candidate_name) %>%
    summarize(num_polls=n(), 
              avg_vote = mean(pct)) %>%
    arrange(desc(avg_vote))

```

Try finding polling averages for a couple of other states.

If you're interested in how much poll results vary, you also find the standard deviation in each candidate's polling results:

```r
pres_polls %>%
  filter(state == "Pennsylvania") %>%
  group_by(state, candidate_name) %>%
  summarize(num_polls=n(), 
            avg_vote = mean(pct),
            sd_vote = sd(pct)) %>%
  arrange(desc(avg_vote))

```

# Weighted Averages?

Maybe some polls should get more weight than others.  We could give more weight to recent polls, to polls from higher quality pollsters, to polls with larger sample sizes or base our weights on a combination of these factors as well as others.  Let's try weighting polls based on their sample size (because that is relatively straight forward).  We'll need to filter out polls where the sample_size column is NA (missing).

```r
pres_polls %>%
  filter(state == "",
      !is.na(sample_size)) %>%
  group_by(candidate_name) %>%
  summarize(num_polls=n(), 
            weighted_avg_vote = 
            sum(pct*sample_size)/sum(sample_size)) %>%
  arrange(desc(weighted_avg_vote))

```

# Write down your Ideas

What other factors would you want to consider if you were using polls to make an election prediction?  Would you like to eliminate some polls that we have included or include some polls that we've eliminated?  Would you like to use a weighted average?  What factors would you like to use to make your weights?  Please write down a couple of thoughts that you could share in class to help us improve our analysis for a follow-up lab.