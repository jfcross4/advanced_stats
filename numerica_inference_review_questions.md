Numerical Inference Review Questions
---------------------------------------

**For each question, state the null hypothesis, determine the type of test to perform, test the null hypothesis (you can use an $\alpha = 0.05$), and write down the relevant numbers (degrees of freedom, p-value...).**

1. Imagine we are studying the impact of a new teaching method on student performance. The national average score for the exam in question is 75. After implementing the new teaching method with a sample of 30 students (taught individually), their scores on the same exam were recorded. We want to know if there is a significant difference between the average score of students taught using the new method and the national average.

```r
scores = 
  c(79.7, 74.5, 88.7, 76.7, 74.1, 79.0, 77.4,
    74.8, 79.4, 83.3, 80.7, 85.6, 82.8, 78.1,
    75.1, 80.8, 79.4, 70.7, 78.2, 81.3, 79.9,
    75.8, 68.7, 77.5, 76.8, 80.8, 77.2, 71.3,
    81.2, 72.9)
```

Is there evidence, based on this sample, that students taught with this new method do better than the national average?  

2. Researchers are conducting a study to determine if a new sleep aid increases the total amount of sleep. A group of 20 participants is selected, and their sleep patterns are monitored for two nights: one night without the sleep aid (control) and one night with the sleep aid (treatment). The total hours of sleep for each participant are recorded for both nights. The researchers want to know if there is a significant difference in the total hours of sleep between the two conditions.

The following data contains the hours of sleep for each of the 20 participants on both the control night and treatment night.  Participants are listed in the same order in both vectors.

```r
control_sleep = 
  c(5.4, 5.8, 7.6, 6.1, 6.1, 7.7, 6.5, 4.7, 
    5.3, 5.6, 7.2, 6.4, 6.4, 6.1, 5.4, 7.8, 
    6.5, 4.0, 6.7, 5.5)
    
treatment_sleep =
  c(5.9, 6.7, 8.0, 6.7, 6.8, 7.9, 7.9, 5.8, 5.7,
    7.2, 8.4, 7.2, 7.8, 7.5, 6.9, 9.1, 7.8, 5.0,
    7.5 6.3)
``` 

Is there evidence, based on this sample, that this treatment increases sleep hours?

3. A company has developed two new training programs aimed at improving employee productivity. To determine which program is more effective, they randomly assign 40 employees to two groups: Group 1 undergoes Training Program A, and Group 2 undergoes Training Program B. At the end of the training programs, the productivity increase (measured as the percentage increase in tasks completed per day) for each employee is recorded. The company aims to determine if there is a significant difference in the average productivity increase between employees trained with Program A and those trained with Program B.

```r
pt =
  c(8.3, 18.1, 19.0, 8.1, 11.4, 13.4, 18.5,
    16.3, 20.0, 17.9, 10.4, 21.6, 19.9, 23.3,
    7.8, 24.7, 23.7, 16.9, 26.4, 22.7)

productivity_increase_B =
  c(17.6, 11.4, 12.9, 21.0, 19.8, 25.7, 17.7,
    18.4, 27.4, 14.6, 17.4, 17.0, 10.0, 21.5,
    20.9, 29.1, 16.7, 19.3, 17.9, 19.8)
```

Is there compelling evidence that one of these methods increases productivity more than the other?

4. A school wants to evaluate two study techniques: Technique A and Technique B. To assess their effectiveness, two separate groups of students were taught using these techniques. After a period of instruction, the exam scores were collected. For this problem, we don't have individual scores but only the summary statistics for each group.

* Group 1 (Technique A): Mean exam score = 78, Standard Deviation = 8, Number of Students = 90

* Group 2 (Technique B): Mean exam score = 80, Standard Deviation = 10, Number of Students = 105

The school aims to determine if there is a significant difference in the average exam scores between students taught with Technique A and those with Technique B.  What do you tell them?
