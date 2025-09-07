# 1. Spring training

before <- c(0.240, 0.250, 0.230, 0.235, 0.225, 0.245, 0.238, 0.242, 0.236, 0.229)
after <- c(0.255, 0.265, 0.230, 0.250, 0.225, 0.260, 0.252, 0.257, 0.250, 0.215)

# H0 - no improvement, HA improvement

t.test(before, after, paired=TRUE, alternative = "less")

# data:  before and after
# t = -2.7823, df = 9, p-value = 0.01066

# 2. 
college_A <- c(8, 6, 4, 10, 7, 6, 5, 4)
college_B <- c(5, 9, 7, 3, 9, 8, 7, 10)

t.test(college_A, college_B)
# t = -0.91423, df = 13.803, p-value = 0.3763
# can't reje t null of equal study hours

# 3

rainy_waits <- c(5.2, 5.4, 5.1, 3.5, 5.3, 5.6, 5.8, 3.8, 5.7, 5.9, 5.5, 3.4)
#H0: 4 hours on average
t.test(rainy_waits, mu=4, alternative="greater")
# t = 3.8728, df = 11, p-value = 0.001298

# 4 Earth Day

mu_c = 16
sd_c = 5
n_c = 40

mu_t = 22
sd_t = 6
n_t = 40

diff = mu_t - mu_c
se_c = 5/sqrt(40)
se_t = 6/sqrt(40)
se_diff = sqrt(se_c^2 + se_t^2)
t_score = diff/se_diff
# 4.86
1-pt(4.86, df=68) # [1] 3.620416e-06
