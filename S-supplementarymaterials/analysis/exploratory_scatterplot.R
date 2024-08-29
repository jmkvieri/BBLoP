#Load data and packages-------------------------------------------
library(here)

load(here("3-part3","data","aginau_data.RData"))

#please note that Ag-in-Au has been divided by 0.4 for modelling purposes,
#so the plot converts this back to the original scale of weight percent



#Plotting---------------------------------------------------------

#set save destination
png(
  file = here("S-supplementarymaterials","figures","exploratory_muisca_aginau.png"),
  width=1754,
  height=1240
)


#set plotting parameters
par(cex=2,
    cex.axis=1.5,
    cex.lab=1.5,
    mar=c(4,6,2,8),
    omi=c(0.2,0.2,1,0.2),
    lwd=3
)


#set colours
palette(c("black","blue"))

#plot cu vs volume, object type
plot(aginau~volume,data=data_aginau,
     pch=21,
     col=object_type,
     xlab=expression("Volume (cm"^3*")"),
     ylab="Ag wt%/ (Au wt% + Ag wt%)",
     cex=1.5,
     yaxt="n",
     ylim=c(0,1))

axis(2, at = seq(0, 1, by = 0.25), labels=c(0, 0.1, 0.2, 0.3, 0.4))

legend("topright",
       legend = levels(data_aginau$object_type),
       col = c("black","blue"),
       pch = 21,
       cex = 1.5)


dev.off()

