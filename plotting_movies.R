Adv Stats: Wrangling and Plotting Movie Data
--------------------------------------------
  
  Today we're going to practice wrangling and plotting data in R and, perhaps, learn something about movies.

Please open up RStudio Cloud and open the "Wrangling and Plotting Movie Data" project in the "Statistics 2023-2024" work space.  This will give you a work space in which the packages we need are already installed.  You'll still nead to load them use the "library" function.  (The first pieces of code you need are already written in an R script that should be open in this workspace.  The rest of the code you'll need to write yourself.)

First, run the code to load the packages we need:

```r
library(tidyverse)
library(ggplot2movies)
```

Now, let's take a peak at the first few movies:
                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                      ```r
                                                                                                                                                                                                                                                                                    glimpse(movies)
                                                                                                                                                                                                                                                                                    ```
                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                    # Plotting the Data
                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                    ## Histograms
                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                    Histograms are a way of showing the distribution of a continuous variable.  Let's make some histograms.

```r
movies %>% 
  ggplot(aes(rating)) + 
  geom_histogram()

movies %>% 
  ggplot(aes(year)) +
  geom_histogram()

# the budget column in NA for most movies
# but we can make a histogram of the movies
# with budgets

movies %>% 
  ggplot(aes(budget)) + 
  geom_histogram()


# this is a histogram of the % of people who gave 
# the movies a rating of 10 on a 1-10 scale
# it's rounded in an unusual way as you'll
# see in the histogram

movies %>% 
  ggplot(aes(r10)) + 
  geom_histogram()
  
# and finally a histogram of the number of people who rated a movie.  Most movies have very few ratings but a small number of movies have many ratings!

movies %>% 
  ggplot(aes(votes)) + 
  geom_histogram() 
  
```



## Bar Charts

Histograms won't work for categorical data but we can plot these distributions with bar charts.
                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                    Notice that most movies don't have an mpaa rating:

```r
movies %>% 
  ggplot(aes(mpaa)) + 
  geom_bar()
```

To make a better plot, we can use filter to remove movies where the mpaa column is blank and make a bar chart of the rest:

```r
movies %>% 
  filter(mpaa != "") %>% 
  ggplot(aes(mpaa)) + 
  geom_bar()
```

The columns labeled "Action" through "Short" are *indicator variables* -- 1's and 0's indicating whether a movie fell into each category.  Indicator variables are great for quick math, you can sum them to find out how many movies fit into a category and average them to find out what proportion fit into a category.  We can also make bar charts of indicator variables (although they won't be incredibly exciting):
  
  ```r
movies %>% 
  ggplot(aes(Drama)) + 
  geom_bar()
```

# Boxplots 

We can plot a few distributions side by side with a box plot.

Here are distribution of movie ratings for movies with different mpaa ratings.  Remember that the box extends from the 25th percentile rating up to the 75th percentile rating and the the central line is the median (or 50th percentile) movie rating.

```r
movies %>% 
  filter(mpaa != "") %>%
  ggplot(aes(mpaa, rating)) + 
  geom_boxplot()
```

## Scatterplots

Scatterplots allow us to look at the relationship between two continuous variables.

This plot of the relationship between movie length and movie rating is unfortunately ruined by a few ridiculously long movies.

```r
movies %>%
  ggplot(aes(length, rating)) +
  geom_point()
```

Let's make the same plot but limit it to movies with at least 10,000 votes.  We should add a title to clarify what we're plotting.

```r
movies %>%
  filter(votes >= 10000) %>%
  ggplot(aes(length, rating)) +
  geom_point() +
  ggtitle("Movie Rating v. Length, min 10,000 votes")
```

Let's look at the relationship between budget and rating.

```r
movies %>%
  filter(votes >= 10000) %>%
  ggplot(aes(budget, rating)) +
  geom_point() +
  ggtitle("Movie Rating v. Budget, min 10,000 votes")
```

and between number of votes and rating:

```r
movies %>%
  ggplot(aes(votes, rating)) +
  geom_point() +
  ggtitle("Movie Average Rating v. Number of Ratings")
```

# Try making your own plot.  

Please fiddle until you find something you like!

# Data Wrangling

Now, let's practice with some of the data wrangling "verbs" we learned about on DataCamp.  We've already used *filter()*.

## top_n and select

We can find the 5 movies with the largest budgets and show the movie name, the budget and the year:

```r
movies %>%
  top_n(5, budget) %>%
  select(title, budget, year)
```

We can find the 10 highest rated movies and show the average rating in addition to the budget (note that this list runs past 10 due to ties):

```r
movies %>%
  top_n(10, rating) %>%
  select(title, budget, rating)
```

That list includes some obscure movies, let's use filter to limit our list to movies with at least 100 votes.  

```r
movies %>%
  filter(votes >= 100) %>%
  top_n(10, rating) %>%
  select(title, votes, rating)
```

Notice that to do this we filtered by votes before finding the top 10 in ratings.  How is our result different if we swap the order of those steps (with the code below)?
  
  ```r
movies %>%
  top_n(10, rating) %>%
  filter(votes >= 100) %>%
  select(title, votes, rating)
```

How do you explain this difference?
  
  ## Arranging
  
  You might also have been frustrated that when we looked at the top 10 movies by rating that they weren't ordered by rating (what kind of a top 10 list is that!).  We can fix this using arrange:

```r
movies %>%
  filter(votes >= 100) %>%
  top_n(10, rating) %>%
  arrange(desc(rating)) %>%
  select(title, votes, rating)
```

**To Do** 

Find the top 20 highest rated movies with at least 1000 votes.

## Mutating

With *mutate* we can add new columns based on existing columns.  Suppose we're interest in how movies have changed over time and might be interested in looking at movies grouped by decade.  We can add a decade column.  To do this, I'll subtract 5 from the year and then round years to the 10's place.  I'll also use *factor* to tell R that the number that results from this calculation is a group or category.

Notice also that I'm starting this line of code with "movies = ...".  This is the way to overwrite the movies data with this new column added.

```r
movies = movies %>% 
  mutate(decade = factor(round(year-5, -1)))
```

Now, let's go back to our box plots and look at movie ratings by decade.  I'll limit this to movies with at least 10,000 ratings:
  
  ```r
movies %>%
  filter(votes >= 10000) %>%
  ggplot(aes(decade, rating)) +
  geom_boxplot()

```

## Play around!

Try wrangling the data in your own ways and making new plots.  If you make a plot that you like, please show it to me (and your neighbors)!