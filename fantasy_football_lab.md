Fantasy Football Lab
--------------------------------------

In today's lab, we're going to examine fantasy football data.  If you have no interest in fantasy football data, you could dig deeper into [comic book data](https://github.com/jfcross4/advanced_stats/blob/cross/comic_characters.md) or [movie data](https://github.com/jfcross4/advanced_stats/blob/cross/plotting_movies.md) instead.

Note: If you dig further into comic book characters, you can combine the two data sets using [this code](https://github.com/jfcross4/advanced_stats/blob/cross/comic_rbind.R).

# 2023 Fantasy Football Data

## Getting the Data

First, let's get weekly data on Fantasy Football performances from the 2023 season.

```r
library(tidyverse)


ff = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/cross/2023_fantasy_football_data.csv")

View(ff)

```

This data is from ESPN.  Spend a little time, getting familiar with this data.  One thing that might be of interest to us is the comparison between ESPN's projected fantasy points and a player's actual fantasy points that week.

Let's plot actual points v. projected points with a blue best fit curve and a red line representing where actual fantasy points equal projected fantasy points:

## Plotting the Data

```r
ff %>% ggplot(aes(projected_pts, actual_pts))+
  geom_point()+
  geom_smooth()+
  geom_abline(intercept=0, slope=1, col="red")
```

We could also split this up by position:

```r
ff %>% ggplot(aes(projected_pts, actual_pts))+
  geom_point()+
  geom_smooth()+
  geom_abline(intercept=0, slope=1, col="red")+
  facet_wrap(~position)
```

We could also look at how projected fantasy points are distributed.  Here, I'll eliminate players with 0 projected points.

```r
ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(projected_pts))+
  geom_histogram()+
  facet_wrap(~position)
```

*What do you notice about these distributions?*

and similarly, how actual points are distributed:

```r
ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(actual_pts))+
  geom_histogram()+
  facet_wrap(~position)
```

Let's add a column represented how players performed relative to their projections:

```r
ff = ff %>%
  mutate(pts_over_exp = actual_pts - projected_pts)
```

Then look at the distribution of this new column:

```r
ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(pts_over_exp))+
  geom_histogram()+
  facet_wrap(~position)
```

Next, let's make the information in the "game_outcome" column 
more useful.  

Right now these a game_outcome column might be "W 25-20" 
indicating that the player's team won 25 to 20.  
Let's split this information into three columns, 
first splitting at the space (" ") and then splitting at the dash ("-").

```r
ff = 
ff %>%
  separate(game_outcome, into=c("outcome", "score"), sep=" ")

ff = 
  ff %>%
  separate(score, into=c("tm_score", "opp_score"), sep="-")
  
View(ff)
```

Let's also add a column for total touchdowns:

```r
ff = 
  ff %>%
  mutate(total_td = pass_td + rush_td + rec_td + misc_td)
```

Try to interpret this graph:

```r
ff %>% filter(projected_pts > 0) %>%
    ggplot(aes(projected_pts, pts_over_exp, 
               color=as.factor(total_td)))+
    geom_point()+
    facet_wrap(~position)
```

or this one:

```r
ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(projected_pts, pts_over_exp, 
             color=as.factor(total_td)))+
  geom_smooth()+
  facet_wrap(~position)
```

## Analysis


Are player's more likely to outperform projections in wins? Let's limit our analysis to fantasy relevant players (with at least 10 projected points):

```r
ff %>% filter(projected_pts >= 10) %>%
  group_by(position, outcome) %>%
  summarize(proj = mean(projected_pts), 
            actual = mean(actual_pts),
            over_exp = mean(pts_over_exp))
```

Did some positions do better relative to expectations than others?

```r
ff %>% filter(projected_pts >= 10) %>%
    group_by(position) %>%
    summarize(proj = mean(projected_pts), 
              actual = mean(actual_pts),
              over_exp = mean(pts_over_exp))

```

Are some positions, more predictable than others?  
To find out I'll look at the correlation between 
actual points and projected points.  

I'll try this both when limited the analysis to 
fantasy relevant players (projected points > 10) and when not limiting the analysis.  
(Does that change the results?  If so, why?)

```r
ff %>% filter(projected_pts >= 10) %>%
  group_by(position) %>%
  summarize(cor(projected_pts, actual_pts))

ff %>% filter(projected_pts > 0) %>%
  group_by(position) %>%
  summarize(cor(projected_pts, actual_pts))
```

*How would you interpret those two tables of correlations?*

## Wide Data

The data we have been looking at so far is *long*.  
By "long", we mean that it has many rows -- every player-game is a row.

What if we wanted to have one row for every 
player and columns for each week?  
This would make the data "wider" (more columns) but not as long (fewer rows).

We could "pivot" the data and make it wider.  
Let's do this!  We'll give the data set a new name 
(so that we don't write over all the good work we've done) 
and only keep the "pts_over_exp" data to keep things simple:

```r
ff_wide = 
ff %>%
  select(player, position, week, pts_over_exp) %>%
  arrange(week) %>%
  pivot_wider(id_cols = c(player, position), 
              names_from = week,
              values_from = pts_over_exp,
              names_prefix = "week")
              
View(ff_wide)

```

Data in this format might be useful for some types of analysis.  For instance, are players who are over/under projected in week 15 likely to be over/under projected in week 16?  I could use this data to try to find out:

```r
ff_wide %>% 
  group_by(position) %>%
  summarize(cor(week15, week16, use="pairwise.complete"))
```

Or, I could plot "pts_over_exp" on consecutive weeks:

```r
ff_wide %>%
  ggplot(aes(week15, week16, color=position)) + 
  geom_point() +
  geom_smooth(method="lm")+
  ggtitle("points over expected")

```

Do players who outperformed expectations in week 15 
tend to outperform in week 16?

We could also look at performance relative to expectations in all pairs of consecutive weeks
by rearranging the data in yet a different way:

```r
ff_consec_weeks = 
left_join(ff %>% select(player, position, week, pts_over_exp), 
          ff %>% select(player, week, pts_over_exp) 
          %>% mutate(prev_week = week - 1),
          by=c("player", "week"="prev_week"))
          
View(ff_consec_weeks)
```

and look for correlations in and plot this data:

```r
ff_consec_weeks %>% 
  group_by(position) %>%
  summarize(cor(pts_over_exp.x, pts_over_exp.y, use="pairwise.complete"))



ff_consec_weeks %>%
  ggplot(aes(pts_over_exp.x, pts_over_exp.y, color=position)) + 
  geom_point() +
  geom_smooth(method="lm")+
  ggtitle("points over expected")

```

# Play Around

See what you discover using either the original data "ff" 
or this wide version "ff_wide"