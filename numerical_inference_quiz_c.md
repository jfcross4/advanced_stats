# Numerical Inference Quiz

For each question, state the null hypothesis, determine the type of test to perform, test the null hypothesis (α = 0.05), and report relevant values (degrees of freedom, p-value, etc.).

---

### 1. Volleyball Vertical Jump Training

A volleyball coach measures players’ vertical jump (in inches) before and after a 6-week training program.

| Player | Before | After |
| ------ | ------ | ----- |
| 1      | 22     | 24    |
| 2      | 24     | 26    |
| 3      | 20     | 22    |
| 4      | 23     | 25    |
| 5      | 21     | 22    |
| 6      | 25     | 27    |
| 7      | 22     | 23    |
| 8      | 19     | 21    |
| 9      | 23     | 24    |
| 10     | 21     | 22    |

```r
before <- c(22, 24, 20, 23, 21, 25, 22, 19, 23, 21)
after  <- c(24, 26, 22, 25, 22, 27, 23, 21, 24, 22)
```

---

### 2. Two Study Apps

Two study apps are tested. Students are randomly assigned and their quiz scores (out of 100) are recorded.

* App A: 78, 82, 85, 80, 79, 83, 81, 84
* App B: 80, 79, 83, 81, 82, 78, 84, 80

```r
app_A <- c(78, 82, 85, 80, 79, 83, 81, 84)
app_B <- c(80, 79, 83, 81, 82, 78, 84, 80)
```

---

### 3. National Tutoring Company Claim

A national tutoring company claims that their program improves students’ SAT scores by an average of 100 points.

A random sample of 10 students who completed the program shows the following score improvements:

85, 110, 95, 120, 70, 105, 90, 115, 80, 100

```r
improvements <- c(85, 110, 95, 120, 70, 105, 90, 115, 80, 100)
```

---

### 4. Baseball Exit Velocity Programs

Two training programs are compared.

* Program A:

  * Mean = 91 mph
  * Standard deviation = 4
  * Sample size = 25

* Program B:

  * Mean = 88 mph
  * Standard deviation = 5
  * Sample size = 25

(You may assume 48 degrees of freedom.)

