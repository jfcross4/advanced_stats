# 1

before_regimen <- c(60, 65, 62, 58, 59, 63, 60, 61)
after_regimen <- c(62, 67, 66, 59, 59, 67, 63, 65)
t.test(after_regimen, 
       before_regimen, 
       paired=TRUE, 
       alternative = "g")

# 2

typing_speeds_A <- c(68, 75, 70, 73, 76, 65, 71, 69)
typing_speeds_B <- c(77, 72, 74, 67, 70, 78, 75, 79)

t.test(typing_speeds_A, 
       typing_speeds_B, alternative = "two")


# 3
lifespans <- c(7950, 8070, 7980, 8200, 8100, 7800, 7800, 7900, 8020, 8050, 7960, 8040, 7980, 7850, 8200)

t.test(lifespans, mu=8000)

# 4

se_a = 3/sqrt(80)
se_b = 4/sqrt(80)

se_diff = sqrt(se_a^2 + se_b^2)
se_diff # 0.559017
mean_a = 13
mean_b = 15
sd_a = 3
sd_b = 4
mean_diff = 15-13
tscore = mean_diff/se_diff
tscore #3.577709

2*(1 - pt(tscore, df=79))
2*(1 - pt(tscore, df=158))

