pop = 1:5
var(pop)
sqrt(var(pop))

sample.int(5, 10, replace=TRUE)

sums_of_samples = 
  replicate(1e5, {x = sample.int(5, 10, replace=TRUE); sum(x)})

means_of_samples = sums_of_samples/10

##a
var(sums_of_samples); sqrt(var(sums_of_samples))

## b
var(means_of_samples); sqrt(var(means_of_samples))

###########
##########

stanni = c(63.6, 80.8, 56.5, 64.0, 89.0, 43.7)
mean(stanni)
sd(stanni)
sd(stanni)/sqrt(6)


mean(stanni) + qnorm(c(0.05, 0.95))*sd(stanni)/sqrt(6)

mean(stanni) + qt(c(0.05, 0.95), df=5)*sd(stanni)/sqrt(6)

########
#######

heights = read.csv("fourth_heights.csv")
t.test(heights$Morning, heights$Evening)
