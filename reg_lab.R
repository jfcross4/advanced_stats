library(tidyverse)

games = read.csv("https://raw.githubusercontent.com/professorkalim/stats22-23/cross/nfl_game_results.csv")


results_by_half = 
  games %>%
  group_by(season, team, half) %>%
  summarize_at(c("win", "loss", "tie"), sum) %>%
  mutate(games = win+loss+tie, 
         win_pct = (win + 0.5*tie)/games)

View(results_by_half)

results_by_even = 
  games %>%
  group_by(season, team, even_wk) %>%
  summarize_at(c("win", "loss", "tie"), sum) %>%
  mutate(games = win+loss+tie, 
         win_pct = (win + 0.5*tie)/games)

View(results_by_even)

results_by_half_wide = 
  results_by_half %>%
  pivot_wider(id_cols = c(season, team),
              names_from=half,
              values_from = win_pct) %>%
  ungroup()

View(results_by_half_wide)

results_by_even_wide = 
  results_by_even %>%
  pivot_wider(id_cols = c(season, team),
              names_from=even_wk,
              values_from = win_pct) %>%
  ungroup()

View(results_by_even_wide)

results_by_half_wide %>%
  ggplot(aes(first, second)) + 
  geom_jitter() + 
  geom_smooth(method="lm")