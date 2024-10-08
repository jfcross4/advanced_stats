file = "https://raw.githubusercontent.com/avehtari/ROS-Examples/master/ElectionsEconomy/data/hibbs.dat"
hibbs <- read.table(file, header=TRUE)
View(hibbs)

library(tidyverse)
hibbs %>% ggplot(aes(growth, vote))+
  geom_point()+geom_text(aes(label=year))


# predict 0 growth
# predict 2% growth
# what % growth gives a prediction of 50% for the incumbent

# infer package
library(infer)
observed_fit <- hibbs %>%
  specify(vote ~ growth) %>%
  fit()

null_fits <- hibbs %>%
  specify(vote ~ growth) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  fit()

get_p_value(null_fits, observed_fit, "two-sided")

visualize(null_fits) + 
  shade_p_value(observed_fit, direction = "both")


bootstraps <- hibbs %>%
  specify(vote ~ growth) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  fit()

get_confidence_interval(
  bootstraps, 
  point_estimate = observed_fit, 
  level = .95
)

visualize(bootstraps) + 
  shade_p_value(observed_fit, direction = "both")

###

lm(vote ~ growth, data=hibbs)
m = lm(vote ~ growth, data=hibbs)
summary(m)

hibbs %>% 
  summarize(m = cor(vote, growth)*sd(vote)/sd(growth),
            b = mean(vote) - m*mean(growth))

hibbs$predicted_vote = predict(m)

# residual = observed - expected

hibbs = hibbs %>%
  mutate(residual = vote - predicted_vote)

hibbs %>%
  summarize(var(vote),
            var(predicted_vote),
            var(residual),
            cor(vote, growth),
            cor(vote, predicted_vote),
            cor(vote, growth)^2,
            variance_unexplained = 
              var(residual)/var(vote),
            variance_explained =
                1-var(residual)/var(vote))

# (y - mean(y)) = m*(x-mean(x))
#y_int  = mean(y) - m*mean(x)
###





hibbs %>% ggplot(aes(growth, vote))+
  geom_point()+geom_text(aes(label=year))+
  geom_smooth(method="lm")

###

### Going further with Fair

fair = read.csv("/Volumes/GoogleDrive/My Drive/advanced_stats/fair.csv")

fair_hibbs = left_join(fair, hibbs, by="year")

fair_hibbs = fair_hibbs %>%
  mutate(incumbent_vote = 50 + I*(VP-50))
