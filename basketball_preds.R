Mresults = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/MRegularSeasonCompactResults.csv")

Wresults =
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/WRegularSeasonCompactResults.csv")


Wteamspellings =
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/WTeamSpellings.csv")

Mteamspellings =
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/MTeamSpellings.csv")

M_tournament_games = 
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/MSampleSubmissionStage2.csv")

W_tournament_games =
  read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/stage2data/WSampleSubmissionStage2.csv")

#https://rpubs.com/jcross/log5_2018

transform_df = function(df, season=2022){
  df %>% mutate(home = case_when(
    WLoc == "N" ~ 0,
    WLoc == "H" ~ 1,
    WLoc == "A" ~ -1,
    TRUE ~ 0))
  
  sub1 <- df %>% 
    filter(Season==season) %>% 
    mutate(team1=as.factor(WTeamID), 
           team2=as.factor(LTeamID), 
           outcome=1) %>% 
    select(team1, team2, home, outcome)
  
  sub2 <- df %>% 
    filter(Season==season) %>% 
    mutate(team1=as.factor(LTeamID), 
           team2=as.factor(WTeamID), 
           home=-1*home, outcome=0) %>% 
    select(team1, team2, home, outcome)
  reg.results <- rbind(sub1, sub2)
  }

Mresults2022 = transform_df(Mresults, season=2022)

library(lme4)

mbt <- glmer(outcome ~ home +  (1 | team1) + 
               (1 | team2), data = Mresults2022, 
             family = binomial) 
exp(coef(mbt)$team1$home[1])

arrange(ranef(mbt)$team1)
