test = read.csv("test_all_states_all_grades_all_years_sample500.csv")

test = test %>% mutate_at(vars(Sleep_Hours_Schoolnight), as.numeric)%>%
    mutate_at(vars(Sleep_Hours_Schoolnight), make_outliers_na)

test = test %>% filter(!is.na(Sleep_Hours_Schoolnight))
test$prediction_number = 1:nrow(test)
write.csv(test, file="test.csv")

test_no_sleep = test
test_no_sleep$Sleep_Hours_Schoolnight <- NA
write.csv(test_no_sleep, file="census_sleep_test_set.csv", row.names = FALSE)
library(tidyverse)

# read in the test set and clean it
test_no_sleep = 
read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/census_sleep_test_set.csv")

test_no_sleep = clean_census(test_no_sleep)

## make your predictions (but something better than this)
test_no_sleep$preds = 8

## write your predictions to a csv
write.csv(test_no_sleep %>% dplyr::select(preds, prediction_number),
          file="jareds_best_predictions.csv", row.names=FALSE)

## download your .csv file and send it to me



make_outliers_na <- function(x) 
{ifelse(x %in% boxplot.stats(x)$out, NA, x)}

clean_census = function(census){
  census %>%
    mutate(Height_cm = gsub("[^0-9.-]", "", Height_cm)) %>%
    mutate_at(vars(Ageyears, 
                   Height_cm,
                   Footlength_cm,
                   Armspan_cm,
                   Languages_spoken,
                   Travel_time_to_School,
                   Reaction_time,
                   Score_in_memory_game,
                   Importance_reducing_pollution:Left_Footlength_cm,
                   Index_Fingerlength_mm,
                   Ring_Fingerlength_mm,
                   Sleep_Hours_Schoolnight:Home_Occupants,
                   Text_Messages_Sent_Yesterday:Work_At_Home_Hours),
              as.numeric) %>%
    mutate_at(vars(Country,
                   Region,
                   Gender, 
                   Handed, 
                   Travel_to_School, 
                   Favourite_physical_activity,
                   Longer_foot,
                   Longer_Finger_Lefthand:Favorite_School_Subject,
                   Home_Internet_Access,
                   Communication_With_Friends,
                   Schoolwork_Pressure:Charity_Donation
    ), as.factor) %>%
    mutate_at(vars(Ageyears, 
                   Height_cm,
                   Footlength_cm,
                   Armspan_cm,
                   Languages_spoken,
                   Travel_time_to_School,
                   Reaction_time,
                   Score_in_memory_game,
                   Importance_reducing_pollution:Left_Footlength_cm,
                   Index_Fingerlength_mm,
                   Ring_Fingerlength_mm,
                   Sleep_Hours_Schoolnight:Home_Occupants,
                   Text_Messages_Sent_Yesterday:Work_At_Home_Hours),
              make_outliers_na)
  
}

test_no_sleep = clean_census(test_no_sleep)


summary(test_no_sleep$Sleep_Hours_Schoolnight)

