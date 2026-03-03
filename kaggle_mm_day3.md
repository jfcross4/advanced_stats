Kaggle March Madness Day 3
------------------------------------------------

First, complete Kaggle March Madness Day 2 (our previous lab) if you haven't already.

1. Open the March Madness project on posit.cloud that you created in the previous lab.  

2. Download the files from Classroom (two of these come directly from Kaggle) and upload them into your project folder on posit.cloud.  (In the lower right hand corner of your posit.cloud window, go to the “Files” Tab and then look for the icon with an up arrow in a little yellow circle.)

3. Reading these files into R data frames.

Remember that you should save your code from this project in an Rscript file so that you can easily find it and run it again when you need to.

```r
MTourneyResults = read.csv("MNCAATourneyCompactResults.csv")
mordinals = read.csv("MMasseyOrdinals.csv")
kenpom = read.csv("KenPom.csv")
```

# What are we up to today?

The purpose of today's lab is to find out which of several public prognosticators is the best at ranking basketball teams.  This will be useful information if we intend to use public rankings to make our Kaggle predictions.

To get a sense of how we're going to do that, let's look at the ordinals file:

```r
View(mordinals)
```

The file contains men's college basketball team rankings from 196 sources throughout the last 24 basketball seasons.  The file comes directly from Kaggle which provides the following description of the data:

# MMasseyOrdinals.csv

