05 Bayes Lab (using binomial random variables)
-------------------------------------

As you may (possibly) recall, it's possible to take Bayes theorem (which helps us find condition probabilities):

$$ P(A|B) = 
\frac{P(A)\cdot P(B|A)}{P(A)\cdot P(B|A) + P(\bar{A})\cdot P(B|\bar{A})} $$

and rearrange it into a formula to help up find relative odds.

Recall that:

$$ odds(A) = \frac{P(A)}{P(\bar{A})} $$

then we can say that 

$$ odds(A|B) = \frac{
\frac{P(A)\cdot P(B|A)}{P(A)\cdot P(B|A) + P(\bar{A})\cdot P(B|\bar{A})}
}{
\frac{P(\bar{A})\cdot P(B|\bar{A})}{P(\bar{A})\cdot P(B|\bar{A}) + P(A)\cdot P(B|A) }
}$$ 

or, more simply:

$$ odds(A|B) = \frac{P(A)\cdot P(B|A)}{P(\bar{A})\cdot P(B|\bar{A})} $$ 

or, even:

$$ odds(A|B) = odds(A) \cdot \frac{P(B|A)}{P(B|\bar{A})} $$ 

This is now a system for updating our beliefs or hypotheses (H) based on new evidence (E):

$$ odds(H|E) = odds(/H) \cdot \frac{P(E|H)}{P(E|\bar{H})} $$

The "posterior" odds of this hypothesis being true (in light of the evidence) is equal to the "prior" odds of this hypothesis being true (prior to the evidence) multiplied by the likelihood of seeing this evidence/result given this hypothesis is true divided by the likelihood of seeing this evidence/result if the hypothesis is false.





