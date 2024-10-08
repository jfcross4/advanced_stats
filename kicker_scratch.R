prob_far_enough = 1/(1 + exp(a + b*distance))

# width of crossbars is about 6 yards
# angle_from_center is roughly sin(6/distance)

#imagine kicker angles 
# have a standard deviation of 10 degrees
# then the chance of missing by more than 20 degrees
# is:
2*pnorm(20/10)

# so, the chance of a kicker missing the angle is:

pnorm(sin(6/distance)/s)
# where s is the standar deviation in kickers kicks

m = nls(rate ~ pnorm(sin(6/Distance)/s)/
              (1 + exp(a + b*Distance)),
               start=list(s=pi/18, a = 0, b=0.01),
               data=success_at_distance,
               weights=n)


m2 = nls(rate ~ (2*pt(sin(3/Distance)/(s+s2*Distance), df=3)-1)/
          (1 + exp(a + b*Distance)),
        start=list(s=5.501e-02, 
                   a = -1.386e+01, 
                   b=2.288e-01,
                   s2=0),
        data=success_at_distance,
        weights=n)
summary(m2)
#Estimate Std. Error t value Pr(>|t|)    
# s  0.08117    0.01466   5.536 1.14e-06 ***
#   a -7.11908    1.00673  -7.071 4.64e-09 ***
#   b  0.12135    0.01721   7.052 4.98e-09 ***

distance <- seq(18, 80, 1)
plot(distance, 
     predict(m, list(Distance=distance), 
             type="response"), 
     type="l", ylab="Predicted Success Rate")

lines(distance, 
     predict(m2, list(Distance=distance), 
             type="response"), lty=2)

points(success_at_distance$Distance, 
       success_at_distance$rate)

lines(distance, 
      predict(m.logistic, list(Distance=distance), 
              type="response"), col="red")

lines(distance, 
      pt(sin(6/distance)/
           (coef(m2)["s"]+coef(m2)["s2"]*distance), df=2), col="blue")

lines(distance, 
      1/(1 + exp(coef(m2)["a"] + coef(m2)["b"]*distance)), 
      col="green")
