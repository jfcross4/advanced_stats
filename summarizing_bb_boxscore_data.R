data = load_mbb_player_box(seasons = 2006:2024) 

cat_summary = 
nba_data %>%
  group_by(athlete_id, season) %>%
  summarize_at(
    vars(c(
      "athlete_display_name",
      "team_id",
      "team_name",
      "team_location")), first)

numeric_summary =      
nba_data %>%
  group_by(athlete_id, season) %>%
  summarize_at(
    vars(c(minutes:fouls, points:active)),
    sum, na.rm=TRUE)

nba_data = load_nba_player_box(seasons = 2006:2024) 
