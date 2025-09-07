measurements2022 = read.csv("Measurements2022.csv")

measurements2023 = read.csv("measurements2023.csv")

library(tidyverse)

measurements2022 =
  measurements2022 %>%
  mutate(Measurement_cm = Measurement_in * 2.54)

measurements = 
rbind(
  measurements2022 %>%
    dplyr::select(-Measurement_in) %>%
    mutate(year = 2022),
  measurements2023 %>%
    mutate(year = 2023)
)

measurements %>% count(Measurer)
measurements %>% count(BodyPart)

View(measurements)

measurements = 
  measurements %>% 
  mutate(BodyPart = ifelse(grepl("Cubit", BodyPart), "Cubit", BodyPart)) %>%
  mutate_at(vars(Measurer, Measuree, BodyPart), tolower) %>%
  mutate_at(vars(Measurer, Measuree, BodyPart), trimws) %>%
  filter(Measurer != "")


measurements %>% count(Measurer)
measurements %>% count(Measuree)
measurements %>% count(BodyPart)


## cleaning

measurements = 
  measurements %>%
  mutate(BodyPart = case_when(
    BodyPart == "cubit" ~ "cubit",
    BodyPart %in% c("height", "hight") ~ "height",
    BodyPart %in% c("wing", "wingspan") ~ "wingspan"
  ))

measurements %>% count(BodyPart)


##

measurements %>% 
  filter(BodyPart=="cubit") %>% 
  group_by(Measuree) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(desc(mu))

measurements %>% 
  filter(BodyPart=="height") %>% 
  group_by(Measuree, year) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(desc(mu))


measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(BodyPart, desc(mu))


measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  pivot_wider(id_cols = c(Measuree, year),
              names_from = BodyPart,
              values_from = mu)

measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  pivot_wider(id_cols = c(Measuree, year),
              names_from = BodyPart,
              values_from = mu) %>%
  ggplot(aes(x=height, y=wingspan, label=Measuree)) +
  geom_label()

measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(desc(mu)) %>% 
  pivot_wider(id_cols = c(Measuree, year),
              names_from = BodyPart,
              values_from = mu) %>%
  ggplot(aes(x=height, y=wingspan)) +
  geom_point() +
  geom_smooth(method="lm")

measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(desc(mu)) %>% 
  pivot_wider(id_cols = c(Measuree, year),
              names_from = BodyPart,
              values_from = mu) %>%
  ggplot(aes(x=height, 
             y=wingspan, 
             col=as.factor(year))) +
  geom_point()

measurements_means_wide = 
measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = mean(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(desc(mu)) %>% 
  pivot_wider(id_cols = c(Measuree, year),
              names_from = BodyPart,
              values_from = mu)

measurements_medians_wide = 
  measurements %>% 
  group_by(Measuree, year, BodyPart) %>% 
  summarize(n=n(), 
            mu = median(Measurement_cm), 
            sigma = sd(Measurement_cm)) %>%
  arrange(desc(mu)) %>% 
  pivot_wider(id_cols = c(Measuree, year),
              names_from = BodyPart,
              values_from = mu)

measurements_wide %>%
  ungroup() %>%
  summarize(mean(height, na.rm = TRUE),
            mean(wingspan, na.rm=TRUE))

lm(wingspan ~ height, data=measurements_wide)

m = lm(wingspan ~ height, data=measurements_wide)

summary(m)

measurements_means_wide %>%
  ungroup() %>%
  select(wingspan, height) %>%
  as.matrix() %>%
  cor()

measurements_means_wide %>%
ggplot(aes(x=height, 
           y=wingspan, 
           col=as.factor(year))) +
  geom_point()

measurements_medians_wide %>%
  ggplot(aes(x=height, 
             y=wingspan, 
             col=as.factor(year))) +
  geom_point()

measurements_medians_wide %>%
  ungroup() %>%
  select(wingspan, height) %>%
  as.matrix() %>%
  cor()

measurements_wide %>%
  ungroup() %>%
  select(wingspan, height) %>%
  as.matrix() %>%
  cor(use="pairwise.complete.obs")
