stories = read.csv("stories.csv")

library(tidyverse)

stories = 
stories %>%
  mutate(
    success.failure = 
      trimws(success.failure)
  )

stories = 
stories %>%
  mutate(
    success = ifelse(
      success.failure == "success",
                     1,0))

summary(stories) #7 of 15

sum(dbinom(7:15, 15, 1/3))


stories %>%
  ggplot(aes(certainty_rating, success)) +
  geom_point()

stories %>%
  group_by(success.failure) %>%
  summarize(mu = mean(certainty_rating),
            sigma = sd(certainty_rating))

m = lm(success ~ certainty_rating,
   data=stories)

summary(m)

m2 = glm(success ~ certainty_rating,
       data=stories, family="binomial")
summary(m2)
