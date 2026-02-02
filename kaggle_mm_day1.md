Kaggle March Madness Day 1
------------------------------------------------

[Kaggle](https://www.kaggle.com/) is a website for data science forecasting competitions.  
Every year they have a ["March Madness" competition](https://www.kaggle.com/competitions/march-machine-learning-mania-2025/overview/description) where competitors the results of Men's and Women's NCAA Basketball tournament games.

Today, we'll start preparing to enter this competition.

# Why do I need Statistics?

You may be used to filling out a bracket and choosing which team will win every game.  You can do this without code or even statistics!  How is this competition different?

1. You will be predicting the results of many more game!

You are going to predict the result of every matchup that could possibly happen.  In theory every team could end up playing every other team and you'll need to submit your predictions before the "first four" 
so there will be 68 teams and **68 choose 2** possible matchups.

${68 \choose 2} = 2278$

You will need to do this for both the Men's and Women's tournaments so you will be making
$2278 \cdot 2 = 4556$ predictions.

2. You are not just predicting who will win!  Historically, competitors have been asked to not just predict a winner but to predict the *probability* of each team winning.  Their predictions are then evaulated on how well these predictions match realiaty.

So, in short, you'll need to come up with 4556 probabilities.  This means making a mathematical model and using it to predict game outcomes!

The exact rules for the 2026 competition are not public yet and the rules change from year to year but we can look back on data and rules from previous years to help us prepare.

# A New Project

Most of our previous projects were one day projects but we'll be working on this project for a while.  You should start a new project in posit.cloud and name it (something like "March Madness") and save all of your code from this project in R scripts.

# The Data

Let's start at the end.  To participate in the competion, you will need to submit (upload) a file 
with you predictions.  The file will look like this:

```r
submission_file = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/master/stage2data/SampleSubmission2023.csv")

View(submission_file)
```

The **"ID"** column is the ID for each game that might occur.  

It contains three pieces of information:

* The year (this old submission file is from 2023, you'll have a submission file for 2026).
* The ID of Team 1 (simply the team that comes first alphabetically)
* The ID of Team 2

We'll match these ID's up with team names.  

The second column is **"Pred".** This is the predicted probability that Team 1 would beat Team 2 if this matchup takes place.  By defaults, these predictions are all set to 0.5 but everything else we do in this project will be ultimately aimed at changing this Pred column to make these predictions better.

# How do you make good predictions?

Our mathematical models need to be based on experience.  In other words, we need to build models that would have accurately predicted games in the past and hope that those same models will work going forward.

Let's look at the results of 2016-2022 tournament games in both the Men's and Women's tournaments:

```r
Mresults = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/master/stage2data/Mresults2016_2022.csv")
Wresults = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/master/stage2data/Wresults2016_2022.csv")

View(Mresults)
View(Wresults)
```

These tables show the results of tournamnet games from 2016 through 2022.  
Notice that the *result* column takes on values of 0 or 1.  
It is 1 if team 1 beat team 2 and 0 if team 2 won that game.  
The *home* column denotes home field advantage.  
Notice that it has the value of 0 for all Men's game since, strictly speaking, no Men's tournament games take place at a school's home court.  In the women's tournament, however the top seeds (1 through 4) have home games in the first two rounds.  

* If the home team was team 1, the *home* column takes on the value of 1.  
* If the home team was team 2, the *home* column takes on the value -1.  
* If neither team was at home, the home column takes the value 0.

We can use historical data to determine how big of an advantage it is to play at home.

# A simple seeds based model

Ultimately, we'll want to use data on how these team's performed in the regular season to predict how they will later perform in the tournament but, just to give a sense of how we might build a model, we can start with a simple model based only on seeds.  Higher seeds are more likely to win, and lower seeds are less likely to win.

Let's get data on what each team's see was entering past tournaments.  We'll start with the Men's tournament where we don't need to think about home field advantage, 
we'll then circle back and look at the Women's tournament add in home field advantage.

```r
Mseeds = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/master/stage2data/MNCAATourneySeeds.csv")

View(Mseeds)
```

The first row of this data set shows that in 1985 Team # 1207 was the #1 seed in the W region.  The four regions are labelled W, X, Y and Z.

# gsub

**gsub** lets us substitute one pattern in for another for instance:

```r
x = c("a;sfjda;skdjajkdk;ji;ehj;ahgkdgh;a")

gsub("a", "A", x)
```
*What did gsub do?*

You can also use gsub to replace any charactor or any number... for instance:

```r
x = c("1234abcd5678efgh")
gsub("[A-Z+a-z]", "Char", x)
gsub("[0-9]", "Num", x)
```
Let's use gsub to split the "Seed" column into a region and a seed number.  I'll also need the help of tidyverse:

```r
library(tidyverse)

Mseeds = 
Mseeds %>% 
    mutate(SeedNum = as.numeric(gsub("[A-Z+a-z]", "", Seed)),
          Region = gsub("[0-9]", "", Seed))  

View(Mseeds)
```

# Joins

Now I have a data table that has teams and their seeds ("Mseeds") and a data table that has the resutls of tournament games ("Mresults").  I want to join this two data tables together to see how seeds predicts results.  A few of you (who finished the data visualization course on DataCamp and moved on to joins) know what's coming next.

I have to look at the two tables and see what columns they have in common so that I can line them up:

```r
head(Mseeds)

head(Mresults)
```

Both tables have a "Season" column and I can match up the "TeamID" column from the Mseeds table with either the team1 or team2 column from the Mresults table.

I'll use team1 first.  Here's how that looks:

```r
inner_join(Mresults, Mseeds, by=c("Season", "team1"="TeamID"))
```
This created a table that has the results from seasons 2016-2022 *and* the Seed, SeedNum and Region for team1.  I only really need the SeedNum for team1 and I want to clarify that it is the SeedNum for team1 and not team2 so I'll rewrite this code as:

```r
inner_join(Mresults, 
    Mseeds %>% select(Season, TeamID, Seed1 = SeedNum), 
    by=c("Season", "team1"="TeamID"))
```

Lastly, I want give this dataframe I created a name:

```r
Mgames = 
inner_join(Mresults, 
    Mseeds %>% select(Season, TeamID, Seed1 = SeedNum), 
    by=c("Season", "team1"="TeamID"))
```

Now, I'm going to add in the seeds for team2 but I'm not going to add them to Mresults but rather to this new data table we just made that already has the team1 seeds.  We'll overwrite the Mgames table we just created.

```r
Mgames = 
inner_join(Mgames, 
    Mseeds %>% select(Season, TeamID, Seed2 = SeedNum), 
    by=c("Season", "team2"="TeamID"))
    
View(Mgames)
```

Now, let's calculate the difference between seeds:

```r
Mgames = 
Mgames %>% 
  mutate(SeedDiff = Seed1 - Seed2)
```
and then we can plot this data:

```r
Mgames %>% 
  ggplot(aes(SeedDiff, result)) + 
  geom_point() + 
  geom_smooth()
```
This best fit line is very nearly a straight line.  We can fit a straight line to this data.

```r
Mgames %>% 
  ggplot(aes(SeedDiff, result)) + 
  geom_point() + 
  geom_smooth(method="lm")
```

How would you interpret this line?  If you want the equation for this line, you can run the following code which will give the y-intercept and slope of the line:

```r
lm(result ~ SeedDiff, data=Mgames)
```

This is our first model!  We could use this model to predict the chance of any team winning any tournament game!

Can you come up with a better equation?

What other information would you want to use to build your model?









