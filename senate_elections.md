Senate Elections (Advanced Stats)
----------------------------------------

# The dplyr Package

dplyr is a package for data manipulation.  If you want a pdf with a summary of dplyr's functions, you can find one <a href="https://raw.githubusercontent.com/rstudio/cheatsheets/main/data-transformation.pdf " target="_blank">here</a>.  And <a href="https://dplyr.tidyverse.org/" target="_blank">here</a> is an official tutorial.  

Try running the following code to load the dplyr package.  If this fails, you'll need to install this package.  Use the Packages tab in the lower right-hand corner of your screen.

```r
library(dplyr)
```


## Senate Polling Data

We're going to use polling data 
<a href="https://projects.fivethirtyeight.com/2022-election-forecast/" target="_blank">collected by 538</a>.

```r
senate_polls = readRDS(url("https://github.com/professorkalim/stats22-23/blob/main/senate_polls.rds?raw=true"))
```

First, let's take a look at the polls.  Here are two ways to do that:

```r
glimpse(senate_polls)

View(senate_polls)

```

Some notes on the data:

* poll_id is a unique identifier for every poll.  Notice that there are multiple rows for each poll but one row for each candidate respondent could choose to support in each poll.

* fte_grade: shows fivethirtyeight.com's rating for the quality of the pollster who conducted the poll

* sample_size: the number of responses to the poll

* population: (most often) either "lv" for likely voters or "rv" for registered voters.

* internal: whether the polls was public or conducted internal by a political party (internal polls might suffer from the "file drawer problem" -- they are only made public is the party like the result).

* partisan: blank is the pollster is not partisan and either "REP" or "DEM" if this is a partisan pollser.  

* party: the party political candidate being polled.

* start_date/end_date: the starting and ending date of when the poll was conducted

* numeric_fte_grade: I translated fivethirtyeight's letter grades into a numeric scale where an A+ is 12 and an F is 0.  A C+ is a 6.

# Filter and the "Pipe" %>%

The Pipe, %>%, acts as "and then" or put another way, it takes whatever you've done to your data thus far (in your "pipeline") and sends it, via a pipe, to the next stage in the process.  In the examples below, we'll just start with the whole data frame and pass it through a filter.

Also, notice that the code following a pipe can be on the next line (R knows that something should follow the pipe so it will look on the next line) but you don't want to start a new line with a pipe.

```r
senate_polls %>% 
  filter(pollster=="YouGov")

senate_polls %>% 
  filter(state=="Pennsylvania")

senate_polls %>% 
  filter(candidate_name == "Raphael Warnock")

senate_polls %>% 
  filter(candidate_name=="John Fetterman", 
         start_date >= "2022-08-01",
         partisan == "",
         population == "lv",
         numeric_fte_grade >= 8)

```

We could also pass the output into a View by adding a pipe and View() at the end:

```r
senate_polls %>% 
  filter(candidate_name == "Raphael Warnock") %>%  View()


senate_polls %>% 
  filter(candidate_name=="John Fetterman", 
         start_date >= "2022-08-01",
         partisan == "",
         population == "lv",
         numeric_fte_grade >= 8) %>% View()

```

# Select and Arrange

The select function allows us to select only certain columns of the data.  We can do this on its own or add it to a previous pipe.  Arrange does exactly what you might think and hope it does, it arranges the rows in order of the column of our choosing.

```r

senate_polls %>% 
  select("end_date", 
         "candidate_name", 
         "pct")

senate_polls %>% 
  select(contains("date"))

senate_polls %>% 
  filter(state=="Pennsylvania", 
         start_date >= "2022-08-01", 
         candidate_name=="Mehmet Oz") %>%
  select("start_date", 
         "pollster", 
         "pct")

senate_polls %>% 
  filter(state=="Pennsylvania", 
         start_date >= "2022-08-01", 
         answer=="John Fetterman") %>%
  select("start_date", 
         "pollster", 
         "pct") %>% 
  arrange(start_date)

senate_polls %>% 
    filter(state=="Georgia", 
           start_date >= "2022-08-01",
           answer=="Herschel Junior Walker") %>%
  select("start_date", 
         "pollster", 
         "pct") %>% 
  arrange(desc(pct))

```

# Group By and Summarize

Here's where things get really good.  

Take a deep breath.  

*group_by* and *summarize* will allow us to get means, standard deviations (or whatever summary statistics we desire) for whatever subsets of the data we're interested in.  So, if we were interested in how each candidate in Pennsylvania is polling since the start of October, we could do the following:

```r
senate_polls %>% 
  filter(state=="Pennsylvania", 
         start_date >= "2022-10-01") %>%
  group_by(candidate_name) %>%
  summarize(n(), mean(pct), min(pct), max(pct))

```

In the above code, n() count the number of rows for each group and, in this case, tells us the number of polls each candidate is found in.  We probably want to give our columns names, eliminate candidates who are in very few polls and arrange this in an orderly way so here goes:

```r
senate_polls %>% 
  filter(state=="Pennsylvania", 
         start_date >= "2022-10-01") %>%
  group_by(candidate_name) %>%
  summarize(num_polls =n(), 
            polling_average = mean(pct), 
            worst_poll = min(pct), 
            best_poll = max(pct)) %>%
  filter(num_polls >= 5) %>%
  arrange(desc(polling_average))


```

