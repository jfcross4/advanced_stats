### takes games to predict and joins
### it with seeds to figure out rounds
### of different games

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
