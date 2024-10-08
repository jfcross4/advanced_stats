measurements = read.csv("Measurements.csv")

library(tidyverse)

measurements = 
  measurements %>% 
  mutate_at(vars(Measurer, Measuree, BodyPart), tolower) %>%
  mutate_at(vars(Measurer, Measuree, BodyPart), trimws)

## cleaning

measurements = 
  measurements %>%
  mutate(BodyPart = case_when(
    BodyPart == "cubit" ~ "cubit",
    BodyPart %in% c("height", "hight") ~ "height",
    BodyPart %in% c("wing", "wingspan") ~ "wingspan"
  ))

##



measurements %>% 
  filter(BodyPart=="cubit") %>% 
  group_by(Measuree) %>% 
  summarize(n=n(), mu = mean(Measurement), 
            sigma = sd(Measurement))


measurements %>% 
  filter(BodyPart=="cubit") %>% 
  group_by(Measuree) %>% 
  summarize(mu = mean(Measurement), 
            sigma = sd(Measurement)) %>% 
  summarize(mean_cubit = mean(mu),
            sd_cubit = sd(mu))


## 

m = lm(Measurement ~ Measuree, 
       data=measurements %>% 
         filter(BodyPart == "cubit"))

summary(m)

m = lm(Measurement ~ Measuree + 0, 
       data=measurements %>% 
         filter(BodyPart == "cubit"))

summary(m)
sqrt(0.2901^2 + 0.3350^2)


## Does this make any sense?
m = lm(Measurement ~ Measuree + BodyPart + 0, 
       data=measurements)



## What about this?

m = lm(Measurement ~ Measuree*BodyPart + 0, 
       data=measurements)
summary(m)


### Mixed Effects Models


# First Just For Cubits
m = lm(Measurement ~ Measuree + 0, 
       data=measurements %>% 
         filter(BodyPart == "cubit"))

summary(m)
library(lme4)
m_random = lmer(Measurement ~ (1|Measuree), 
                   data=measurements %>% 
                     filter(BodyPart == "cubit"))
coef(m)

summary(m_random)
ranef(m_random)
coef(m_random)

# Now with all body parts?
m_random = lmer(Measurement ~ (1|Measuree) + BodyPart,
                data=measurements)

summary(m_random)
ranef(m_random)

### or is this better?

m_random = lmer(Measurement ~ (1|Measuree) + (1|BodyPart),
                data=measurements)

summary(m_random)
ranef(m_random)

## or this:

m_random = lmer(Measurement ~ (BodyPart|Measuree),
                data=measurements)

summary(m_random)
ranef(m_random)

## or this:

m_random = lmer(Measurement ~ (Measuree|BodyPart),
                data=measurements)

summary(m_random)
ranef(m_random)
coef(m_random)


## or even this:

m_random = lmer(Measurement ~ (Measuree|BodyPart) + 
                  (1|Measurer),
                data=measurements)

summary(m_random)
ranef(m_random)
coef(m_random)


##### Speed Dating Data

dd <- read.csv('https://raw.githubusercontent.com/jfcross4/advanced_stats/master/Speed%20Dating%20Data.csv', header=TRUE)

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
  mutate(pid = as.factor(pid), #potential partners
         iid=as.factor(iid)). # individuals making the decisions

m = lm(dec ~ pid, data=dd)
summary(m)
coef(m)

m = lmer(dec ~ (1|pid), data=dd)
summary(m)

m = glm(dec ~ pid, data=dd, family="binomial")
summary(m)
coef(m)
exp(coef(m))


m = glmer(dec ~ (1|pid), data=dd, family="binomial")
summary(m)
exp(-0.32562)

exp(-0.32562)/(1 + exp(-0.32562))

ranef(m)
exp(ranef(m)$pid)


m = glmer(dec ~ (1|pid) + (1|iid), data=dd, family="binomial")
summary(m)
# who has more influence on the decision the partner or the decision maker?


m = glmer(dec ~ (1|pid) + (1|iid) + fun, data=dd, family="binomial")
summary(m)
