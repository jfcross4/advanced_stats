# Probability of Selecting Four Cards of the Same Suit

To find the probability that all four cards selected from a standard deck of 52 cards are of the same suit, we can follow these steps:

## Step 1: Count the Total Ways to Select 4 Cards

The total number of ways to choose any 4 cards from a standard deck of 52 cards is given by the combination formula:

\[
\binom{n}{k} = \frac{n!}{k!(n-k)!}
\]

For our case, \(n = 52\) and \(k = 4\):

\[
\text{Total ways} = \binom{52}{4} = \frac{52!}{4!(52-4)!} = \frac{52 \times 51 \times 50 \times 49}{4 \times 3 \times 2 \times 1} = 270725
\]

## Step 2: Count the Ways to Select 4 Cards of the Same Suit

There are 4 suits in a deck (hearts, diamonds, clubs, and spades). We can choose any one of the 4 suits, and then we need to choose 4 cards from the 13 available cards in that suit.

The number of ways to choose 4 cards from one suit is:

\[
\binom{13}{4} = \frac{13!}{4!(13-4)!} = \frac{13 \times 12 \times 11 \times 10}{4 \times 3 \times 2 \times 1} = 715
\]

Since there are 4 suits, the total number of ways to choose 4 cards all from the same suit is:

\[
\text{Ways to select 4 cards of the same suit} = 4 \times \binom{13}{4} = 4 \times 715 = 2860
\]

## Step 3: Calculate the Probability

Now we can calculate the probability that all four selected cards are from the same suit by dividing the number of favorable outcomes by the total outcomes:

\[
\text{Probability} = \frac{\text{Ways to select 4 cards of the same suit}}{\text{Total ways to select 4 cards}} = \frac{2860}{270725}
\]

## Final Calculation

Calculating the probability gives:

\[
\text{Probability} \approx 0.01058
\]

To express this as a percentage:

\[
\text{Probability} \approx 1.058\%
\]

## Conclusion

The probability that all four cards drawn from a standard deck are of the same suit is approximately **1.06%**.