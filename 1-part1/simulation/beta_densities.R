#Load data and packages--------------------------------------------------------
library(here)

#set save destination
png(
  file = here("1-part1","figures","beta_densities.png"),
  width=1548,
  height=1240
)

#set plotting parameters
par(mfrow=c(5,3),
    cex=1.4,
    cex.axis=1.5,
    cex.lab=1.5,
    mar=c(4,6,2,2),
    omi=c(0.2,0.2,0.2,0.2),
    lwd=3
)

#create different values for mu and phi
mu <- c(rep(c(0.2,0.5,0.8),times=5))
phi <- c(rep(0.5,times=3),rep(2,times=3),rep(10,times=3),rep(100,times=3),rep(500,times=3))

#plot curves for the beta densities
for (i in 1:length(mu)) {
  curve( dbeta(x,(mu[i]*phi[i]),((1-mu[i])*phi[i])) , from=0 , to=1 ,
         xlab=bquote(paste(~mu,"=",.(mu[i]),~phi,"=",.(phi[i]))),
         ylab="Density")
}

dev.off()
