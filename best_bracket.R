library(devtools)
devtools::install_github("elishayer/mRchmadness", build_vignettes = TRUE)
library(mRchmadness)
vignette("mRchmadness")

pred.pop.2023 = scrape.population.distribution(2023, league = "mens")
head(pred.538.men.2023)

simple.bracket = find.bracket(
  bracket.empty = bracket.men.2023,
              prob.source="538",
             pool.source = "pop",
             league="men",
             year = 2023,
             num.candidates = 100,
             num.sims = 1000,
             criterion = "win",
             pool.size = 50,
            bonus.round=c(1,2,4,8,16,32))

draw.bracket(bracket.empty = bracket.men.2023, 
             bracket.filled = simple.bracket)

test = test.bracket(
  bracket.empty = bracket.men.2023,
  bracket.picks = simple.bracket,
  prob.source="538",
  league = "men",
  pool.size = 50,
  num.sims = 5000,
  bonus.round = c(1, 2, 4, 8, 16, 32),
  bonus.seed = rep(0, 16)
)

mean(test$win)
hist(test$percentile, breaks = 20)


stanns.bracket = find.bracket(
  bracket.empty = bracket.men.2023,
  prob.source="538",
  pool.source = "pop",
  league="men",
  year = 2023,
  num.candidates = 500,
  num.sims = 5000,
  criterion = "win",
  pool.size = 38,
  bonus.round=c(2,3,5,7,10,16))

draw.bracket(bracket.empty = bracket.men.2023, 
             bracket.filled = stanns.bracket)


s.work.bracket = find.bracket(
  bracket.empty = bracket.men.2023,
  prob.source="538",
  pool.source = "pop",
  league="men",
  year = 2023,
  num.candidates = 1000,
  num.sims = 10000,
  criterion = "win",
  pool.size = 350,
  bonus.round=c(1,2,4,8,16,32))

draw.bracket(bracket.empty = bracket.men.2023, 
             bracket.filled = s.work.bracket)

test = test.bracket(
  bracket.empty = bracket.men.2023,
  bracket.picks = s.work.bracket,
  prob.source="538",
  league = "men",
  pool.size = 350,
  num.sims = 5000,
  bonus.round = c(1, 2, 4, 8, 16, 32),
  bonus.seed = rep(0, 16)
)

1/mean(test$win)


jonah.school.bracket = find.bracket(
  bracket.empty = bracket.men.2023,
  prob.source="538",
  pool.source = "pop",
  league="men",
  year = 2023,
  num.candidates = 1000,
  num.sims = 5000,
  criterion = "win",
  pool.size = 15,
  bonus.round=c(1,2,4,8,16,32))

draw.bracket(bracket.empty = bracket.men.2023, 
             bracket.filled = jonah.school.bracket)

test = test.bracket(
  bracket.empty = bracket.men.2023,
  bracket.picks = jonah.school.bracket,
  prob.source="538",
  league = "men",
  pool.size = 15,
  num.sims = 10000,
  bonus.round = c(1, 2, 4, 8, 16, 32),
  bonus.seed = rep(0, 16)
)
1/mean(test$win)

jonah.school.bracket.3 = find.bracket(
  bracket.empty = bracket.men.2023,
  prob.source="538",
  pool.source = "pop",
  league="men",
  year = 2023,
  num.candidates = 1000,
  num.sims = 5000,
  criterion = "score",
  pool.size = 15,
  bonus.round=c(2,3,5,7,10,16))

draw.bracket(bracket.empty = bracket.men.2023, 
             bracket.filled = 
               jonah.school.bracket.3)

test = test.bracket(
  bracket.empty = bracket.men.2023,
  bracket.picks = jonah.school.bracket.3,
  prob.source="538",
  league = "men",
  pool.size = 15,
  num.sims = 10000,
  bonus.round = c(1, 2, 4, 8, 16, 32),
  bonus.seed = rep(0, 16)
)

mean(test$win)

G.school.bracket.3 = find.bracket(
  bracket.empty = bracket.men.2023,
  prob.source="538",
  pool.source = "pop",
  league="men",
  year = 2023,
  num.candidates = 3000,
  num.sims = 5000,
  criterion = "score",
  pool.size = 50,
  bonus.round=c(1,2,4,6,8,12))

draw.bracket(bracket.empty = bracket.men.2023, 
             bracket.filled = 
               G.school.bracket.3)

test = test.bracket(
  bracket.empty = bracket.men.2023,
  bracket.picks = G.school.bracket.3,
  prob.source="538",
  league = "men",
  pool.size = 50,
  num.sims = 10000,
  bonus.round = c(1,2,4,6,8,12),
  bonus.seed = rep(0, 16)
)

mean(test$win)*100
