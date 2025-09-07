polls = read.csv("senate_polls.csv")
#https://projects.fivethirtyeight.com/2022-election-forecast/

map <- c("F"=0, "D-"=1, "D"=2, "D+"=3, "C-"=4 , "CC-"=4.5, "C"=5, "C+"=6, 
         "B-"=7, "B"=8, "B+"=9, "A-"=10, "A"=11, "A+"=12)
pollster_ratings$num.538.Grade <- unname(map[as.character(pollster_ratings$X538.Grade)])


poll.weight <- function(num.538.Grade, days_old, type_simple, samplesize){
  1/(((12-num.538.Grade)/2)^d + a*days_old^b + (if(type_simple=="Pres-P"){3}else{0})^2 + 50^2/samplesize)^(1/c)
}

###

dem_primary_polls <- dem_primary_polls %>% 
  mutate(start_date=as.Date(start_date, "%m/%d/%y"),
         end_date=as.Date(start_date, "%m/%d/%y"),
         create_date=as.Date(created_at, "%m/%d/%y")
  ) 


###