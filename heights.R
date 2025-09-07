heights = 
  read.csv("fourth_heights.csv")


t.test(heights$Evening,
       heights$Morning,
       paired=FALSE)

t.test(heights$Evening,
       heights$Morning,
       paired=TRUE)

t.test(sample(heights$Evening),
       heights$Morning,
       paired=TRUE)
