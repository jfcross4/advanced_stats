# Numerical Inference Practice Quiz – April Edition

For each question, state the null hypothesis, determine the type of test to perform, test the null hypothesis (you can use an α = 0.05), and write down the relevant numbers (degrees of freedom, p-value, etc.).

---

### **1. Spring Training and Batting Performance**

A baseball coach wants to see if a spring training program improves batting averages. Ten players are tested before and after participating in the training.

**Data (batting averages):**

| Player | Before Training | After Training |
|--------|------------------|----------------|
| 1      | 0.240            | 0.255          |
| 2      | 0.250            | 0.265          |
| 3      | 0.230            | 0.230          |
| 4      | 0.235            | 0.250          |
| 5      | 0.225            | 0.225          |
| 6      | 0.245            | 0.260          |
| 7      | 0.238            | 0.252          |
| 8      | 0.242            | 0.257          |
| 9      | 0.236            | 0.250          |
| 10     | 0.229            | 0.215          |

```r
before <- c(0.240, 0.250, 0.230, 0.235, 0.225, 0.245, 0.238, 0.242, 0.236, 0.229)
after <- c(0.255, 0.265, 0.230, 0.250, 0.225, 0.260, 0.252, 0.257, 0.250, 0.215)
```

---

### **2. Spring Break Study Habits**

Two colleges want to compare how much students study during spring break. Independent samples are taken from each school.

**Data (hours studied over spring break):**

- **College A**: 8, 6, 4, 10, 7, 6, 5, 4  
- **College B**: 5, 9, 7, 3, 9, 8, 7, 10

```r
college_A <- c(8, 6, 4, 10, 7, 6, 5, 4)
college_B <- c(5, 9, 7, 3, 9, 8, 7, 10)
```

---

### **3. Rainy Day Wait Times at Cafés**

A popular café claims that wait times don’t increase on rainy April days. A customer records their wait times during 12 rainy days.

**Rain Day Wait Times (minutes):** 5.2, 5.4, 5.1, 3.5, 5.3, 5.6, 5.8, 3.8, 5.7, 5.9, 5.5, 3.4  
**Non-rain average wait time**: 4.0 minutes

```r
rainy_waits <- c(5.2, 5.4, 5.1, 3.5, 5.3, 5.6, 5.8, 3.8, 5.7, 5.9, 5.5, 3.4)
```

---

### **4. Earth Day Recycling Program Impact**

A city introduces an Earth Day campaign to improve recycling habits.  To test the effects of the campaign they introduce it in one neighborhood while using another similar neighborhood as a control. The following data shows the average pounds of recycling per household in April.

**Summary Statistics:**

- **Control Neighborhood**:  
  - Mean = 16 lbs  
  - Standard deviation = 5 lbs  
  - Sample size = 40

- **Treatment Neighborhood**:  
  - Mean = 22 lbs  
  - Standard deviation = 6 lbs  
  - Sample size = 40

---
