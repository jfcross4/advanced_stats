## Packages
library(tidyverse)
library(reshape2)

## Kaggle and 538 Data Files
M538 = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/538ratingsMen.csv")
W538 = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/538ratingsWomen.csv")

M_results = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/Mresults2016_2022.csv")
W_results = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/Wresults2016_2022.csv")

Mseeds = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/MNCAATourneySeeds.csv")
Wseeds = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/WNCAATourneySeeds.csv")

sample_submission = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/SampleSubmission2023.csv")

## Functions

RMSE = function(x,y){
  sqrt(mean((x-y)^2))}

## To add the rounds in which teams will meet
add_game_rounds <- function(games, Seeds){
  Seeds = Seeds %>% 
    dplyr::select(Seed, TeamID, Season) %>% 
    mutate(Seed=substr(Seed, 1, 3),
           Division = substr(Seed, 1, 1),
           Rank = as.numeric(substr(Seed, 2, 3)))
  
  orig_columns = colnames(games)
  
  games = left_join(games, Seeds %>% 
                      rename(Seed1=Seed, 
                             Division1=Division, 
                             Rank1=Rank), 
                    by=c("team1"="TeamID", "Season"))
  games = left_join(games, Seeds %>% 
                      rename(Seed2=Seed, 
                             Division2=Division, 
                             Rank2=Rank), 
                    by=c("team2"="TeamID", "Season"))
  
  
  games = games %>% mutate(
    same_division = ifelse(Division1==Division2, 1, 0),
    same_side = case_when(
      same_division == 1 ~ 1,
      Division1 %in% c("X", "W") & 
        Division2 %in% c("X", "W") ~ 1,
      Division1 %in% c("Y", "Z") & 
        Division2 %in% c("Y", "Z") ~ 1,
      Division1 %in% c("X", "W") & 
        Division2 %in% c("Y", "Z") ~ 0,
      Division1 %in% c("Y", "Z") & 
        Division2 %in% c("X", "W") ~ 0
    )
  )
  
  games = games %>% mutate(
    round_of_32_team1 = case_when(
      Rank1 %in% c(1, 8, 9, 16) ~ "a",
      Rank1 %in% c(2, 7, 10, 15) ~ "b",
      Rank1 %in% c(3, 6, 11, 14) ~ "c",
      Rank1 %in% c(4, 5, 12, 13) ~ "d"
    ),
    round_of_32_team2 = case_when(
      Rank2 %in% c(1, 8, 9, 16) ~ "a",
      Rank2 %in% c(2, 7, 10, 15) ~ "b",
      Rank2 %in% c(3, 6, 11, 14) ~ "c",
      Rank2 %in% c(4, 5, 12, 13) ~ "d"
    ),
    round_of_16_team1 = case_when(
      round_of_32_team1 %in% c("a", "d") ~ "a",
      round_of_32_team1 %in% c("b", "c") ~ "b"
    ),
    round_of_16_team2 = case_when(
      round_of_32_team2 %in% c("a", "d") ~ "a",
      round_of_32_team2 %in% c("b", "c") ~ "b"
    ),
    meeting_round = case_when(
      same_side == 0 ~ 6,
      same_side == 1 & same_division==0 ~ 5,
      Rank1 + Rank2 == 17 ~ 1,
      round_of_32_team1 == round_of_32_team2 ~ 2,
      round_of_16_team1 == round_of_16_team2 ~ 3,
      round_of_16_team1 != round_of_16_team2 ~ 4
    )) %>% dplyr::select(all_of(orig_columns), 
                         meeting_round, 
                         Rank1, Rank2, 
                         Division1, Division2)
  return(games)
}


## To make predictions from 538 ratings
# pred538 <- function(r1, r2){
#   1/(1+ 10^((r2-r1)*30.464/400))
# }

## To adjust odds for HFA in Women's tournament
home_adj <- function(pred, home, size=1.1){
  odds <- (pred/(1-pred))*size^home
  return(odds/(odds+1))
}

### To get team names from sample submission file
games_to_predict = function(SampleSubmission){
  games.to.predict <- cbind(SampleSubmission$ID, 
                            colsplit(SampleSubmission$ID, 
                                     pattern = "_", 
                                     names = c('Season', 'team1', 'team2')))   
  colnames(games.to.predict)[1] <- "ID"
  games.to.predict$home <- 0
  return(games.to.predict)
}

### Finding Parameters based on past year's data

M_results_w_seeds = 
  add_game_rounds(M_results, Mseeds)

W_results_w_seeds = 
  add_game_rounds(W_results, Wseeds)

Mresults_with_ratings =M_results_w_seeds %>% 
  left_join(M538 %>% 
              select(Season, 
                     TeamID, 
                     team1rating = X538rating),
            by=c("Season", "team1"="TeamID")) %>%
  left_join(M538 %>% 
              select(Season, 
                     TeamID, 
                     team2rating = X538rating),
            by=c("Season", "team2"="TeamID"))


Wresults_with_ratings = W_results_w_seeds %>% 
  left_join(W538 %>% 
              select(Season, 
                     TeamID, 
                     team1rating = X538rating),
            by=c("Season", "team1"="TeamID")) %>%
  left_join(W538 %>% 
              select(Season, 
                     TeamID, 
                     team2rating = X538rating),
            by=c("Season", "team2"="TeamID"))


## checking the 538 formula

mM = nls(result ~ 
          1/(1+ 10^((team2rating-team1rating)*a/400)),
        data=Mresults_with_ratings,
        start=list(a=30))
summary(mM) # a= 24.3 +/- 3.3

