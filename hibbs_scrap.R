file = "https://raw.githubusercontent.com/avehtari/ROS-Examples/master/ElectionsEconomy/data/hibbs.dat"
hibbs <- read.table(file, header=TRUE)

library(tidyverse)

hibbs %>% ggplot(aes(growth, vote))+
  geom_text(aes(label=inc_party_candidate)) +
  geom_smooth(method="lm", se=FALSE)

m = lm(vote ~ growth, data = hibbs)
summary(m)

2*(1-pt(3.0605/0.6963, df=14))

fair = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/fair.csv")

fair = fair %>%
  mutate(incumbent_vote = 50 + I*(VP-50),
         incumbent_running_again = abs(DPER),
         length_party_control = abs(DUR))

fair_hibbs = left_join(hibbs, fair, by="year")

m1 = lm(vote ~ growth, data=fair_hibbs)

m2  = lm(vote ~ G, data = fair_hibbs)

summary(m1)
summary(m2)

#Question 7: 
# Which appears to be a better predictor 
# of the vote share?

m3 = lm(vote ~ growth + 
          length_party_control, 
        data=fair_hibbs)

m_really_cool_4_vars = lm(vote ~ growth + 
          length_party_control +
          incumbent_running_again + 
          P, 
        data=fair_hibbs)
summary(m_really_cool_4_vars)