We could go a little nuts and do this for every state...  Notice that I'm opening up the start_date filter to get older polling here.

```r
senate_polls %>% 
  filter(start_date >= "2022-09-01")  %>%
  group_by(candidate_name, state) %>%
  summarize(part = first(party),
            polling_avg = round(mean(pct),1), 
            num_polls = n()) %>%
  filter(num_polls > 2, polling_avg > 2) %>% 
  arrange(state, desc(polling_avg)) %>%
  View()
```


# Mutate

I can also create new columns of data based on existing columns.  Don't worry about the "as.numeric()" function below.  The code below simply calculates the how many days prior to the election each poll ended and assigns a weight based on that.  The weight goes down for poll conducted longer ago.  I could change the number, 0.98, to assign relatively more or less weight to recent polls.

For now, let's just look at what this looks like for Pennsylvania.

```r
senate_polls %>% 
  filter(state=="Pennsylvania")  %>%
  mutate(days_before_election = as.numeric(election_date-end_date),
         poll_weight = 0.98^days_before_election ) %>% 
  select(end_date, 
         days_before_election, 
         poll_weight, 
         pct, candidate_name, pollster) %>%
  View()
```

# Weighted Averages

Now, I'll use these weights to get a **weighted polling average** for each candidate.  

To get a weighted average of the polls, we multiply each poll by its weight, add up those products and then divide by the sum of the weights.

Here's how that looks in Pennsylvania:

```r
senate_polls %>% 
  filter(state=="Pennsylvania") %>%
  mutate(days_before_election = as.numeric(election_date-end_date),
         poll_weight = 0.98^days_before_election ) %>%  
  group_by(candidate_name) %>%
  summarize(simple_polling_avg = mean(pct),
            weighted_polling_avg = sum(pct*poll_weight)/sum(poll_weight),
            num_polls = n()) %>%
  filter(simple_polling_avg >=2) %>%
  arrange(desc(weighted_polling_avg))
  
  
```

You might also want to filter out polls that you think are dubious. I'll repeat the code about but only allow polls that took place since September 1st, with a B grade (8 numeric grade) or higher.

```r
senate_polls %>% 
  filter(state=="Pennsylvania",
         numeric_fte_grade >= 8,
         start_date >= "2022-09-01"
         ) %>%
  mutate(days_before_election = as.numeric(election_date-end_date),
         poll_weight = 0.98^days_before_election ) %>%  
  group_by(candidate_name) %>%
  summarize(party = first(party),
            simple_polling_avg = mean(pct),
            weighted_polling_avg = sum(pct*poll_weight)/sum(poll_weight),
            num_polls = n()) %>%
  filter(simple_polling_avg >=2) %>%
  arrange(desc(weighted_polling_avg))

```

Try editing the above code!  You could try giving more/less weight to more recent polls, try changing which pollster grades are filtered out or add new filters (should we limit the polling average to "likely voters"?).



# Make Predictions!

Our <a href="https://docs.google.com/forms/d/e/1FAIpQLSeqB98X2NAjiX3bTps21_UEIxHtZEjYI6FDH8B0U5UT8Ptp2g/viewform?usp=sf_link" target="_blank">election prediction contest</a> asks you to make predictions for the 12 senate elections in:


* Georgia
* Nevada
* Pennsylvania
* Arizona
* New Hampshire
* North Carolina
* Wisconsin
* Ohio
* Colorado
* Washington
* Florida
* Iowa

Try running your code for each of the twelve states above and writing down the winning party and the margin of victory so that you can enter the prediction contest!

# Going Further

It's possible to come up with more complex weighting schemes that include uncertainty (or variance) due to a number of factors such as the time since the poll was conducted, polling quality and sample size among other things.  In a perfect world, we'd look at the polls leading up to past elections and use the relative accuracy of those polls to determine how much each of these factors matters.  For now, we'll wing it!  Here's one scheme of assigning weights to polls.  If you have time, you should try to create your own!

```r
prediction_states = 
  c("Pennsylvania", "Georgia", "Nevada",
  "Arizona", "New Hampshire", "North Carolina",
  "Wisconsin", "Ohio", "Colorado", "Washington",
  "Florida", "Iowa")

senate_polls %>% 
  filter(state %in% prediction_states,
         numeric_fte_grade >= 8,
         start_date >= "2022-09-01"
         ) %>%
  mutate(days_before_election = as.numeric(election_date-end_date),
        var_time = days_before_election/2,
        var_sample_size = (50^2)/sample_size,
        var_poll_quality = 2*(12-numeric_fte_grade),
        var_unknown = 4,
        total_variance = var_time + var_sample_size + 
          var_poll_quality + var_unknown,
        poll_weight = 1/total_variance) %>%
    group_by(state, candidate_name) %>%
  summarize(party = first(party),
            simple_polling_avg = round(mean(pct),1),
            weighted_polling_avg = 
              round(sum(pct*poll_weight)/sum(poll_weight),1),
            num_polls = n()) %>%
  filter(simple_polling_avg >=2) %>%
  arrange(state, desc(weighted_polling_avg)) %>%
  View()

```
