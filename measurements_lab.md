Measurements Lab
---------------------------

One of the things that separates statisticians from ordinary humans is that we no longer think of measurements as unadulterated facts about the world.  All measurements (really, all observations) are subject to error and as we think about measurements we should keep this error in mind.  Ultimately, this should change how we see many things.  For instance, my score on a stoichiometry quiz is an imperfect measurement of my stoichiometry abilities (it might be accurate and it might not be) and not the “ground truth.”  The outcome of a game is an imperfect measure of the quality of the teams and players and, if they faced off again, something quite different might occur.  Measurements of lengths (like heights, wingspans, and cubits) are generally quite accurate. Our measurements would be much “noisier” if we were taking temperatures, personality quizzes or free throws.  Nonetheless, even these measurements will have errors.  

# Cleaning the Data

First go to posit.cloud, sign in, open up our class workspace and the *Measurements* project within that workspace.

Next, load the libraries we need and read in the data:

```r
library(tidyverse)

measurements = read.csv("measurements.csv")

View(measurements)
```

You'll see that we have measurements from the last three years.

Let's look at how many measurements we have by Measurer, Measuree and by body part.  Please run each of the following individually and look at the results:

```r
measurements %>% 
  count(year, Measuree)

measurements %>% 
  count(year, Measurer)
  
measurements %>% 
  count(year, Measurer)

measurements %>% 
  count(BodyPart)
```

I included year with student names since, for example, there were different Ian's in different school years and we shouldn't expect them to have the same measurements.

Also, note that sometimes the same student's name is written differently.  In 2022, the same Ben shows up as "Ben" and "ben".  We'll need to fix that.  The body parts also have a variety of spellings and captilizations and we'll want to fix that as well.

First, we'll remove all capitalizations and trim away excess spaces:

```r
measurements = 
  measurements %>% 
  mutate_at(vars(Measurer, Measuree, BodyPart), tolower) %>%
  mutate_at(vars(Measurer, Measuree, BodyPart), trimws) 
```

Then we can take another look:

```r
measurements %>% 
  count(BodyPart)
```

This is better, but still needs some work.  Let's combine different spellings, and take another look:


```r
measurements = 
  measurements %>%
  mutate(BodyPart = case_when(
    BodyPart %in% c("cubit", "left cubit", "right cubit") ~ "cubit",
    BodyPart %in% c("height", "hight") ~ "height",
    BodyPart %in% c("wing", "wingspan", "wing span") ~ "wingspan",
    TRUE ~ BodyPart
  ))
  
measurements %>% 
  count(BodyPart)

```

That's better!  For now, I'm going to eliminate the measurements of a digit, hand, inch, span and yard:

```r
measurements = 
measurements %>% 
  filter(BodyPart %in% c("cubit", "wingspan", "height"))
```

Next, I'm going to combine the student names and years into columns that are distinct identifiers:

```r
measurements = 
measurements %>%
  mutate(
    Measurer = paste(Measurer, year),
    Measuree = paste(Measuree, year))
```

Now, we're ready to do some analysis!

# Body Part Averages

Let's get the mean and standard deviation for every person-body part:

```r
body_part_means = 
  measurements %>%
  group_by(Measuree, BodyPart) %>%
  summarize(num_times_measured = n(),
            mean_length = mean(Measurement_cm),
            sd_length = sd(Measurement_cm))
            
View(body_part_means)

```

You can see that the standard deviations are NA for body parts that were measured only once.

# Wide Data

Next, I'm going to transform this data set from a *long* format (with one row for every person-body part) to a *wide* format with one row for every person but columns for each body part.  It's often useful in data analysis to move make and forth between long and wide formats:

```r
body_part_means_wide = 
body_part_means %>%
  pivot_wider(id_cols = Measuree,
              names_from = BodyPart,
              values_from = mean_length)
              
View(body_part_means_wide)
```

# Scatter Plots and Correlations

Let's make scatter plots for each pair of measurements.  Take a look at each one individually and try to estimate the correlation between each pair of measurements before moving on.

```r
body_part_means_wide %>%
  ggplot(aes(height, wingspan)) +
  geom_point()

body_part_means_wide %>%
  ggplot(aes(height, cubit)) +
  geom_point()

body_part_means_wide %>%
  ggplot(aes(wingspan, cubit)) +
  geom_point()

```

Now, let's find the correlations:

```r
body_part_means_wide %>%
  ungroup() %>%
  summarize(
  cor_ht_wing = cor(height, wingspan),
  cor_ht_cub = cor(height, cubit),
  cor_wing_cub = cor(wingspan, cubit))
```

# Wing Span

Let's take a look the ratios between wingspan and height:

```r
body_part_means_wide = 
body_part_means_wide %>%
  mutate(wing_ratio = wingspan/height) 

View(body_part_means_wide)
```

# Easiest Parts to Measure

Which body parts were we able to measure most accurately?  We can attempt to determine this by looking at repeat measurements of the same body part and seeing how closely they match.  Let's go back to the original *long* data format and match up every pair of measurements of the same part.

```r
measurement_pairs = 
inner_join(measurements %>% select(-year),
           measurements %>% select(-year),
           by=c("Measuree", "BodyPart"),
           relationship = "many-to-many") %>%
  filter(Measurer.x != Measurer.y)

View(measurement_pairs)
  
```

To find out what parts are easiest/hardest to measure, let's get the correlation, average absolute error and root mean square error between pairs of measurements:

```r
AAE = function(x,y){mean(abs(x-y))}
RMSE = function(x,y){sqrt(mean((x-y)^2))}

measurement_pairs %>%
  group_by(BodyPart) %>%
  summarize(
    correlation = cor(Measurement_cm.x, Measurement_cm.y),
    AAE = AAE(Measurement_cm.x, Measurement_cm.y),
    RMSE = RMSE(Measurement_cm.x, Measurement_cm.y)
  )
```

# Best Measurer

Lastly, let's try to find out who the best measurer was.  We'll evaluate this based on how similar that person's measurements were to other measurements made of the same body part.  Since some body parts were easier to measure than others, we can try to control for the body part by comparing each measurer's average absolute error to typical errors for the same body parts.

In the following we'll calculate, for each measurer:

  * AAE - average absolute error
  * mean_typical_error - the expected AAE for someone measuring all the same body parts.
  * mean_error_over_average - this will be negative for people who have measurements that most closely resemble other.
  * total_error_over_average - the total accuracy off all measurement compared to others (here again, negative is good).
  

```r
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
         
View(errors_over_average)
```

You might well bicker with our measurer ratings?  What are possible issues with this ratings?  How could be design our experiment to get more accurate ratings of measurers?