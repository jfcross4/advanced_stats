Numerical Inference Quiz
---------------------------------------

**For each question, state the null hypothesis, determine the type of test to perform, test the null hypothesis (you can use an $\alpha = 0.05$), and write down the relevant numbers (degrees of freedom, p-value...).**

### **1. High School Softball Training Impact**

A Brooklyn high school softball coach wants to determine if a new strength training program improves players' bench press max. Ten players are tested before and after the 8-week program.  Please help the coach analyze their data.

**Data:**

| Player | Before Program (lbs) | After Program (lbs) |
|--------|----------------------|---------------------|
| 1      | 185                  | 190                 |
| 2      | 190                  | 200                 |
| 3      | 135                  | 140                 |
| 4      | 180                  | 195                 |
| 5      | 170                  | 175                 |
| 6      | 185                  | 192                 |
| 7      | 178                  | 185                 |
| 8      | 82                   | 95                  |
| 9      | 179                  | 188                 |
| 10     | 174                  | 182                 |

```r
before <- c(185, 190, 135, 180, 170, 185, 178, 82, 179, 174)
after <- c(190, 200, 140, 195, 175, 192, 185, 95, 188, 182)
```

---

### **2. College Basketball Free Throw Practice**

A college basketball coach at a CUNY school is evaluating two different free throw routines. Two groups of players are randomly assigned to different warm-ups and then their free throw percentages are recorded.  What can you tell the coach about their free throw routines?

**Data:**

- **Routine A**: 79, 75, 72, 73, 74, 76, 71, 77  
- **Routine B**: 78, 80, 79, 82, 81, 83, 79, 80

```r
routine_A <- c(79, 75, 72, 73, 74, 76, 71, 77)
routine_B <- c(78, 80, 79, 82, 81, 83, 79, 80)
```

---

### **3. Evaluating a Brooklyn Coffee Shop’s Wait Time**

A popular Brooklyn coffee shop claims their average wait time is 4 minutes. A local blogger collects a sample of 12 visit wait times to verify this.  What should the blogger report about the wait times?

**Data (in minutes)**: 4.2, 3.8, 4.1, 4.5, 3.9, 4.3, 4.0, 4.6, 3.7, 4.4, 4.1, 3.9

```r
wait_times <- c(4.2, 3.8, 4.1, 4.5, 3.9, 4.3, 4.0, 4.6, 3.7, 4.4, 4.1, 3.9)
```

---

### **4. Comparing Running Clubs in Prospect Park**

Two Brooklyn running clubs claim to help runners improve 5K race times. After 6 weeks, the average time improvement (in seconds) is compared.  What would you report about these Brooklyn running clubs? (Note: you can assume 58 degrees of freedom when solving this problem).

**Summary Statistics:**

- **Club A**:  
  - Mean improvement = 45 seconds  
  - Standard deviation = 10 seconds  
  - Sample size = 30

- **Club B**:  
  - Mean improvement = 50 seconds  
  - Standard deviation = 12 seconds  
  - Sample size = 30

---