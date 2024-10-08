https://docs.google.com/document/d/1foRO7C7Be0S1wiBkTSv3Ru0RlsxrGUAQMlsekIn3sqs/edit?usp=sharing

http://www.stat.columbia.edu/~gelman/stuff_for_blog/sheena.pdf

dd <- read.csv('https://raw.githubusercontent.com/jfcross4/advanced_stats/master/Speed%20Dating%20Data.csv', header=TRUE)

library(dplyr); library(ggplot2)


# removing rows with missing information
dd <- dd %>% 
  filter(!is.na(pid), 
         !is.na(iid), 
         !is.na(attr),
         !is.na(intel),
         !is.na(fun),
         !is.na(sinc),
         !is.na(amb),
         !is.na(shar)
         )

dd <- dd %>% 
  mutate(pid = as.factor(pid), 
         iid=as.factor(iid))

# recap
m <- glm(dec ~ fun+attr+intel+sinc+amb+shar, 
         data=dd, family="binomial")

summary(m)

# age
m <- glm(dec ~ I(age_o-age) + abs(age-age_o), 
         data=dd, family="binomial")

## iid: subject who makes dec
## pid: subject who makes dec_o

m <- glm(dec ~ attr + attr_o, 
         data=dd, family="binomial")

# gender:	Female=0
# Male=1


m <- glm(dec ~ attr*gender, 
         data=dd, family="binomial")

m <- glm(dec ~ fun*gender, 
         data=dd, family="binomial")

m <- glm(dec ~ intel*gender, 
         data=dd, family="binomial")

m <- glm(dec ~ sinc*gender, 
         data=dd, family="binomial")

m <- glm(dec ~ amb*gender, 
         data=dd, family="binomial")


subset_of_columns = dd %>% dplyr:: select(fun, attr, intel, sinc, amb, shar, dec) 

round(cor(subset_of_columns),2)

library(corrplot)
corrplot(cor(subset_of_columns), method="circle")

dd %>% summarize_at(vars(attr:shar), mean) 
dd %>% summarize_at(vars(attr:shar), sd) 

# standard deviation of partner means
dd %>% group_by(pid) %>%
  summarize_at(vars(attr:shar), mean) %>%
  summarize_at(vars(attr:shar), sd)

# mean of partner standard deviations
dd %>% group_by(pid) %>%
  summarize_at(vars(attr:shar), sd) %>%
  summarize_at(vars(attr:shar), mean)

m <- glm(dec ~ fun+attr+intel+sinc+amb+shar +samerace, 
         data=dd, family="binomial")

m <- glm(dec ~ samerace, 
         data=dd, family="binomial")

m <- glm(dec ~ gender*samerace, 
         data=dd, family="binomial")


###
m <- lm(dec ~ amb + attr + intel + iid, data=dd %>%
          filter(gender==0))
summary(m)

m <- lm(dec ~ amb + attr + intel + iid, data=dd %>%
          filter(gender==1))

summary(m)


m <- lmer(dec ~ amb + attr + intel + (1|iid), data=dd %>%
            filter(gender==0))

summary(m)

m <- lmer(dec ~ amb + attr + intel + (1|iid), data=dd %>%
          filter(gender==1))

summary(m)

m <- lmer(dec ~ amb + 
            attr + 
            intel + 
            (1|iid), data=dd)

m <- lm(dec ~ amb + 
            attr + 
            intel, data=dd)

summary(m)

m <- lmer(dec ~ amb*gender + 
            attr*gender + 
            intel*gender + 
            (1|iid), data=dd)

summary(m)
