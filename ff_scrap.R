ff = read.csv("combined_2023_FF_data.csv")
View(ff)
library(tidyverse)

ff %>% group_by(PLAYER.POSITION) %>%
  summarize(n = n())

ff_colnames = 
  c("player", "team", "position",
       "game_outcome", "projected_pts", "pass_yds",
    "pass_td", "pass_int", "rush_carries",
    "rush_yds", "rush_td", "receptions",
    "rec_yds", "rec_td", "rec_targets",
    "two_pt_conv", "fumbles", "misc_td",
    "actual_pts", "pass_completions", "pass_attempts",
    "opp_team", "home_away", "position_rank", 
    "date", "week")

colnames(ff) = ff_colnames


ff = ff %>% 
  filter(position != "PLAYER POSITION")

ff = 
  ff %>% filter(team != "FA", opp_team != "*BYE*",
                !is.na(actual_pts))

ff = ff %>%
  group_by(player, week) %>%
  slice_max(n=1, projected_pts, with_ties=FALSE) %>%
  ungroup()

#write.csv(ff, "2023_fantasy_football_data.csv", row.names = FALSE)
ff = read.csv("2023_fantasy_football_data.csv")


ff %>% ggplot(aes(projected_pts, actual_pts))+
  geom_point()+geom_smooth()

ff %>% filter(projected_pts==0) %>%
  ggplot(aes(actual_pts))+
  geom_histogram()

ff %>% filter(projected_pts > 0) %>% 
  ggplot(aes(projected_pts, actual_pts))+
  geom_point() + geom_smooth()+
  facet_wrap(~position)

ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(projected_pts))+
  geom_histogram()+
  facet_wrap(~position)

ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(actual_pts))+
  geom_histogram()+
  facet_wrap(~position)
 


ff = ff %>%
  mutate(pts_over_exp = actual_pts - projected_pts)

ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(pts_over_exp))+
  geom_histogram()+
  facet_wrap(~position)

ff = 
ff %>%
  separate(game_outcome, into=c("outcome", "score"), sep=" ")

ff = 
  ff %>%
  separate(score, into=c("tm_score", "opp_score"), sep="-")



ff = 
  ff %>%
  mutate(total_td = pass_td + rush_td + rec_td + misc_td)

ff %>% filter(projected_pts > 0) %>%
  ggplot(aes(projected_pts, pts_over_exp, 
             color=as.factor(total_td)))+
  geom_point()+
  facet_wrap(~position)

ff %>% filter(projected_pts >= 10, !is.na(actual_pts)) %>%
  group_by(position, outcome) %>%
  summarize(proj = mean(projected_pts), 
            actual = mean(actual_pts),
            over_exp = mean(pts_over_exp))

ff %>% filter(projected_pts >= 10, !is.na(actual_pts)) %>%
  group_by(position) %>%
  summarize(proj = mean(projected_pts), 
            actual = mean(actual_pts),
            over_exp = mean(pts_over_exp))

ff %>% filter(projected_pts >= 8, !is.na(actual_pts)) %>%
  group_by(week) %>%
  summarize(proj = mean(projected_pts), 
            actual = mean(actual_pts),
            over_exp = mean(pts_over_exp))

ff %>% filter(projected_pts >= 8, !is.na(actual_pts)) %>%
  group_by(position) %>%
  summarize(cor(projected_pts, actual_pts))

ff %>% filter(projected_pts > 0, !is.na(actual_pts)) %>%
  group_by(position) %>%
  summarize(cor(projected_pts, actual_pts))

ff_wide = 
ff %>%
  select(player, week, pts_over_exp) %>%
  arrange(week) %>%
  pivot_wider(id_cols = player, 
              names_from = week,
              values_from = pts_over_exp,
              names_prefix = "week")


ff_wide %>%
  summarize(cor(week15, week16, use="pairwise.complete"))

ff_wide %>%
  ggplot(aes(week15, week16)) + 
  geom_point() +
  geom_smooth(method="lm")+
  ggtitle("points over expected")
