m2022 = read.csv("Measurements2022.csv")
m2022$year = 2022
m2022$Measurement_cm = 2.54*m2022$Measurement_in

m2023 = read.csv("Measurements2023.csv")
m2023$year = 2023

m2024 = read.csv("Measurements2024.csv")
m2024$year = 2024

library(tidyverse)

Measurements = 
rbind(m2024 %>% select(year, Measurer, Measuree,
                       BodyPart,
                       Measurement_cm),
      m2023 %>% select(year, Measurer, Measuree,
                       BodyPart,
                       Measurement_cm),
      m2022 %>% select(year, Measurer, Measuree,
                       BodyPart,
                       Measurement_cm))

#write.csv(Measurements, "measurements.csv")
measurements = read.csv("Measurements.csv")
measurements %>% count(year, Measurer)
measurements %>% count(year, Measuree)
measurements %>% count(BodyPart)

measurements = 
  measurements %>% 
  mutate_at(vars(Measurer, Measuree, BodyPart), tolower) %>%
  mutate_at(vars(Measurer, Measuree, BodyPart), trimws) 

measurements %>% count(BodyPart)

measurements = 
  measurements %>%
  mutate(BodyPart = case_when(
    BodyPart %in% c("cubit", "left cubit", "right cubit") ~ "cubit",
    BodyPart %in% c("height", "hight") ~ "height",
    BodyPart %in% c("wing", "wingspan", "wing span") ~ "wingspan",
    TRUE ~ BodyPart
  ))

measurements = 
  measurements %>% 
  filter(BodyPart %in% c("cubit", "wingspan", "height"))

head(measurements)

measurements = 
measurements %>%
  mutate(
    Measurer = paste(Measurer, year),
    Measuree = paste(Measuree, year))

body_part_means = 
  measurements %>%
  group_by(Measuree, BodyPart) %>%
  summarize(num_times_measured = n(),
            mean_length = mean(Measurement_cm),
            sd_length = sd(Measurement_cm))

body_part_means_wide = 
body_part_means %>%
  pivot_wider(id_cols = Measuree,
              names_from = BodyPart,
              values_from = mean_length)

body_part_means_wide %>%
  ggplot(aes(height, wingspan)) +
  geom_point()

body_part_means_wide %>%
  ggplot(aes(height, cubit)) +
  geom_point()

body_part_means_wide %>%
  ggplot(aes(wingspan, cubit)) +
  geom_point()

body_part_means_wide %>%
  ungroup() %>%
  summarize(
    cor_ht_wing = cor(height, wingspan),
    cor_ht_cub = cor(height, cubit),
    cor_wing_cub = cor(wingspan, cubit))

body_part_means_wide = 
  body_part_means_wide %>%
  mutate(wing_ratio = wingspan/height) 

measurement_pairs = 
inner_join(measurements %>% select(-year),
           measurements %>% select(-year),
           by=c("Measuree", "BodyPart"),
           relationship = "many-to-many") %>%
  filter(Measurer.x != Measurer.y)

AAE = function(x,y){mean(abs(x-y))}
RMSE = function(x,y){sqrt(mean((x-y)^2))}

measurement_pairs %>%
  group_by(BodyPart) %>%
  summarize(
    correlation = cor(Measurement_cm.x, Measurement_cm.y),
    AAE = AAE(Measurement_cm.x, Measurement_cm.y),
    RMSE = RMSE(Measurement_cm.x, Measurement_cm.y)
  )

average_errors_by_part = 
measurement_pairs %>%
  group_by(BodyPart) %>%
  summarize(
    typical_abs_error = AAE(Measurement_cm.x, Measurement_cm.y)
  )

errors_over_average = 
left_join(measurement_pairs,
          average_errors_by_part,
          by="BodyPart") %>%
  group_by(Measurer.x) %>%
  summarize(n = n(),
            AAE = round(AAE(Measurement_cm.x, Measurement_cm.y),3),
            mean_typical_error = round(mean(typical_abs_error),3)) %>%
  mutate(mean_error_over_average = AAE - mean_typical_error,
         total_error_over_average = n*(AAE - mean_typical_error))
