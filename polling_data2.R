library(tidyverse)

pres_polls = read.csv("https://projects.fivethirtyeight.com/polls-page/data/president_polls.csv")

pres_polls = 
  pres_polls %>% 
  select(poll_id, pollster_id, pollster, numeric_grade, pollscore,
         methodology, state, start_date, end_date, question_id,
         sample_size, population, partisan, party, answer,
         candidate_id, candidate_name, pct)

factor_variables = 
  c("poll_id", "pollster_id", "pollster", "methodology", 
    "state", "population",
    "partisan", "party", "answer", "candidate_id",
    "candidate_name")

date_variables = c("start_date", "end_date")


pres_polls = pres_polls %>%
  mutate_at(factor_variables, as.factor) %>%
  mutate_at(date_variables, as.Date,
            tryFormats = c("%m/%d/%y"))

pres_polls_wider = 
pres_polls %>%
  filter(answer %in% c("Trump", "Harris", "Stein", "Oliver",
                       "West", "Kennedy")) %>%
  pivot_wider(
    id_cols = poll_id:partisan,
    names_from = answer,
    values_from = pct
  )

pres_polls_wider = 
  pres_polls_wider %>%
  filter(partisan == "",
         start_date > "2024-07-21",
         population == "lv",
         !is.na(Harris),
         !is.na(Trump))

pres_polls_wider = 
pres_polls_wider %>%
  mutate(
    Harris_share = Harris/(Harris + Trump),
    Trump_share = Trump/(Harris + Trump)
  )

pres_polls_wider %>%
  filter(state == "") %>%
  ggplot(aes(start_date, Harris_share)) +
  geom_point() + geom_smooth()

pres_polls_wider %>%
  filter(state == "") %>%
  summarize(num_polls=n(), 
            avg_Harris = mean(Harris_share),
            avg_Trump = mean(Trump_share))

pres_polls_wider %>%
  filter(state == "") %>%
  ggplot(aes(start_date, Harris_share), col="blue") +
  geom_smooth()

pres_polls_wider %>%
  filter(state == "Pennsylvania") %>%
  summarize(num_polls=n(), 
            avg_Harris = mean(Harris),
            avg_Trump = mean(Trump),
            sd_Harris = sd(Harris),
            sd_Trump = sd(Trump))

pres_polls_wider %>%
  filter(state == "Pennsylvania") %>%
  ggplot(aes(start_date, Harris_share)) +
  geom_smooth(aes(start_date, Harris_share),
              col="blue") +
  geom_smooth(aes(start_date, Trump_share),
              col="red")

# weights

pres_polls_wider = 
pres_polls_wider %>%
  mutate(
    days_ago = as.numeric((Sys.Date() - 
      end_date)),
    recency_weight = .95^days_ago,
    sample_size_weight = 
      sample_size/(1000 + sample_size),
    poll_quality_weight = numeric_grade,
    overall_weight = 
      recency_weight*sample_size_weight*poll_quality_weight
  ) %>% 
  filter(!is.na(overall_weight))

pres_polls_wider %>%
  filter(state == "") %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump*overall_weight)/
              sum(overall_weight))

pres_polls_wider %>%
  filter(state == "Pennsylvania") %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump*overall_weight)/
              sum(overall_weight))

swing_states =
  c("Pennsylvania",
    "Michigan",
    "Wisconsin",
    "Nevada",
    "Georgia",
    "North Carolina",
    "Arizona")

pres_polls_wider %>%
  filter(state %in% swing_states) %>%
  group_by(state) %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris_share*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump_share*overall_weight)/
              sum(overall_weight)) %>%
  arrange(avg_Harris)

pres_polls_wider %>%
  filter(state %in% swing_states) %>%
  group_by(state) %>%
  summarize(num_polls=n(), 
            avg_Harris = sum(Harris_share*overall_weight)/
              sum(overall_weight),
            avg_Trump = sum(Trump_share*overall_weight)/
              sum(overall_weight)) %>%
    mutate(Margin = avg_Harris - avg_Trump) %>%
  arrange(desc(Margin))
