07 Learning about Comic Characters
----------------------------------

The dual goals of today's lab are to learn about DC and Marvel comic characters and to practice our tidyverse skills.  In particular, I'm hoping you'll use some of our favorite verbs while examining this data: filter, mutate, group_by, summarize and arrange.

# The Data

Our data was scraped from D.C. and Marvel wikipedia pages by 538.  We can read it into R as follows:

```r
marvel = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/marvel-wikia-data.csv")

dc = read.csv("https://raw.githubusercontent.com/jfcross4/advanced_stats/master/dc-wikia-data.csv")
```

You can start by using *View()* to take a look at the data.

# Our Favorite Verbs
Here's a quick review of how to use our favorite verbs/functions.  To use them you'll need to first load the tidyverse package (or the dplyr package):

```r
library(tidyverse)
```

## filter: To only select rows that meet some criteria.

For instance, if I wanted to find all the DC characters with Pink Eyes, I could do:

```r
dc %>% filter(EYE == "Pink Eyes")
```

## select: to select only certain columns.

If I want less information on these pink-eyed characters:

```r
dc %>% 
  filter(EYE == "Pink Eyes") %>%
  select(name, HAIR, SEX, ALIVE)
```
## top_n

If I want to find the 5 Marvel characters with the most appearances:

```r
marvel %>% 
  top_n(5, APPEARANCES) %>%
  select(name, APPEARANCES)
```

## arrange

And if I want the 10 Marvel characters with the most appearances in order of their first appearance:

```r
marvel %>% 
  top_n(10, APPEARANCES) %>%
  select(name, APPEARANCES, Year) %>%
  arrange(Year)
```


## mutate: add new columns based on existing columns.

Suppose that I might later want to group results by decade.  I would first need to create a decade column.  I'll do this by rounding the year column to the nearest 10.

```r
dc = dc %>% 
mutate(decade = round(as.numeric(as.character(YEAR))-5, -1))

marvel = marvel %>% mutate(decade = round(Year-5, -1))
```

## group_by 

If I want to figure out the Marvel character, from each decade, who appeared in the most comics, I could do the following:

```r
marvel %>% 
  group_by(decade) %>% 
  top_n(1, APPEARANCES) %>% 
  arrange(decade) %>% 
  select(decade, name, APPEARANCES)
```

## group_by and summarize

If I wanted to figure out the number of characters and number of appearances for Marvel characters of different sexes I could do the following*:

* note: within sum(), I've added "na.rm=TRUE" so that characters with "NA" for appearances are removed when calculating *total_appearances*.  If you don't do this, the sums with be NA.

```r
marvel %>% 
  group_by(SEX) %>% 
  summarize(num_characters=n(), 
            total_appearances = sum(APPEARANCES, na.rm=TRUE), 
            app_per_char = total_appearances/num_characters)

```

## Plots

I can use ggplot to make plots:

```r
marvel %>% 
  ggplot(aes(x=SEX)) + geom_bar()
```

or

```r
marvel %>% 
  ggplot(aes(x=SEX, fill=SEX)) + 
  geom_bar() + 
  facet_wrap(~decade)
```

and I can combine the verbs we used above with ggplot:

```r
marvel %>% 
  filter(!is.na(decade), 
          decade>=1940,
          ALIGN == "Good Characters",
          SEX !="") %>% 
          ggplot(aes(x=SEX, fill=SEX)) + 
          geom_bar() + 
          facet_wrap(~decade) + 
          ggtitle("Good Characters by Decade")+
          theme(axis.text.x=element_blank())
```

or

```r
marvel %>%
  group_by(decade) %>%
  summarize(female_percent =
        mean(SEX=="Female Characters")) %>%
        filter(!is.na(decade)) %>%
        ggplot(aes(decade, female_percent))+
        geom_point()
```

# Challenge:

Use our favorite verbs or some combination of plots and verbs to learn something new about comicbook characters or to make a comparison between marvel and dc comic characters.
