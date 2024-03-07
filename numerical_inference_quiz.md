Numerical Inference Quiz
---------------------------------------

**For each question, state the null hypothesis, determine the type of test to perform, test the null hypothesis (you can use an $\alpha = 0.05$), and write down the relevant numbers (degrees of freedom, p-value...).**

**1.** A physical therapist introduces a new physical therapy regimen aimed at improving knee joint flexibility in patients experiencing knee stiffness due to arthritis. To evaluate the effectiveness of this regimen, the therapist measures the maximum angle of flexion (in degrees) that each patient can achieve with their knee joint before starting the regimen and again after completing a 6-week program. The goal is to determine whether there is a statistically significant improvement (meaning a larger angle) in knee joint flexibility after the 6-week regimen.  Please help them analyze their data.

Data:
Here are the maximum knee flexion angles (in degrees) for each of the 8 patients before and after completing the regimen

| Patient | Before Regimen | After Regimen |
|:----:|:--------------:|:-------------:|
|  1   |       60       |       62      |
|  2   |       65       |       67      |
|  3   |       62       |       66      |
|  4   |       58       |       59      |
|  5   |       59       |       59      |
|  6   |       63       |       67      |
|  7   |       60       |       63      |
|  8   |       61       |       65      |

```r
before_regimen <- c(60, 65, 62, 58, 59, 63, 60, 61)
after_regimen <- c(62, 67, 66, 59, 59, 67, 63, 65)
```
\
\

**2.** A company is interested in improving employee efficiency by providing ergonomic keyboards. To decide between two popular models, they conduct a study to compare the average typing speeds (in words per minute, WPM) of two groups of employees using these keyboards. Group 1 uses Ergonomic Keyboard Model A, and Group 2 uses Ergonomic Keyboard Model B. Each group consists of employees who had not previously used ergonomic keyboards to minimize experience bias. The company aims to determine if there is a significant difference in the typing speeds between employees using Model A and those using Model B.  Please help them analyze their data.

Data:
Here are the hypothetical typing speeds for each of the groups:

Model A: 68, 75, 70, 73, 76, 65, 71, 69

Model B: 77, 80, 74, 82, 85, 78, 75, 79

```r
typing_speeds_A <- c(68, 75, 70, 73, 76, 65, 71, 69)
typing_speeds_B <- c(77, 72, 74, 67, 70, 78, 75, 79)
```
\
\
**3.** A light bulb manufacturer claims that their new energy-efficient light bulb has an average lifespan of 8000 hours. To test this claim, a quality control manager at a retail store decides to test a sample of these light bulbs by running them continuously until they fail. After testing a random sample of 15 light bulbs, the following lifespans (in hours) were recorded:

Lifespans: 7950,8070,7980,8200,8100,7800,7800,7900,8020,8050,7960,8040,7980,7850,8200

```r
lifespans <- c(7950, 8070, 7980, 8200, 8100, 7800, 7800, 7900, 8020, 8050, 7960, 8040, 7980, 7850, 8200)
```

The manager wants to determine if the average lifespan of this sample significantly differs from the manufacturer's claim.  Please act as the statistician for this manager.
\
\

**4.** A botanist wants to compare the effectiveness of two fertilizers, Fertilizer A and Fertilizer B, on the growth of a particular type of plant. Two groups of plants are grown under controlled conditions, with one group receiving Fertilizer A and the other group receiving Fertilizer B. At the end of the growth period, the botanist measures the increase in height of the plants in each group. The botanist has compiled the following summary statistics:

**Group 1 (Fertilizer A):**

* Mean height increase = 13 cm
* Standard Deviation = 3 cm
* Number of Plants = 80

**Group 2 (Fertilizer B):**

* Mean height increase = 15 cm
* Standard Deviation = 4 cm
* Number of Plants = 80

The botanist aims to determine if there is a significant difference in the average height increase between plants treated with Fertilizer A and those treated with Fertilizer B.  Please help the botanist analyze this data.
