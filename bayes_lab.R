# barrels of coins
# 50% fair coins
# 25% come up heads 40% of the time
# 25% come up heads 60% of the time

values = c(0.4, 0.5, 0.6)
rel_prior = c(1, 2, 1)

# flip 50 coins and 50 of them are heads

rel_lik = 
  dbinom(30, 50, prob = values)

rel_posterior = rel_prior * rel_lik

rel_posterior/sum(rel_posterior)

# next toss

sum(rel_posterior*values)/sum(rel_posterior)

# if you had started with 80% fair coins, 
# 10% coins that comes up heads 60% of the time
# and 10% coins that come up heads 40% of the time
# and then flipped 55 heads in 100 tosses, 
# what is the chance of heads on your next toss.


#######

values = seq(0, 1, 0.01)
rel_prior = dnorm(values, mean=0.7, sd=0.1)

sum(rel_prior*values)/sum(rel_prior)

plot(values, rel_prior, type="h")

# shooter makes 9 of 10 free throws

rel_lik = 
  dbinom(9, 10, prob = values)

rel_posterior = rel_prior * rel_lik

posterior = rel_posterior/sum(rel_posterior)

plot(values, posterior, type="h")

sum(rel_posterior*values)/sum(rel_posterior)

### better prior
# https://rdrr.io/cran/dampack/man/beta_params.html
rel_prior = dbeta(values, shape1=35, shape2=15)
plot(values, rel_prior, type="h")

# find the expected shooting percentage if a player makes
# 90 of 100 shots

rel_lik = 
  dbinom(90, 100, prob = values)

# plot the distribution, comments on it and
# write the expected shooting percentage


# Bem

values = seq(0, 1, 0.01)
rel_prior = ifelse(values==0.5, 1, 0.01)

rel_prior[values==0.5]/sum(rel_prior)


sum(rel_prior) # half chance of 0.5 exactly

rel_lik = 
  dbinom(850, 1600, prob = values)

rel_posterior = rel_prior * rel_lik

plot(values, rel_prior, type="h")
plot(values, rel_posterior, type="h")

rel_posterior[values==0.5]/sum(rel_posterior)

sum(values*rel_posterior)/sum(rel_posterior)

# devise your own ESP prior, 
# how do Bem's results alter your beliefs?