Numerical Inference Problems
---------------------------------------

1. National data show that on average, college freshmen spend 7.5 hours a week going to parties.  One administrator does not believe that these figures apply at her college, which has nearly 3000 freshmen.  She takes a simple random sample of 100 freshmen, and interviews them.  On average they spend 6.6 hours a week going to parties and the standard deviation is 9 hours.  Is this compelling evidence that students at her school average less than 7.5 hours a week at parties?

2. Does the psychological environment affect the anatomy of the brain?  This question was studied experimentally by Mark Rosenzweig and others.  The subjects from the strain were rats.  From each of 59 litters of rats, one rat was selected at random for the treatment group and one rate was selected for the control group.  Both groups got exactly the same kind of food and drink but each animal in the treatment group living with 11 others in a large cage, furnished with playthings and changed daily.  Animals in the control group living in isolation with no toys.  After a month, both the treatment and controls rats were killed and dissected.  The cortexes (known as the "grey matter" or thinking parts of the brains) were weighed for every rat.  The following data shows the masses of the cortexes in milligrams with for treatment and control mice.  The first values in both the treatment and control groups are rats from the first liter and the second values are rates from the second liter and so on.

```r

treatment = c(689, 656, 668, 660, 679, 663, 664, 647, 694, 633, 653,
      707, 740, 745, 652, 649, 676, 699, 696, 712, 708, 749, 690,
      690, 701, 685, 751, 647, 647, 720, 718, 718, 696, 658, 680,
      700, 718, 679, 742, 728, 677, 696, 711, 670, 651, 711, 710,
      640, 655, 624, 682, 687, 653, 653, 660, 668, 679, 638, 649)
      
control = c(657, 623, 652, 654, 658, 646, 600, 640, 605, 635, 642,
      669, 650, 651, 627, 656, 642, 698, 648, 676, 657, 692, 621,
      668, 667, 647, 693, 635, 644, 665, 689, 642, 673, 675, 641,
      662, 705, 656, 652, 578, 678, 670, 647, 632, 661, 670, 694,
      641, 589, 603, 642, 612, 603, 593, 672, 612, 678, 593, 602)

```

One things that researchers noticed is that if one of the experimental rats from a liter had a large cortex there was a tendency for the other rat from that same litter to have a large cortex.  The correlation between the brain sizes of treatment and control was is 0.48:

```r
cor(treatment, control)
```

But the researchers are also interested in whether the treatment affected cortex size.  Is there evidence in this data that it did?  Please explain.

3. During the 1970's, the Multiple Risk Factor Interventiain Trial tested the effect of an intervention to reduce serum cholesterol levels and blood pressure.  The subjects were 12,866 men aged 35-57, at high risk for heart disease.  6,428 were randomized into the intervention group and 6,438 to the control group.  The intervention included counseling on diet and smoking, and in some cases therapy to reduce blood pressure.  Subject were followed for a minimum of 6 years.

a. Blood Pressure

On entry to the study, the diastolic blood pressure of the intervention group averaged 91.0 mm Hg, with a SD of 7.6 mm Hg.  After six years, their blood pressures averaged 80.5 with an SD of 7.9.  On entry to the study, the blood pressures of the control group averaged 90.9 with a SD of 7.7.  After six years, they averaged 83.6 with an SD of 9.2. What do you conclude?

b. Cholesterol

On entry to the study, the cholesterol levels of the intervention group averaged 253.8 mg/dl, with a SD of 36.4 mg/dl.  After six years, their cholesterol levels averaged 235.5 with a SD of 38.3.  On entry to the study, the blood pressures of the control group averaged 253.5 with a SD of 36.8.  After six years, they averaged 240.3 with an SD of 39.9. What do you conclude?