mW = nls(result ~ 
           1/(1+ 10^((team2rating-team1rating)*a/400)),
         data=Wresults_with_ratings,
         start=list(a=30))
summary(mW) # a= 24.7 +/- 2.9

pred538_adjusted <- function(r1, r2){
  1/(1+ 10^((r2-r1)*25/400))
}

Mresults_with_ratings = Mresults_with_ratings %>% 
  mutate(Pred = pred538_adjusted(team1rating, team2rating))

Wresults_with_ratings = Wresults_with_ratings %>% 
  mutate(Pred = pred538_adjusted(team1rating, team2rating))

m_home = nls(result ~ 
               ((Pred/(1-Pred))*size^home)/
               ((Pred/(1-Pred))*size^home+1),
             data=Wresults_with_ratings,
             start=list(size=1.6))
summary(m_home) #HFA appears to make little difference
# in the Women's tournament

results_with_ratings = rbind(Wresults_with_ratings %>%
        select(team1rating, team2rating, meeting_round, result),
      Mresults_with_ratings %>%
        select(team1rating, team2rating, meeting_round, result)
      )

m_round1 = nls(result ~ 
                1/(1+ 10^((team2rating-team1rating)*a/400)),
              data=results_with_ratings %>% 
                filter(meeting_round==1),
              start=list(a=30))
summary(m_round1) # a=25.5 +/- 3.2

m_round2plus = nls(result ~ 
                 1/(1+ 10^((team2rating-team1rating)*a/400)),
               data=results_with_ratings %>% 
                 filter(meeting_round>=2),
               start=list(a=30))
summary(m_round2plus) # a=23.5

m_round = nls(result ~ 
                     1/(1+ 10^((team2rating-team1rating)*
                                 (a - r*meeting_round)/400)),
                   data=results_with_ratings,
                   start=list(a=30, r=1))
summary(m_round)

m_round = nls(result ~ 
                1/(1+ 10^((team2rating-team1rating)*
                            (28 - r*meeting_round)/400)),
              data=results_with_ratings,
              start=list(r=1))
summary(m_round)

pred538_round_adjusted <- function(r1, r2, meeting_round){
  1/(1+ 10^((r2-r1)*(28-1.7*meeting_round)/400))
}

Mresults_with_ratings = Mresults_with_ratings %>% 
  mutate(Pred_adj = 
           pred538_round_adjusted(team1rating, 
                                  team2rating,
                                  meeting_round))

Mresults_with_ratings %>%
  summarize(
    RMSE(Pred, result),
    RMSE(Pred_adj, result)
  )

Wresults_with_ratings = Wresults_with_ratings %>% 
  mutate(Pred_adj = 
           pred538_round_adjusted(team1rating, 
                                  team2rating,
                                  meeting_round))

Wresults_with_ratings %>%
  summarize(
    RMSE(Pred, result),
    RMSE(Pred_adj, result)
  )

### Making 2023 Predictions

sample_submission = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/SampleSubmission2023.csv")

games = games_to_predict(sample_submission)

Wgames = games %>% filter(team1 >= 3000)
Mgames = games %>% filter(team1 < 3000)

Mgames_with_ratings = Mgames %>% 
  left_join(M538 %>% 
              select(Season, 
                     TeamID, 
                     team1rating = X538rating),
            by=c("Season", "team1"="TeamID")) %>%
  left_join(M538 %>% 
              select(Season, 
                     TeamID, 
                     team2rating = X538rating),
            by=c("Season", "team2"="TeamID"))

Wgames_with_ratings = Wgames %>% 
  left_join(W538 %>% 
              select(Season, 
                     TeamID, 
                     team1rating = X538rating),
            by=c("Season", "team1"="TeamID")) %>%
  left_join(W538 %>% 
              select(Season, 
                     TeamID, 
                     team2rating = X538rating),
            by=c("Season", "team2"="TeamID"))

## figure out rounds

Mgames_with_ratings = 
  add_game_rounds(Mgames_with_ratings, Mseeds)

Wgames_with_ratings = 
  add_game_rounds(Wgames_with_ratings, Wseeds)

Wgames_with_ratings = 
  Wgames_with_ratings %>%
  mutate(Pred = 
           pred538_round_adjusted(team1rating, 
                            team2rating,
                            meeting_round))

Mgames_with_ratings = 
  Mgames_with_ratings %>%
  mutate(Pred = 
           pred538_round_adjusted(team1rating, 
                                  team2rating,
                                  meeting_round))

games_with_ratings = rbind(Wgames_with_ratings,
                           Mgames_with_ratings)

games_with_ratings$Pred[is.na(games_with_ratings$Pred)] = 0.50

## Submission 1: Alabama and SC win it all

games_with_ratings_submission1 = 
  games_with_ratings %>%
  mutate(Pred = ifelse(team1==1104, 1, Pred),
         Pred = ifelse(team2==1104, 0, Pred),
         Pred = ifelse(team1==3376, 1, Pred),
         Pred = ifelse(team2==3376, 0, Pred),
         )

## Submission 2: Gonzaga wins it all

games_with_ratings_submission2 = 
  games_with_ratings %>%
  mutate(Pred = ifelse(team1==1211, 1, Pred),
         Pred = ifelse(team2==1211, 0, Pred)
  )

## making files

write.csv(games_with_ratings_submission1 %>%
            select(ID, Pred), 
          file="kaggle_submission1_alabama_and_sc.csv",
          row.names = FALSE)

write.csv(games_with_ratings_submission2 %>%
            select(ID, Pred), 
          file="kaggle_submission2_gonzaga.csv",
          row.names = FALSE)
