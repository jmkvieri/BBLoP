#Load data and packages-------------------------------------------
library(here)

load(here("1-part1","data","simulated_nonvardisp.RData"))

#please note that Ag-in-Au has been divided by 0.4 for modelling purposes,
#so the plot converts this back to the original scale of weight percent



#Plotting---------------------------------------------------------

#set save destination
png(
  file = here("S-supplementarymaterials","figures","log_skewness.png"),
  width=1754,
  height=1000
)


#set plotting parameters
par(mfrow=c(1,2),
    cex=2,
    cex.axis=1.5,
    cex.lab=1.5,
    lwd=3
)


#set colours
palette(c("black","blue"))

#plot cu vs volume, object type
plot(density(simulated$comp), main="Density of simulated data")

plot(density(log(simulated$comp)), main="Density of log-transformed simulated data")


dev.off()