This file lists ordinal rankings (e.g. #1, #2, #3, ..., #N) of men's teams going back to the 2003 season, under a large number of different ranking system methodologies. The information was gathered by Kenneth Massey and provided on his [rankings page](https://masseyratings.com/cb/arch/compare2023-19.htm).

**Season** - this is the year of the associated entry in MSeasons.csv (the year in which the final tournament occurs)

**RankingDayNum** - this integer always ranges from 0 to 133, and is expressed in the same terms as a game's DayNum (where DayZero is found in the MSeasons.csv file). The RankingDayNum is intended to tell you the first day that it is appropriate to use the rankings for predicting games. For example, if RankingDayNum is 110, then the rankings ought to be based upon game outcomes up through DayNum=109, and so you can use the rankings to make predictions of games on DayNum=110 or later. The final pre-tournament rankings each year have a RankingDayNum of 133, and can thus be used to make predictions of the games from the NCAA® tournament, which generally start on DayNum=134 (the Tuesday after Selection Sunday).

**SystemName** - this is the (usually) 3-letter abbreviation for each distinct ranking system. These systems may evolve from year to year, but as a general rule they retain their meaning across the years. Near the top of the Massey rankings page (linked to above), you can find slightly longer labels describing each system, along with links to the underlying pages where the latest rankings are provided (and sometimes the calculation is described).

**TeamID** - this is the ID of the team being ranked, as described in MTeams.csv.

**OrdinalRank** - this is the overall ranking of the team in the underlying system. Most systems from recent seasons provide a complete ranking from #1 through #351, but more recently they go higher because additional teams were added to Division I in recent years.

---------------

We don't want to try to analyze all rankings from all days (this file has almost 6 million rankings!) so instead, let's look at the last rankings (prior to the tournament) from the 25 systems (out of 196) which have put our late seaseon rankings in each of the last 10 seasons (excluding 2020):

```r
library(tidyverse)

systems = c("7OT", "BBT", "BIH", "BWE", "COL", 
                 "DCI", "DII", "DOK", "DOL", "DUN", "EBP", "KPK", "LMC", "LOG", 
                 "MAS", "MOR", "PGH", "POM", "REW", "RT", "SPR", "TRK", "TRP", 
                 "WIL", "WLK")
  
mordinals = 
mordinals %>% 
  group_by(SystemName, Season) %>% 
  slice_max(RankingDayNum, n=1) %>% 
  filter(Season >=2015, Season <=2025, Season !=2020, RankingDayNum >=120) %>% 
  filter(SystemName %in% systems)
  
View(mordinals)
```

Now we're down to 25 systems over 10 seasons and a more modest 89,000 rankings.

Ultimately, we want to take the rankings from each of these systems, use the to project the results of each of the last 5 tournaments and see whose rankings made the best predictions... but here's the tricky part, how do we make predictions from rankings?  For instance, if the #10 team in the country plays the #26 team in the country, what is each team's chance of victory?  To answer this question, let's first work on turning rankigns into ratings.  To do this we'll use the KenPom data that has both rankings and ratings:

```r
View(kenpom)
```

In this data set the two columns that matter to use are "RankAdjEM", the ordinal ranking and "AdjEM" the rating.  Let's take those two columns and graph them:

```r
kp = kenpom %>% 
  filter(Season >=2015, Season <=2025, Season !=2020) %>%
    select(OrdinalRank = RankAdjEM, Rating=AdjEM)

kp %>% 
  ggplot(aes(OrdinalRank, Rating)) + 
  geom_point(size=0.5)
```

You can see that a #11 ranked team likely has a considerable lower rating than the #1 ranked team, whereas the difference between the 100th and 110th best teams likely to be consierably smaller.  Let's fit a smooth curve to fit this data and then make a new plot showing what KenPom rating we'd predict for every possible ordinal ranking:

```r
m = loess(Rating ~ OrdinalRank, data=kp, span=0.05)
kp$predRating = predict(m)

kp %>% 
  ggplot(aes(OrdinalRank, Rating)) + 
  geom_point(size=0.5)+
  geom_point(aes(OrdinalRank, predRating), col="red", size=0.1)
```
The red points show the predicted ratings for every possible ranking.  We can now use this relationship to turn all of the rankings (from all of the systems) into predicted ratings:

```r
mordinals$Rating = predict(m, newdata=mordinals)
```

Lastly, we need a way to turn ratings into predicted probabilities.

After some fiddling, I found the the following system works:

* Calculate the difference in ratings.
* Divide by 14 (a standard error in the prediction) to get a t-score
* Turn this into a probability by using the t-distribution with 2 degrees of freedom

After determining the probability of victory that our system and Massey's rankings would have assigned to each of the winning teams over the last 10 years, we can calculate our Brier Score by averaging the squared differences between our predictions and the result.

Let's see how this work for Massey Rankings (MAS):

```r
test.system = "MAS"

mordinals_subset = 
mordinals %>% 
filter(SystemName==test.system)

# getting tournament results for the last 10 seasons

TourneyResults = 
TourneyResults %>% 
filter(Season >=2015, Season <=2025, Season !=2020)

# matching tournament results with Massey ratings

tourney_with_ratings = 
left_join(TourneyResults,
          mordinals_subset %>%
            ungroup() %>%
            select(Season, TeamID, WRating = Rating),
          by=c("Season", "WTeamID"="TeamID")) %>%
left_join(., 
          mordinals_subset %>%
            ungroup() %>%
            select(Season, TeamID, LRating = Rating),
          by=c("Season", "LTeamID"="TeamID"))


# calculating a Brier Score

tourney_with_ratings %>%
  mutate(tscore = (WRating-LRating)/14,
         pred = pt(tscore, df=2)) %>%
  summarize(brier_score = mean((1-pred)^2))

```

Great!  This system would have achieved a Brier Score of 0.1903.  Can any of the other rankings do better?  Let's use a for loop to calculate the Brier Score for each of these 25 systems.  First, I'll create an empty data frame in which to store our results:

```r
results = data.frame(System = systems, 
                     brier.score = NA)
                     
for(i in 1:length(systems)){
  test.system = systems[i]
  
  mordinals_subset = mordinals %>% 
    filter(SystemName==test.system)
  
  
  tourney_with_ratings = 
    left_join(TourneyResults,
              mordinals_subset %>%
                ungroup() %>%
                select(Season, TeamID, WRating = Rating),
              by=c("Season", "WTeamID"="TeamID")) %>%
    left_join(., 
              mordinals_subset %>%
                ungroup() %>%
                select(Season, TeamID, LRating = Rating),
              by=c("Season", "LTeamID"="TeamID"))
  
  
  score = 
    tourney_with_ratings %>%
    mutate(tscore = (WRating-LRating)/14,
           pred = pt(tscore, df=2)) %>%
    summarize(brier_score = mean((1-pred)^2)) %>%
    as.numeric()
  
  
  results = 
    results %>%
    mutate(brier.score = 
             ifelse(System==test.system, score, brier.score))
}                     

View(results)
```

The top scoring system is TRP ([TeamRankings](https://www.teamrankings.com/ncaa-basketball/ranking/predictive-by-other/)), followed by WLK ([Whitlock](http://whitlockrankings.com/fbrank1.htm)), DOK ([Dokter Entropy](http://www.dokterentropy.com/r2026.CBB)), EBP ([ESPN BPI](https://www.espn.com/mens-college-basketball/bpi)) and POM ([Ken Pomeroy](https://kenpom.com/)).

Let's make a graph of the Brier Scores:

```r
results %>%
    arrange(brier.score) %>%
    mutate(System = factor(System, levels = System),
           highlight = row_number() <= 9) %>%
    ggplot(aes(x = System, y = brier.score, color = highlight)) +
    geom_point(size = 2.5) +
    theme_minimal() +
    labs(title = "System Scores", x = NULL, y = "Score")+
    scale_color_manual(values = c("black", "red")) +
    theme_minimal() +
    guides(color = "none")+ coord_flip()
```

I highlighted the best 9 Brier Scores in red since these system stand out from the rest to some degree.

Let's make a composite of the best 9 systems by averaging the ratings of these 9 system for every basketball team in each of the 10 most recent seasons:

```r
best.systems = c("TRP", "WLK", "DOK", "EBP", "POM", 
                 "LMC", "LOG", "MOR", "TRK")
mordinals_best = 
  mordinals %>% filter(SystemName %in% best.systems)

mordinals_best_mean = 
mordinals_best %>%
  group_by(Season, TeamID) %>%
  summarize(Rating=mean(Rating))
```

Next, let's use these average ratings to make predictions:

```r
tourney_with_ratings = 
  left_join(TourneyResults,
            mordinals_best_mean %>%
              ungroup() %>%
              select(Season, TeamID, WRating = Rating),
            by=c("Season", "WTeamID"="TeamID")) %>%
  left_join(., 
            mordinals_best_mean %>%
              ungroup() %>%
              select(Season, TeamID, LRating = Rating),
            by=c("Season", "LTeamID"="TeamID"))

  tourney_with_ratings %>%
  mutate(tscore = (WRating-LRating)/14,
         pred = pt(tscore, df=2)) %>%
  summarize(brier_score = mean((1-pred)^2)) %>%
  as.numeric()

```

This score based on the average of the 9 best system is betting than any one system on it's own!  Better yet, the prediction based on the average of 9 systems has a bit less noise than the prediction of one system so we can use a smaller standard error.  Let's try 12 instead of 14.

```r
tourney_with_ratings %>%
  mutate(tscore = (WRating-LRating)/12,
         pred = pt(tscore, df=2)) %>%
  summarize(brier_score = mean((1-pred)^2)) %>%
  as.numeric()
```

This improves our predictions further!

The take home: The best predictions might come from, [finding the best systems and averaging them](https://fivethirtyeight.com/features/how-our-march-madness-predictions-work/).





