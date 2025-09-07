?chisq.test

expected = c(0.5, 0.5)*94
observed = c(55, 39)

sum(((observed-expected)^2)/expected)

1-pchisq(2.72, df=1)

sim100000 = replicate(100000, {
results = sample(x=c("correct", "incorrect"), size=94, replace=TRUE)
observed = table(results)
observed_chi = sum(((observed-expected)^2)/expected)
observed_chi
})

mean(sim100000 >= 2.723404)
