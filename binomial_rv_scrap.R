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
