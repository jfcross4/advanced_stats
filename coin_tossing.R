coin <- c('h','t')
allTosses = c()
toss = sample(coin,1,T)
target_sequence = c("h", "t", "h")

for (i in 1:10) {
  allTosses = c(allTosses, sample(coin,1,T))
}


check_end_for_sequence = function(tosses, target){
  if(length(tosses) < length(target)){
    FALSE
  } else{
    identical(tosses[(length(tosses)-length(target)+1):
                       length(tosses)], target)  
  }
}

check_end_for_sequence(allTosses, target_sequence)
check_end_for_sequence(allTosses, c("t", "h", "t"))

num_flips = 0
MATCHED = FALSE
allTosses = c()

while(!MATCHED){
  allTosses = c(allTosses, sample(coin,1,T))
  MATCHED = check_end_for_sequence(allTosses, target_sequence)
  (num_flips = num_flips + 1)
  }


