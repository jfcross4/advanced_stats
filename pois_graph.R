pois_graph = function(lambda){
    xmin = lambda - floor(2.5*sqrt(lambda))
    xmax = lambda + ceiling(2.5*sqrt(lambda))
    range = xmin:xmax
    plot(range, dpois(range, lambda), type="h")}
  
pois_graph(1.5)
pois_graph(3)

pois_graph(10)
pois_graph(30)
ppois_graph(400)
