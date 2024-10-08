library(discreteRV)

X = RV(outcomes=1:6, probs=rep(1/6, 6))

num = 2
num_rolls = SofIID(X, n=num)
plot(num_rolls)


stanns = 
  RV(outcomes=0:3, 
     probs=c(0.55, 0.05, 0.3, 0.1))

packer = 
  RV(outcomes=0:3, 
     probs=c(0.6, 0.05, 0.2, 0.15))

stanns_game = SofIID(stanns, n=70)

packer_game = SofIID(packer, n=70)

total = 
  SofI(stanns_game, packer_game)

margin = 
  SofI(stanns_game, -1*packer_game)

