### lab

library(tidyverse)

games = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/refs/heads/cross/ncaa_basketball_games_2025.csv")

View(games)

games %>%
  ggplot(aes(TO_margin, PT_margin))+
  geom_point()+
  geom_smooth(method="lm")

m = lm(PT_margin ~ TO_margin, data=games)

summary(m)

m = lm(PT_margin ~ PF_margin, data=games)
summary(m)


# 1. High School Softball Bench

before <- c(185, 190, 135, 180, 170, 185, 178, 82, 179, 174)
after <- c(190, 200, 140, 195, 175, 192, 185, 95, 188, 182)

t.test(before, after, paired=TRUE, 
       alternative = "less")


softball = data.frame(before, after)

softball = 
softball %>%
  mutate(diff = after-before)

m = lm(diff ~ 1, data=softball)
summary(m)

# 2. College Basketball Free Throw Practice (we're here)

routine_A <- c(79, 75, 72, 73, 74, 76, 71, 77)
routine_B <- c(78, 80, 79, 82, 81, 83, 79, 80)

t.test(routine_A, routine_B)
t.test(routine_A, routine_B, var.equal = TRUE)

free_throws = data.frame(routine=c(rep("A", 8), rep("B",8)),
                        results = c(routine_A, routine_B))

m = lm(results ~ routine, data=free_throws)
summary(m)


# lm can also build more complicated models

m = lm(PT_margin ~ OR_margin + DR_margin, data=games)

summary(m)

m = lm(PT_margin ~ OR_margin, data=games)
summary(m)

m = lm(PT_margin ~ DR_margin, data=games)
summary(m)

m = lm(PT_margin ~ OR_margin +FGA_margin + DR_margin, data=games)
summary(m)

games = 
games %>%
  mutate(missed_margin = FGA_margin - (team1_FGM - team2_FGM))

m = lm(PT_margin ~ OR_margin +missed_margin, data=games)
summary(m)

m = lm(PT_margin ~ OR_margin +missed_margin, data=games)
summary(m)

### what if we wanted to predict win/loss

games = 
games %>%
  mutate(W = ifelse(PT_margin>0, 1, 0))

games %>%
  ggplot(aes(OR_margin, W))+
  geom_point()+
  geom_smooth(method="lm")

m = lm(W ~ OR_margin, data=games)
summary(m)
predict(m)

games %>%
  ggplot(aes(DR_margin, W))+
  geom_point()+
  geom_smooth(method="lm")

m = lm(W ~ DR_margin, data=games)
summary(m)

predict(m)

summary(m)
hist(predict(m))

### logistic regression

# recall
games %>%
  ggplot(aes(DR_margin, W))+
  geom_point()+
  geom_smooth(method="lm")

m = lm(W ~ DR_margin, data=games)
summary(m)
hist(predict(m))

# odd and log odds

m_logistic = glm(W ~ DR_margin, data=games,
                 family = "binomial")


summary(m_logistic)
hist(predict(m_logistic))
hist(predict(m_logistic, type="response"))

games$pred_linear = predict(m)
games$pred_logistic = predict(m_logistic, type="response")

games %>%
  ggplot(aes(pred_linear, pred_logistic))+
  geom_point()

games %>%
  ggplot(aes(pred_linear, W))+
  geom_point()+
  geom_smooth()

games %>%
  ggplot(aes(pred_logistic, W))+
  geom_point()+
  geom_smooth()

# Analysis of Two Truths and a Lie

ttl = read.csv("ttl.csv")

ttl = ttl %>%
  mutate(success = ifelse(success.failure=="success", 1, 0))

ttl %>%
  ggplot(aes(certainty.rating, success))+
  geom_point()+
  geom_smooth(method="lm")

m_ttl = 
  lm(success ~ certainty.rating,
     data=ttl)
summary(m_ttl)

ttl %>%
  ggplot(aes(certainty.rating, success))+
  geom_jitter(width=0.2, height=0.2)+
  geom_smooth(method="lm")

m_ttl_log = 
  glm(success ~ certainty.rating,
     data=ttl,
     family="binomial")
summary(m_ttl_log)

ttl %>%
  ggplot(aes(certainty.rating, success))+
  geom_smooth(method="glm", 
              method.args = list(family = "binomial"),se=FALSE)+
  ylim(c(0,1))+xlim(c(1,10))

ttl %>%
  ggplot(aes(certainty.rating, success))+
  geom_smooth(method="lm", se=FALSE)+
  ylim(c(0,1))+xlim(c(1,10))
