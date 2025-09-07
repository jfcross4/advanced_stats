## How well does 538 predict the tournament

# The following files have 538's ratings for college basketball teams
# as the entered the NCAA tournaments from 2016 through the present
library(tidyverse)
M538 = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/538ratingsMen.csv")
W538 = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/538ratingsWomen.csv")

# Take a look a find the highest rated teams in this period
View(M538)
View(W538)

# You can find out more about how these ratings work here:
#https://fivethirtyeight.com/features/how-our-march-madness-predictions-work-2/

# How well do they predict the tournament?  
# To find out, let's match them up with past tournament results

# M_t_results = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/MNCAATourneyCompactResults.csv")
# W_t_results = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/WNCAATourneyCompactResults.csv")
# 
# View(M_t_results)
# 
# M_clean = clean_results(M_t_results)
# 
# clean_results = function(df){
#   df %>% 
#     filter(Season>=2016 & Season <= 2022) %>%
#     mutate(team1 = pmin(WTeamID, LTeamID),
#            team2 = pmax(WTeamID, LTeamID),
#            result = 1*(WTeamID==team1),
#            home = case_when(
#              WLoc == "N" ~ 0,
#              WLoc == "H" ~ 2*result-1, 
#              WLoc == "A" ~ 1-2*result,
#            )
#     ) %>%
#     select(Season, team1, team2, result, home)
# }
# 
# W_clean = clean_results(W_t_results)
# write.csv(M_clean, "stage2data/Mresults2016_2022.csv", row.names = FALSE)
# write.csv(W_clean, "stage2data/Wresults2016_2022.csv", row.names = FALSE)

M_results = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/Mresults2016_2022.csv")
W_results = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/Wresults2016_2022.csv")

source("add_game_rounds.R")

Mseeds = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/MNCAATourneySeeds.csv")
Wseeds = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/WNCAATourneySeeds.csv")

library(tidyverse)
M_results_w_seeds = 
  add_game_rounds(M_results, Mseeds)

W_results_w_seeds = 
  add_game_rounds(W_results, Wseeds)

View(M_results)
View(W_results)

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

pred538 <- function(r1, r2){
  1/(1+ 10^((r2-r1)*30.464/400))
}

Mresults_with_ratings = Mresults_with_ratings %>% 
  mutate(Pred = pred538(team1rating, team2rating))

Mresults_with_ratings %>%
  ggplot(aes(Pred, result))+
  geom_point()+
  geom_smooth(method="lm")+
  geom_abline(slope=1, intercept=0,
              color="red")+
  facet_wrap(~Season)

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

Wresults_with_ratings = Wresults_with_ratings %>% 
  mutate(Pred = pred538(team1rating, team2rating))


Wresults_with_ratings %>%
  ggplot(aes(Pred, result))+
  geom_point()+
  geom_smooth(method="lm")+
  geom_abline(slope=1, intercept=0,
              color="red")

RMSE = function(x,y){
  sqrt(mean((x-y)^2))}

Wresults_with_ratings %>%
  summarize(RMSE(Pred, result))

Mresults_with_ratings %>%
  summarize(RMSE(Pred, result))

home_adj <- function(pred, home, size=1.656){
  odds <- (pred/(1-pred))*size^home
  return(odds/(odds+1))
}

Wresults_with_ratings = 
Wresults_with_ratings %>%
  mutate(adjPred = home_adj(Pred, home))

Wresults_with_ratings %>%
  summarize(RMSE(adjPred, result))

Wresults_with_ratings %>%
  summarize(RMSE(Pred, result))

Wresults_with_ratings = 
  Wresults_with_ratings %>%
  mutate(adjPred = home_adj(Pred, home, size=0.8))


Wresults_with_ratings %>%
  summarize(RMSE(adjPred, result))

m = nls(result ~ 
      1/(1+ 10^((team2rating-team1rating)*a/400)),
    data=Mresults_with_ratings,
    start=list(a=30))

summary(m)

mM1 = nls(result ~ 
          1/(1+ 10^((team2rating-team1rating)*a/400)),
        data=Mresults_with_ratings %>% 
          filter(meeting_round==1),
        start=list(a=30))

summary(mM1) #first round

