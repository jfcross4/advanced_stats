dbinom(692, 2768, prob=0.25)
dbinom(1024, 2768, prob=0.25)

dbinom(692, 2768, prob=0.25)/
  dbinom(1024, 2768, prob=0.25)

# likelihood ratio
dbinom(1024, 2768, prob=1/3)/
  dbinom(1024, 2768, prob=0.25)

# p-value
sum(dbinom(1024:2768, 2768, prob=0.25))


dbinom(850, 1600, .53)/dbinom(850, 1600, 0.5)

### Titanic

library(dplyr)

titanic %>% 
  filter(Age>=18) %>% 
  group_by(SibSp>=1) %>% 
  summarize(n=n(), 
            NumSurvived = sum(Survived), 
            SurvivalRate=mean(Survived))

titanic %>% 
  filter(Age>=18) %>% 
  summarize(n=n(), 
            NumSurvived = sum(Survived), 
            SurvivalRate=mean(Survived))

###########

loners_survived = rbinom(1000, 428, 0.381)
sibsp_survived = rbinom(1000, 173, 0.381)

loner_survival_rate = loners_survived/428
sibsp_survival_rate = sibsp_survived/173

difference_in_survival_rate = 
  sibsp_survival_rate - loner_survival_rate

hist(difference_in_survival_rate)

# one tailed p-value
mean(difference_in_survival_rate>0.131)

# two tailed p-value
mean(abs(difference_in_survival_rate)>0.131)

# Kobe

kobe = readRDS(url("https://github.com/jfcross4/advanced_stats/blob/master/kobe_basket.rds?raw=true"))
View(kobe)

shots = kobe$shot
table(shots)
mean(shots=="H")
which(shots=="H")

shots_after_hits = which(shots[-133]=="H")+1
shots_after_misses = which(shots[-133]=="M")+1

shots_after_hits; shots_after_misses
length(shots_after_hits); length(shots_after_misses)

sum(shots[shots_after_hits]=="H")
mean(shots[shots_after_hits]=="H")

sum(shots[shots_after_misses]=="H")
mean(shots[shots_after_misses]=="M")

# Apple

apple = readRDS(url("https://github.com/jfcross4/advanced_stats/blob/master/apple.rds?raw=true"))

mean(apple)

days_after_up = which(apple[-5730]==TRUE)+1
days_after_down = which(apple[-5730]==FALSE)+1


### stock price

library(tidyquant)

getSymbols("AAPL", from = '2000-01-01',
           to = "2022-10-12",warnings = FALSE,
           auto.assign = TRUE)
head(AAPL)
nrow(AAPL)

AAPL = data.frame(AAPL)
opens = AAPL$AAPL.Open
#saveRDS(AAPL, "apple.rds")



stock_increases = lead(opens, n=1) - opens >0



stock_increases = stock_increases[-length(stock_increases)]
mean(stock_increases)

APPL.stock_increases = stock_increases
saveRDS(APPL.stock_increases, "apple.rds")
# use Kobe analysis
