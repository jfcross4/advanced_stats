Kaggle March Madness Day 5 (The Last Lab)
------------------------------------------------
In our fourth Kaggle Lab, we used TeamRankings ratings (for Men) and Massey ratings (for Women) to make predictions.

If you missed previous Kaggle March Mania labs 
([1](https://github.com/jfcross4/advanced_stats/blob/cross/kaggle_mm_day1.md),[2](https://github.com/jfcross4/advanced_stats/blob/cross/kaggle_mm_day2.md),[3](https://github.com/jfcross4/advanced_stats/blob/cross/kaggle_mm_day3.md),[4](https://github.com/jfcross4/advanced_stats/blob/cross/kaggle_mm_day4.md)), 
please complete the earlier Kaggle March Madness labs before working on this lab.


Today we want to

* Update Massey and TeamRankings ratings.

* Take Homefield Advantage into account now that we have a bracket.

* Think carefully about how you want to differentiate your predictions.

# Updating TeamRankings ratings 

1. Go to the [TeamRankings website](https://www.teamrankings.com/ncaa-basketball/ranking/predictive-by-other/).  Next highlight the full table including the headers (as shown below) but try not to highlight anything else.

<img src="teamrankings_highlight.png" width="500" height="400" />

2. Now paste this data into Google Sheets.  Change the name of your Google Sheets file to "TeamRankings" and then go to File/Download and select "Comma Separated Values (.csv)".  You now have this data as a .csv file.

3. Upload the TeamRankings .csv file you just created into your posit.cloud March Madness project.

# Updating Massey ratings 

1. go to:
[https://masseyratings.com/cbw/ncaa-d1/ratings](https://masseyratings.com/cbw/ncaa-d1/ratings)

2. Find the menu on top that says “More” and scroll down to “Export” to dowload.

3. Change the name of the file to “wratings.csv” and upload it to your posit.cloud project.

# Lastly, adding new files

Download the three new files on Classroom ('WNCAATourneySeeds.csv', 'MNCAATourneySeeds.csv' and 'NCAATourneySeedRoundSlots.csv') and upload them to posit.cloud.

# Reading files into an R data frame.

Remember that you should save your code from this project in an Rscript file so that you can easily find it and run it again when you need to.

```r
# Check the name of your .csv file and change this code as needed:
library(tidyverse)
MTeamSpellings = read.csv("MTeamSpellings.csv")
WTeamSpellings = read.csv("WTeamSpellings.csv")
Stage2 = read.csv("SampleSubmissionStage2.csv")
mratings = read.csv("mratings.csv")

# only after you've updated the data
TR = read.csv("TeamRankings - Sheet1.csv")
wratings = read.csv("wratings.csv")

WSeeds <- read.csv('WNCAATourneySeeds.csv')
MSeeds <- read.csv('MNCAATourneySeeds.csv')
SRS <- read.csv('NCAATourneySeedRoundSlots.csv')
```

# TeamRanking Cleanup 
(and name matching)

```r
# Team Ranking Cleanup - same as last time but condensed

TR = TR[, 2:3]

TR = 
TR %>%
  mutate(Team = gsub("[^a-zA-Z\\ \\' \\&\\.]", "",Team)) %>%
  mutate(Team = gsub("\\s+", " ",Team)) %>%
  mutate(Team = trimws(Team)) %>%
  mutate(Team = tolower(Team))
  
M_new_spellings = 
  data.frame(
    TeamNameSpelling = c("miami",
                         "s florida",
                         "n iowa",
                         "st thomas",
                         "illinois chicago",
                         "e tennessee st",
                         "n texas",
                         "ucsd",
                         "kennesaw st",
                         "kent st",
                         "ut rio grande",
                         "loyola mymt",
                         "middle tenn"), 
    TeamID = c(1274,
               1378,
               1320,
               1472,
               1227,
               1190,
               1317,
               1471,
               1244,
               1245,
               1410,
               1258,
               1292))

MTeamSpellings2 = 
  rbind(MTeamSpellings, M_new_spellings)          
     
TR_with_ids = inner_join(TR, 
                    MTeamSpellings2,
                    by=c("Team"="TeamNameSpelling"))              
```


# Cleaning Massey
(and combining with TeamRankings)

We only have TeamRankings for Men's teams, so we'll use the Massey ratings for Women's teams.  You should have a data.frame called "massey" that you created in a [previous lab](https://github.com/jfcross4/advanced_stats/blob/cross/kaggle_mm_day2.md).

```r
massey = clean_and_combine_masseys(mratings, wratings)


combined_ratings = 
rbind(massey %>% 
        filter(TeamID >= 3000),
      TR_with_ids %>%
      select(TeamID, Rating)
        )
```

# Altering Ratings
We can still alter ratings (like you did in the second Kaggle lab) in order to make some gambles.  Replace the code below with the ratings alterations that you want to make (or skip this entirely if you'd rather avoid gambles):

```r
combined_ratings = 
  combined_ratings %>%
  mutate(
    Rating = case_when(
    TeamID == 1181 ~ 35,
    TeamID == 3376 ~ 90,
    .default = Rating
    )
  )

```

# Adding Rounds to our Games

```r
games = games_to_predict(Stage2)
```

This is our new adventure for the day.  We want to "games" data.frame and add the round of each game and the seedings for each team.  We'll use the new files we added to do this:

1. Combine the Men's and Women's Seeds files:

```r
Seeds = rbind(
  MSeeds %>% filter(Season==2026),
  WSeeds %>% filter(Season==2026)
) %>% select(-Season)

View(Seeds)

```

In this data set the regions are referred to as W, X, Y and Z.  So, W01 and W16 will face each other in the first round but teams from different regions can't meet until the finals.


2. Extract the seed number from the seeds

```r
Seeds = Seeds %>% 
  mutate(SeedNum = as.numeric(substr(Seed,2,3)))

View(Seeds)
```

3. Figure out the earliest game in which two teams might meet.

We'll use the SeedRoundSlot file for this.  This file has the day in which each seed could (potentially) play in each game.

```r
View(SRS)
```

This next part gets ugly but it's worth taking a look at what we create at the end:

```r
SRSjoin <- left_join(SRS, 
                     SRS %>% 
                      select(GameSlot, Seed), 
                     by="GameSlot",
                     relationship = "many-to-many") %>%
  filter(Seed.x != Seed.y)
  
temp <- left_join(games, 
                  Seeds, 
                  by=c("team1"="TeamID"))

games.to.predict.Seeds <- left_join(temp, 
                                    Seeds, 
                                    by=c("team2"="TeamID"))
                                    

games.to.predict.SeedsRounds =
  left_join(games.to.predict.Seeds, 
            SRSjoin, 
            by=c("Seed.x"="Seed.x", 
                 "Seed.y"="Seed.y"),
            relationship = "many-to-many")
            
games.to.predict.SeedsRounds = 
games.to.predict.SeedsRounds %>% 
  rename(seed1 = Seed.x, 
         seed2 = Seed.y,
         seedNum1 = SeedNum.x,
         seedNum2 = SeedNum.y) %>% 
  select(-EarlyDayNum, -LateDayNum )
  
games.to.predict = 
  games.to.predict.SeedsRounds %>% 
  group_by(Season, team1, team2) %>% 
    summarize(GameRound = min(GameRound),
              team1seed = first(seedNum1),
              team2seed = first(seedNum2)) %>% 
  ungroup() %>%
  mutate(Pred = 0.5, 
         tourney=ifelse(team1 > 2500, "W", "M"),
         home = 0)
         
View(games.to.predict)
```

Look at the GameRound column.  If this column is NA, it's because at least one of the two teams did not qualify for the tournament and they can't possible meet.  If the GameRound is 0, these two teams will play in the play in round and those games aren't score by Kaggle.  Only the games that would happen in rounds 1 through 6 count and only the games in round 1 are (mostly) sure to happen.

Now, let's modify the "home" column to give home field advantage to teams that will have it in the women's tournament:

```r
games.to.predict = games.to.predict %>% mutate(
  home = ifelse(tourney=="W" & GameRound <=2 & team1seed <= 4, 1, 0),
  home = ifelse(tourney=="W" & GameRound <=2 & team2seed <= 4, -1, home)
)
```

# Making Predictions

Finally, we can make predictions!

Let's match games with our ratings:

```r
games_with_ratings = 
  join_games_and_ratings(games.to.predict, combined_ratings)

games_with_ratings = 
  games_with_ratings %>%
  mutate(
    team1rating = ifelse(is.na(team1rating), 0, team1rating),
    team2rating = ifelse(is.na(team2rating), 0, team2rating),
    home = ifelse(is.na(home), 0, home))
```

and add predictions:

```r
games_with_predictions = 
  add_massey_preds(games_with_ratings)
```

Now, we need to adjust these predictions in cases where a team has home field advantage.  We'll have home field advantage, multiple the *odds* of a team winning by 1.656 (this is based on historical data).

```r
home_adj <- function(pred, home){
  odds <- (pred/(1-pred))*1.656^home
  return(odds/(odds+1))
}

games_with_adj_predictions <- games_with_predictions %>% 
  mutate(Pred = home_adj(Pred, home))

```

Lastly, we can write these adjusted predictions to a .csv file that we can submit to Kaggle:

```r
write.csv(unite(games_with_adj_predictions, 
                col="ID", 
                Season, team1, team2) %>%
            select(ID, Pred), 
          file="best_predictions_ever.csv",
          row.names = FALSE)
```