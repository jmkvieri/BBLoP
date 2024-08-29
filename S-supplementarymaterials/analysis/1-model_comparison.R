#Load data and packages------------------------------------------------------
library(here)
library(rstan)
library(rstanarm)
library(scales)

load(here("3-part3","data","aginau_data.RData"))
load(here("3-part3","model_outputs","aginau_model.RData"))
load(here("S-supplementarymaterials","model_outputs","aginau_model1_for_comparison.RData"))
load(here("S-supplementarymaterials","model_outputs","aginau_model2_for_comparison.RData"))


#Formal model comparison using LOO---------------------------------------------

#Calculate loo for each model

loomulti <- loo(fit_muisca_aginau_multi)
loo_nonmulti_vardisp <- loo(fit_muisca_aginau_beta_vardisp)
loo_nonmulti_novardisp <- loo(fit_muisca_aginau_beta_novardisp)

#Compare loo
aginau_loo <- loo_compare(loomulti, loo_nonmulti_vardisp, loo_nonmulti_novardisp)


write.csv(aginau_loo, here("S-supplementarymaterials","tables","loo_model_comparison.csv"))


#Plot model predictions vs original data points--------------------------------


#save original data to plot against predictions
y <- data_aginau$aginau


png(file="./S-supplementarymaterials/figures/aginau_model_comp.png",
    width=1748,
    height=1240
)

par(mfrow=c(2,2),
    lwd=2,
    cex=1.7,
    cex.main=1,
    mar=c(4,4,2,2),
    omi=c(0.2,0.2,0.2,0.2))


#plot final model
yrep <- rstan::extract(fit_muisca_aginau_multi)[["y_rep"]]

yrep1_mean <- apply(yrep , 2 , mean)
yrep1_PI <- apply(yrep , 2 , quantile, probs=c(0.25,0.75))

plot(NA,
     xlab = "Ag-in-Au (wt%)" ,
     ylab = "Predicted Ag-in-Au (wt%)",
     ylim=c(0,1),
     xlim=c(0,1),
     xaxt="n",
     yaxt="n",
     main="a) Final model")

for (i in 1:nrow(data_aginau))
  lines(rep(data_aginau$aginau[i], 2) , yrep1_PI[, i]  , col=alpha(rgb(0,0,0), 0.3))


points(
  yrep1_mean ~ y,
  cex = 1.1,
  pch=21,
  bg = "white"
)

#change axes from modelling scale (scaled with 40wt% as maximum) back to original scale of wt%
axis(1, at = seq(0, 1, by = 0.25), labels=c(0, 10, 20, 30, 40))
axis(2, at = seq(0, 1, by = 0.25), labels=c(0, 10, 20, 30, 40))


#add line through perfect predictions
abline(a = 0 , b = 1 , lty = 2)



#now plot var disp. beta reg with no hierarchical structure
yrep <- rstan::extract(fit_muisca_aginau_beta_vardisp)[["y_rep"]]


yrep1_mean <- apply(yrep , 2 , mean)
yrep1_PI <- apply(yrep , 2 , quantile, probs=c(0.25,0.75))



plot(NA,
     xlab = "Ag-in-Au (wt%)" ,
     ylab = "Predicted Ag-in-Au (wt%)",
     ylim=c(0,1),
     xlim=c(0,1),
     xaxt="n",
     yaxt="n",
     main="c) Var disp. beta reg.")

for (i in 1:nrow(data_aginau))
  lines(rep(data_aginau$aginau[i], 2) , yrep1_PI[, i]  , col=alpha(rgb(0,0,0), 0.3))


points(
  yrep1_mean ~ y,
  cex = 1.1,
  pch=21,
  bg="white"
)

#change axes from modelling scale (scaled with 40wt% as maximum) back to original scale of wt%
axis(1, at = seq(0, 1, by = 0.25), labels=c(0, 10, 20, 30, 40))
axis(2, at = seq(0, 1, by = 0.25), labels=c(0, 10, 20, 30, 40))


#add line through perfect predictions
abline(a = 0 , b = 1 , lty = 2)


#finally, model accounting only for type 1 variability
yrep <- rstan::extract(fit_muisca_aginau_beta_novardisp)[["y_rep"]]


yrep1_mean <- apply(yrep , 2 , mean)
yrep1_PI <- apply(yrep , 2 , quantile, probs=c(0.25,0.75))


plot(NA,
     xlab = "Ag-in-Au (wt%)" ,
     ylab = "Predicted Ag-in-Au (wt%)",
     ylim=c(0,1),
     xlim=c(0,1),
     xaxt="n",
     yaxt="n",
     main="d) Beta reg.")

for (i in 1:nrow(data_aginau))
  lines(rep(data_aginau$aginau[i], 2) , yrep1_PI[, i]  , col=alpha(rgb(0,0,0), 0.3))


points(
  yrep1_mean ~ y,
  cex = 1.1,
  pch=21,
  bg="white"
)

#change axes from modelling scale (scaled with 40wt% as maximum) back to original scale of wt%
axis(1, at = seq(0, 1, by = 0.25), labels=c(0, 10, 20, 30, 40))
axis(2, at = seq(0, 1, by = 0.25), labels=c(0, 10, 20, 30, 40))


#add line through perfect predictions
abline(a = 0 , b = 1 , lty = 2)


dev.off()




