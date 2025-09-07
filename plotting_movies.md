Adv Stats: Wrangling and Plotting Movie Data
--------------------------------------------
  
Today we are going to practice wrangling and plotting data in R and, perhaps, learn something about movies.

Please open up posit.cloud and start a new project in the "Advanced Statistics 2024-2025" 
work space.  This will give you a work space in which the packages we need are already installed.  You'll still need to load them use the "library" function.  

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
```

The budget column in NA for most movies but we can make a histogram of the movies with budgets.

```r
movies %>% 
  ggplot(aes(budget)) + 
  geom_histogram()
```

In the budget histogram so many of the movies are small budget movies and squeezed near 0 by the big budget movies that the histogram is perhaps hard to interpret.  Let's try it again with a logarithmic x axis.

```r
movies %>% 
  ggplot(aes(budget)) + 
  scale_x_log10() +
  geom_histogram() 

```

1. Try making a histogram for the number of votes a movie received.  You may want to use a logarithmic axis.  From your graphs, try to estimate (just by eyeballing the graphs) the median number of votes a movie received.

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

# Indicator Variables 

The columns labeled "Action" through "Short" are *indicator variables* -- 1's and 0's indicating whether a movie fell into each category.  Indicator variables are great for quick math, you can sum them to find out how many movies fit into a category and average them to find out what proportion fit into a category.  

```r
movies %>%
  summarize(sum(Action),
            mean(Action))
```

We can also make bar charts of indicator variables (although they won't be incredibly exciting):
  
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

We can add a best fit curve to the graph as follows:

```r
movies %>%
  filter(votes >= 10000) %>%
  ggplot(aes(budget, rating)) +
  geom_point() +
  ggtitle("Movie Rating v. Budget, min 10,000 votes") +
  geom_smooth()
```

If we want to make that curve a best fit *line* we can do the following:

```r
movies %>%
    filter(votes >= 10000) %>%
    ggplot(aes(budget, rating, size=votes, wt=votes, col=Drama)) +
    geom_point() +
    ggtitle("Movie Rating v. Budget, min 10,000 votes") +
    geom_smooth(method="lm")
```

and between number of votes and rating:

```r
movies %>%
  ggplot(aes(votes, rating)) +
  geom_point() +
  ggtitle("Movie Average Rating v. Number of Ratings")
```

2. Try adding a best fit  to the rating v. votes graph above and try making the x axis logarithmic.  If you make a best-fit line with an without a logarithmic axis, are they the same line?

# A Fancier Plot!

We can use use some of the other aesthetics that we are learning about in our ggplot course.  

Let's try to make a scatter plot where we size the points based on the number votes a movie received and color the points based on whether the movie was a Drama.

```r
movies %>%
    filter(votes >= 10000) %>%
    ggplot(aes(budget, rating, size=votes, col=Drama)) +
    geom_point() +
    ggtitle("Movie Rating v. Budget, min 10,000 votes") +
    geom_smooth(method="lm")

```

This plot falls short in at least one way.  The color of the points is on a continuous scale (from light blue to dark blue) but the Drama variable only has (two) discrete values: 0 and 1. While treating Drama as a numeric variable was useful for getting counts and proportions, for the purposes of this plot we want to treat it as a *factor* (categorical) variable.  Take a look at the code below that should accomplish that:

```r
movies %>%
    filter(votes >= 10000) %>% 
    mutate(DramaFactor = as.factor(Drama)) %>%
    ggplot(aes(budget, rating, size=votes, col=DramaFactor)) +
    geom_point() +
    ggtitle("Movie Rating v. Budget, min 10,000 votes") +
    geom_smooth(method="lm")

```
Notice also that this creates two best fit lines.  How would you express what these best fit lines tell us?


If you think that the legends are distracting and taking up too much room we can remove them:

```r
movies %>%
    filter(votes >= 10000) %>% 
    mutate(DramaFactor = as.factor(Drama)) %>%
    ggplot(aes(budget, rating, size=votes, col=DramaFactor)) +
    geom_point() +
    ggtitle("Movie Rating v. Budget, 
    min 10,000 votes, sized by Votes,
    Dramas in Red") +
    geom_smooth(method="lm")+
    theme(legend.position="none")
```

3. Try making your own plot from this data.  Please fiddle until you find something you like!

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
  filter(votes >= 1000) %>%
  ggplot(aes(decade, rating)) +
  geom_boxplot()

```

## Summarizing

Let's put a few of the things we've learned together.  First, let's find the proportion of the 100 highest rated films each decade that are Dramas:

```
movies %>%
    filter(votes >= 100) %>%
    group_by(decade) %>%
    top_n(100, rating) %>%
    summarize(num_movies=n(), 
      prop_drama = mean(Drama))
  
```

Let's eliminate the first two decade where there aren't many movies:

```r
movies %>%
    filter(votes >= 100) %>%
    group_by(decade) %>%
    top_n(100, rating) %>%
    summarize(num_movies = n(), 
      prop_drama = mean(Drama)) %>%
    filter(num_movies >= 50)

```

Lastly, let's plot this summary:

```r
movies %>%
    filter(votes >= 100) %>%
    group_by(decade) %>%
    top_n(100, rating) %>%
    summarize(num_movies = n(), 
      prop_drama = mean(Drama)) %>%
    filter(num_movies >= 50) %>%
    ggplot(aes(decade, prop_drama))+
    geom_point()

```

Try creating a similar plot for comedies.


## Play around!

Try wrangling the data in your own ways and making new plots.  If you make a plot that you like, please show it to me (and your neighbors)!