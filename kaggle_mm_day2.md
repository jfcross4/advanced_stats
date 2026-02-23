Kaggle March Madness Day 2
------------------------------------------------

[Kaggle March Machine Learning Mania 2026](https://www.kaggle.com/competitions/march-machine-learning-mania-2026) is now live!

From Kaggle:
*You will be forecasting the outcomes of both the men's and women's 2026 collegiate basketball tournaments, by submitting predictions for every possible tournament matchup.*

“Every possible tournament matchup” means that we will be making predictions for matchups of every Division I Men’s team against every other Division I Men’s team and every Division I Women’s team against every other Division I Women’s team.  All told, this means that we will need to make 132,133 predictions.  Most of these teams won’t make the tournament and most tournament teams won’t face each other.  In fact, only 126 of these 132,133 games will actually take place (although we don’t know which ones) and only those 126 predictions will matter.  Kaggle is actually doing us a favor by having us make 132,133 predictions because we can work on these predictions now before all of the game have been played or the tournament bracket has been made and, if you’re writing code, it’s essentially no harder to make 132,133 predictions than 126.  Lastly, remember that each predicion you'll make is a probability (between 0 and 1) and not simply a win/loss prediction.

**The Stages**

Technically, this competition happens in two stages: Stage 1 and Stage 2.  Only Stage 2 matters.  Stage 1 allows people to test their models by submitting predictions for 2021-2025 tournament games (games that have already been played).  Many participants won’t bother to make Stage 2 predictions.  Stage 2 is when everyone makes predictions for the 2026 tournaments.  

**Today and Tomorrow**

We’re going to work on how to take public team ratings and turn them into projections.  We will also talk about how to tweak these ratings or “gamble” on particular games.  Time permitting, in another lab, we will later work on how to make our own team ratings.  

1. Downloading Kaggle Data and Importing it into R

If you started a March Madness project on posit.cloud you can use that.  Otherwise, start a new project on March Madness and make sure to name it.  

Download the files from Classroom (these come directly from Kaggle) and upload them into your project folder on posit.cloud.  (In the lower right hand corner of your posit.cloud window, go to the “Files” Tab and then look for the icon with an up arrow in a little yellow circle.)

2. Downloading Public Team Ratings from Massey.com

For Men’s team ratings, go to:
[https://masseyratings.com/cb/ncaa-d1/ratings](https://masseyratings.com/cb/ncaa-d1/ratings)

The numbers we want are in the “Power” column.  For instance, for Duke, we want the number 56.14, Duke’s current power rating.  To get all of this data, find the menu on top that says “More” and scroll down to “Export”.  This should download the file.  After you have downloaded it, you should change the name of the file to “mratings.csv” and then upload it to your posit.cloud project folder.

For Women’s team ratings, go to:
[https://masseyratings.com/cbw/ncaa-d1/ratings](https://masseyratings.com/cbw/ncaa-d1/ratings)

And then follow the same instructions as with the men’s rating except this time change the name of the file to “wratings.csv”.

3. Reading these files into R data frames.

Start a new R script (File/New File/R script) on posit.cloud.  
Since this is a longer project it will be important to save all of your code in scripts rather than just running it in the console.

Paste the following code into your script and run it:

```r
library(tidyverse)

mratings = read.csv("mratings.csv")
wratings = read.csv("wratings.csv")
MTeamSpellings = read.csv("MTeamSpellings.csv")
WTeamSpellings = read.csv("WTeamSpellings.csv")
Stage2 = read.csv("SampleSubmissionStage2.csv")
```

Next, take a look at each these files individually.  
You can use View to look at them, for example:

```r
View(mratings)
```

There are some things you might notice:

* the mratings and wratings data frames are messy!  We're going to need to write code that cleans them up.

* the MTeamSpellings and WTeamSpellings data frames have all of the common team spellings for each team matched up with that team's ID.  This is very useful!  It will allow us to match up data from different websites and use that data to make predictions on the Sample Submission File.

* the Stage2 data frame looks like a file we used in our last lab.  The ID column has the ID's for the two teams in every possible matchup.  Are predictions are the chance we assign to team 1 (the team listed first) beating team 2 if these two teams play each other.  We just need to alter the "Pred" column with our predictions and submit this file to Kaggle.

# Cleaning the Massey Data

I've written a function that cleans the Massey Data and uses the MTeamSpelling and WTeamSpellings data frames to match ratings with team IDs.  
Here is the function.  The function contains a simpler function "clean_massey" which can be applied to both the men's and women's ratings. 
First "clean_massey" take the 1st and 9th columns from the Massey data we downloaded and discards the rest.
Next, it names these columns "Team" and "Rating".  After that, it changes all of the letters in the team names lowercase.  We do this since all of the names in "MTeamSpellings" and "WTeamSpellings" are lowercse.
After we've cleaned both the men's and women's data, we join them with the TeamNameSpellings data frame to match the ratings with the team IDs.  Lastly, we combine the men's and women's ratings into one large dataframe.

```r
clean_and_combine_masseys = 
  function(m=MMassey, w=WMassey){
    
    clean_massey = function(x){
      x = x[,c(1,9)]
      colnames(x) = c("Team", "Rating")
      x = x %>%
        mutate(TeamNameSpelling = tolower(Team))
      return(x)}
    
    m = clean_massey(m)
    w = clean_massey(w)
    
    m = 
      left_join(m,
                MTeamSpellings,
                by="TeamNameSpelling")
    
    w = 
      left_join(w,
                WTeamSpellings,
                by="TeamNameSpelling")
    massey = 
      rbind(m,w) %>%
      select(TeamID, Rating)
  }
```

To use this function, run the code:

```r
massey = clean_and_combine_masseys(mratings, wratings)
```

Now, take a look at what you've created:

```r
View(massey)
```

# Working with the Sample Submission File

Let's write a function that the "Stage2" file and makes it easier to work with.  We'll separate the information in the ID column and add columns denoting whether this is a men's or women's game and whether team 1 is at home.  We don't have a bracket yet and don't know which women's teams will be at home in which games yet so this is just a place holder for when we have more information.

```r
games_to_predict = function(SampleSubmission){
  games.to.predict = 
    SampleSubmission %>%
    separate_wider_delim(ID, 
                         delim = "_",
                         names = c("Season", "team1", "team2"))
  
  
  games.to.predict$home <- 0
  
  games.to.predict = 
    games.to.predict %>%
    mutate(team1 = as.numeric(team1),
           team2 = as.numeric(team2), 
           tourney = ifelse(team1 <= 2500, "M", "W"))
  return(games.to.predict)
}
```

Now, let's use this function, and look at the result:

```r
games = games_to_predict(Stage2)

View(games)
```

Next, let's write a function to join these games with our clean Massey ratings file:

```r
join_games_and_ratings = 
  function(games, ratings){
    #games must have columns team1 and team2
    #ratings must have TeamID and rating
    games = 
      left_join(games,
                ratings %>% 
                  dplyr::rename(team1rating = Rating),
                by=c("team1"="TeamID")) %>%
      left_join(.,
                ratings %>% 
                  dplyr::rename(team2rating = Rating),
                by=c("team2"="TeamID"))
    return(games)
  }
```

and let's use this function and look at what we created:

```r
games_with_ratings = 
  join_games_and_ratings(games, massey)

View(games_with_ratings)
```

Notice that each game now has a rating for each team.

# Making Predictions

How do we use these ratings to make predictions?  
It turns out that the difference between two teams' Massey Ratings is the the predicted margin of victory on a neutral court.  I'll add in a 2.7 point advantage for the home team and get the following formula:

Predicted Margin of Victory = Team1 Rating - Team2 Rating + Home Field Advantage (0, 2.7 or 2.7)

Then, how do we use the predicted margin of victory, to determine a probability of victory?  We can look at past games and calculate the root mean square error in Massey predictions.  It is about 10.5 points.  This means that the standard deviation in Massey predictions is 10.5 points.  If Massey predicts that a team will win by 15 points, we should interpret that as 15 +/- 10.5
We can use this information to turn the predicted margin of victory into a z-score.  If a team is predicted to win by 15 points, we think that they'll win by $15/10.5 \approx 1.43$ standard deviations.

Okay, so how often would they win?  If a team is predicted to win by 1.43 standard deviations, they'll win unless their result is 1.43 standard deviations below average or worse.  We could look up the chance of this happening on our standard normal tables or just use R code to calculate their change of victory:

```r
pnorm(1.43)
```

A team that's predicted to win by 15 points should win 92% of the time.

Let's put this all together into a function that turns team ratings into margins of victory:

```r
add_massey_preds = function(games){
  games = 
    games %>%
    mutate(PredScoreDiff = 
             team1rating - team2rating + 2.7*home,
           Pred = pnorm(PredScoreDiff/10.5))
  return(games)
}
```

And, now, let's use it to make predictions:

```r
games_with_predictions = 
  add_massey_preds(games_with_ratings)
  
View(games_with_predictions)
```

Notice that the "Pred" column has changed and that we've added a "PredScoreDiff" column.

Just for fun, let's make a plot of probability of victory vs. predicted score difference:

```r
games_with_predictions %>%
  ggplot(aes(PredScoreDiff, Pred)) +
  geom_line()
```

# Boosting Teams

Let's suppose (for example) that I think that the Duke Men's Team and South Carolina Team are underrated by Massey ratings.  
I want to bump Duke up to a rating of 60 and South Carolina up to a rating of 90.  I'm using these numbers for example.  Note that these ratings are on difference scales but what matters is how these ratings compare to other teams in the same tournament.  Further note, you should find your own teams that you want to adjust.  

Once you have decided which team ratings you want to later find the IDs for those teams in MTeamSpellings and/or WTeamSpellings (use the View function and then filter).  
Men's Duke is 1181 and Women's South Carolina is 3376.

Now, I'll the "massey" data frame we created to adjust the ratings.  I'll use the "case_when" function to change the Ratings of as many teams as I wish while having all other teams default to their Massey ratings:

```r

massey = 
  massey %>%
  mutate(
    Rating = case_when(
    TeamID == 1181 ~ 60,
    TeamID == 3376 ~ 90,
    .default = Rating
    )
  )

```

Take a look at the file to see that you've made the changes that you wish:

```r
View(massey)
```

Now, you can run the following code to update your predictions based on your altered ratings:

```r
games_with_ratings = 
  join_games_and_ratings(games, massey)

games_with_predictions = 
  add_massey_preds(games_with_ratings)
```

# How to Make a Submission File:

To submit to Kaggle we need to make a .csv file with just two columns: the game ID and Pred.  We can do that with the following code.  Note, you can give the file a more interesting name than "kaggle_predictions.csv" that will help you remember what you did in this set of predictions.

```r
write.csv(unite(games_with_predictions, 
                  col="ID", 
                  Season, team1, team2) %>%
            select(ID, Pred), 
          file="kaggle_predictions.csv",
          row.names = FALSE)

```

To code above created a file in your project folder that you can download and could submit to Kaggle in stage 2.

# How to Update these Predictions

More NCAA games will be played between now and the start of the tournament and you'll want to use the most up-to-date team ratings.  The good news, is that your predictions are easy to update:

1. Download new data from the Massey Website and upload it to posit.cloud as you did at the beginning of this lab (remmeber to change the names of the files).

2. Run the following code (which makes use of the function that you've already created):

```r
mratings = read.csv("mratings.csv")
wratings = read.csv("wratings.csv")

massey = clean_and_combine_masseys(mratings, wratings)

# alter the following with your team rating adjustments
# or delete this section entirely to use
# pure massey ratings

massey = 
  massey %>%
  mutate(
    Rating = case_when(
    TeamID == 1181 ~ 60,
    TeamID == 3376 ~ 90,
    .default = Rating
    )
  )

games_with_ratings = 
  join_games_and_ratings(games, massey)

games_with_predictions = 
  add_massey_preds(games_with_ratings)

write.csv(unite(games_with_predictions, 
                  col="ID", 
                  Season, team1, team2) %>%
            select(ID, Pred), 
          file="kaggle_predictions.csv",
          row.names = FALSE)
```
This will make a *new* .csv file with updated predictions.