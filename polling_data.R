library(tidyverse)

pres_polls = read.csv("https://projects.fivethirtyeight.com/polls-page/data/president_polls.csv")

#View(pres_polls)
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

polls_to_remove = 
pres_polls %>%
  filter(candidate_name == "JD Vance" |
           candidate_name == "Joe Biden") %>%
  pull(question_id) %>%
  unique()

pres_polls = 
pres_polls %>%
  filter(partisan == "",
         start_date > "2024-07-21",
         population == "lv",
         !(question_id %in% polls_to_remove))

pres_polls %>%
  filter(state == "") %>%
  group_by(candidate_name) %>%
  summarize(num_polls=n(), 
            avg_vote = mean(pct)) %>%
  arrange(desc(avg_vote))

pres_polls %>%
  filter(state == "Pennsylvania") %>%
  group_by(state, candidate_name) %>%
  summarize(num_polls=n(), 
            avg_vote = mean(pct),
            sd_vote = sd(pct)) %>%
  arrange(desc(avg_vote))

# Remove Polls with Kennedy
# Filter by Date (more restrictive)
# Try other states