
k_weights <- c(93, 77, 62, 78, 75, 85, 66, 83, 91, 72)
mean(k_weights)

sample_means <- 
  colMeans(replicate(50000, sample(k_weights, 
                                 size=10, replace=TRUE)))

var(sample_means)


## another way
varpopB = function(x){
  sum((x - mean(x))^2)/(length(x)-1)}
varpopB(k_weights)
var(k_weights)

var_mean_10_roos = varpopB(k_weights)/10
sd_mean_10_roos = sqrt(var_mean_10_roos)
sd_mean_10_roos
# bootstrapped variance isn't Bessel corrected

# p-value
mean(sample_means >= 91)


