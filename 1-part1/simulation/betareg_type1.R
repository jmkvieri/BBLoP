#Load data and packages--------------------------------------------------------
library(here)
library(rstan)
library(ggplot2)
library(brms)

#Helper functions--------------------------------------------------------------
inv_logit <- function(x) {
  1 / (1 + exp(-x))
}

#Simulate compositional data---------------------------------------------------
set.seed(1241)

N   <- 500                  # Sample size
predictor <- rexp(N,0.8)    # Continuous predictor
X   <- cbind(1, predictor)  # Design matrix with intercept and predictor
beta <- c(-3.5, 1.2)        # Regression coefficients

mu   <- inv_logit(X %*% beta)
phi  <- 80

#convert to shape parameters
p <- mu * phi
q <- (1 - mu) * phi


#draw samples from random beta distribution
y <- rbeta(N, p, q)

#save simulated data as data frame
simulated <- data.frame(comp=y, predictor)

#Aaccount for inability of model to consider 100% or 0%
simulated$comp[simulated$comp < 0.01 ] <- 0.01
simulated$comp[simulated$comp == 1] <- 0.9999

#order dataset for plotting later
simulated <- simulated[order(simulated$comp),]

#save simulated data as RData to use in Supplementary Material
save(simulated, file=here("1-part1", "data", "simulated_nonvardisp.RData"))

#RUN MODELS---------------------------------------------------------------------


#Run Gaussian model on non-transformed data for comparison
fit_linear <-
  brm(
    formula =  bf(comp ~ predictor),
    data = simulated, family="gaussian"
  )

#Run Gaussian model on log-transformed data for comparison
fit_linear_log <-
  brm(
    formula =  bf(log(comp) ~ predictor),
    data = simulated, family="gaussian"
  )



#create model matrix for predictors 
X_comp  <- model.matrix(~ predictor,
                        data = simulated)


#pass data to stan
stan_simulated = list(
  N = length(simulated$comp),
  K = ncol(X_comp),
  y = simulated$comp,
  X = X_comp
)


fit_beta <-
  rstan::stan(
    file = here("0-stanmodelcodes","betareg.stan"),
    data = stan_simulated,
    warmup = 1000,
    iter = 2000,
    chains = 4
  )



#PLOT MODEL PREDICTIONS-----------------------------------------------------------------------------

png(file = here("1-part1","figures","simulated_model_performance.png"), width=1700, height=1200)

par(mfrow=c(2,3),
    cex=1.5)


plot.new()

plot(density(simulated$comp),col="red",xlim=c(0,1),  xaxt="n", main="Density of simulated compositions")
axis(1, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))

plot.new()

#original data

y <- simulated$comp



#first plot model without transformations

#extract predictions
yrep <- posterior_predict(fit_linear)

yrep1_mean <- apply(yrep , 2 , mean)
yrep1_PI <- apply(yrep , 2 , quantile, probs=c(0.025,0.975))


plot(NA,
     xlab = "Element (wt%)" ,
     ylab = "Predicted element (wt%)",
     ylim=c(-0.3,1.6),
     xlim=c(0,1),
     xaxt="n",
     yaxt="n",
     main="Linear reg. on non-transformed data")

for (i in 1:nrow(simulated))
  lines(rep(simulated$comp[i], 2) , yrep1_PI[, i]  , col=alpha(rgb(0,0,0), 0.3))


points(
  yrep1_mean ~ y,
  cex = 1.1,
  pch=21,
  bg = ifelse(simulated$x_2==1,"white","blue")
)

#change axes back to original scale
axis(1, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))
axis(2, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))


#add line through perfect predictions
abline(a = 0 , b = 1 , lty = 2)
abline(a = 1 , b = 0 , col = "red")
abline(a = 0 , b = 0 , col = "red")


#second plot model using log transformations

#extract predictions
yrep <- exp(posterior_predict(fit_linear_log))

yrep1_mean <- apply(yrep , 2 , mean)
yrep1_PI <- apply(yrep , 2 , quantile, probs=c(0.025,0.975))


plot(NA,
     xlab = "Element (wt%)" ,
     ylab = "Predicted element (wt%)",
     ylim=c(-0.3,1.6),
     xlim=c(0,1),
     xaxt="n",
     yaxt="n",
     main="Linear reg. on log-transformed data")

for (i in 1:nrow(simulated))
  lines(rep(simulated$comp[i], 2) , yrep1_PI[, i]  , col=alpha(rgb(0,0,0), 0.3))


points(
  yrep1_mean ~ y,
  cex = 1.1,
  pch=21,
  bg = ifelse(simulated$x_2==1,"white","blue")
)

#change axes back to original scale
axis(1, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))
axis(2, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))


#add line through perfect predictions
abline(a = 0 , b = 1 , lty = 2)
abline(a = 1 , b = 0 , col = "red")
abline(a = 0 , b = 0 , col = "red")



#now plot model using beta distribution

#extract predictions
yrep <- rstan::extract(fit_beta)[["y_rep"]]

yrep1_mean <- apply(yrep , 2 , mean)
yrep1_PI <- apply(yrep , 2 , quantile, probs=c(0.025,0.975))


plot(NA,
     xlab = "Element (wt%)" ,
     ylab = "Predicted element (wt%)",
     ylim=c(-0.3,1.6),
     xlim=c(0,1),
     xaxt="n",
     yaxt="n",
     main="Beta reg. on non-transformed data")

for (i in 1:nrow(simulated))
  lines(rep(simulated$comp[i], 2) , yrep1_PI[, i]  , col=alpha(rgb(0,0,0), 0.3))


points(
  yrep1_mean ~ y,
  cex = 1.1,
  pch=21,
  bg = ifelse(simulated$x_2==1,"white","blue")
)

#change axes back to original scale
axis(1, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))
axis(2, at = seq(0, 1, by = 0.1), labels = seq(0, 100, by=10))

#add line through perfect predictions
abline(a = 0 , b = 1 , lty = 2)
abline(a = 1 , b = 0 , col = "red")
abline(a = 0 , b = 0 , col = "red")


dev.off()