mM2plus = nls(result ~ 
            1/(1+ 10^((team2rating-team1rating)*a/400)),
          data=Mresults_with_ratings %>% 
            filter(meeting_round>=2),
          start=list(a=30))

summary(mM2plus)

mW1 = nls(result ~ 
            1/(1+ 10^((team2rating-team1rating)*a/400)),
          data=Wresults_with_ratings %>% 
            filter(meeting_round==1),
          start=list(a=30))

summary(mW1)

mW2plus = nls(result ~ 
            1/(1+ 10^((team2rating-team1rating)*a/400)),
          data=Wresults_with_ratings %>% 
            filter(meeting_round>=2),
          start=list(a=30))

summary(mW2plus)

pred538_adjusted <- function(r1, r2){
  1/(1+ 10^((r2-r1)*24.3/400))
}

Mresults_with_ratings = Mresults_with_ratings %>% 
  mutate(Pred_adj = pred538_adjusted(team1rating, team2rating))

Mresults_with_ratings %>%
  summarize(
    RMSE(Pred, result),
    RMSE(Pred_adj, result)
  )

Mresults_with_ratings %>%
  ggplot(aes(Pred_adj, result))+
  geom_point()+
  geom_smooth()+
  geom_abline(slope=1, intercept=0,
              color="red")

Mresults_with_ratings %>%
  ggplot(aes(Pred, Pred_adj))+
  geom_point()+
  geom_abline(slope=1, intercept=0,
              color="red")

m = nls(result ~ 
          1/(1+ 10^((team2rating-team1rating)*a/400)),
        data=Wresults_with_ratings,
        start=list(a=30))
summary(m) #24.7



Wresults_with_ratings = Wresults_with_ratings %>% 
  mutate(Pred_adj = pred538_adjusted(team1rating, team2rating))

Wresults_with_ratings %>%
  summarize(
    RMSE(Pred, result),
    RMSE(Pred_adj, result)
  )

Wresults_with_ratings = 
  Wresults_with_ratings %>%
  mutate(PredHF = home_adj(Pred_adj, home, size=1.1))

home_adj <- function(pred, home, size=1.656){
  odds <- (pred/(1-pred))*size^home
  return(odds/(odds+1))
}

m_home = nls(result ~ 
               ((Pred_adj/(1-Pred_adj))*size^home)/
               ((Pred_adj/(1-Pred_adj))*size^home+1),
             data=Wresults_with_ratings,
             start=list(size=1.6))
             
summary(m_home)

Wresults_with_ratings = 
  Wresults_with_ratings %>%
  mutate(PredHF = home_adj(Pred_adj, home, size=1.08))


Wresults_with_ratings %>%
  summarize(
    RMSE(Pred, result),
    RMSE(Pred_adj, result),
    RMSE(PredHF, result)
  )

### Actual tournament predictions

sample_submission = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/SampleSubmission2023.csv")
summary(sample_submission)
View(sample_submission)
nrow(sample_submission) #131k rows
# most can be left as 0.5

library(reshape2)
games_to_predict = function(SampleSubmission){
  games.to.predict <- cbind(SampleSubmission$ID, 
                            colsplit(SampleSubmission$ID, 
                                     pattern = "_", 
                                     names = c('Season', 'team1', 'team2')))   
  colnames(games.to.predict)[1] <- "ID"
  games.to.predict$home <- 0
  return(games.to.predict)
}

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


Wgames_with_ratings = 
Wgames_with_ratings %>%
  mutate(Pred = pred538_adjusted(team1rating, team2rating))

Mgames_with_ratings = 
  Mgames_with_ratings %>%
  mutate(Pred = pred538_adjusted(team1rating, team2rating))

games_with_ratings = rbind(Wgames_with_ratings,
      Mgames_with_ratings)

# just in case
games_with_ratings$Pred[is.na(games_with_ratings$Pred)] = 0.50
# piece together and replace NA with 0.5
summary(games_with_ratings)

write.csv(games_with_ratings %>%
            select(ID, Pred), 
          file="Jared_winning_predictions.csv",
          row.names = FALSE)
# Submit your predictions to
#Kaggle: March Machine Learning Mania 2023