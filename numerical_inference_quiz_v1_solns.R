# 1. High School Softball Bench

before <- c(185, 190, 135, 180, 170, 185, 178, 82, 179, 174)
after <- c(190, 200, 140, 195, 175, 192, 185, 95, 188, 182)

#H0: no improvement
# Ha: improvement, after > before
t.test(before, after, paired=TRUE, 
       alternative = "less")
# t = -7.7256, df = 9, p-value = 1.461e-05
# reject H0

# 2. College Basketball Free Throw Practice

routine_A <- c(79, 75, 72, 73, 74, 76, 71, 77)
routine_B <- c(78, 80, 79, 82, 81, 83, 79, 80)

# H0: routines are equally good
# Ha: one routine is better than the other
t.test(routine_A, routine_B)
# t = -5.0538, df = 11.748, p-value =0.0003019
# reject H0, routine B is better

# 3. Evaluating a Brooklyn Coffee Shop’s Wait Time

wait_times <- c(4.2, 3.8, 4.1, 4.5, 3.9, 4.3, 4.0, 4.6, 3.7, 4.4, 4.1, 3.9)

# H0: average wait time is 4 minutes
# Ha: average wait time is not 4 minutes
t.test(wait_times, mu=4)
# t = 1.5288, df = 11, p-value = 0.1546
# can't reject H0

# 4. Comparing Running Clubs in Prospect Park

mean_a = 45
sd_a = 10
n_a = 30

mean_b = 50
sd_b = 12
n_b = 30

diff = mean_b - mean_a

se_a = sd_a/sqrt(n_a)
se_b = sd_b/sqrt(n_b)

se_diff = sqrt(se_a^2 + se_b^2)
# [1] 2.8519

t_score = diff/se_diff
t_score
# [1] 1.753217

# H0: run clubs are equally good
# Ha: one run club is better than the other

# p-value:
2*(1-pt(t_score, df=58))
# [1] 0.08484843
# cannot reject H0 that run clubs are equally good