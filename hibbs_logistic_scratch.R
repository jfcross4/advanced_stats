file = "https://raw.githubusercontent.com/avehtari/ROS-Examples/master/ElectionsEconomy/data/hibbs.dat"
hibbs <- read.table(file, header=TRUE)

library(tidyverse)

hibbs = 
hibbs %>% 
  mutate(won_pop = ifelse(vote>=50, 1, 0))

m = lm(won_pop ~ growth,
   data=hibbs)

hist(predict(m))

growth_seq =seq(-2, 5, 0.1)
plot(growth_seq, 
predict(m, newdata=data.frame(growth=growth_seq)),
ylab="predicted chance of winning", type="l")
points(hibbs$growth, hibbs$won_pop)

m_log_odds = glm(won_pop ~ growth,
       data=hibbs,
       family="binomial")

summary(m_log_odds)

plot(growth_seq, 
     predict(m_log_odds, 
             newdata=data.frame(growth=growth_seq),
             type="response"),
     ylab="predicted chance of winning", type="l")
