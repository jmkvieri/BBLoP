#Load data and packages--------------------------------------------------------
library(here)
library(rstan)
library(ggplot2)

#Helper functions--------------------------------------------------------------
inv_logit <- function(x) {
  1 / (1 + exp(-x))
}


#Simulate data-----------------------------------------------------------------
set.seed(1234)

N   <- 250                                 # Sample size
predictor <- runif(N,min=0,max=5)          # Continuous predictor
x_1 <- scale(predictor)                    # Standardise predictor
X   <- cbind(1, x_1)                       # Design matrix


#Set parameter values
gamma_list <- c(0, -1.5, 1.5)

#create empty list for diff sets of sim data
simulated <-  list()
fit_beta_test <- list()


for (i in 1:length(gamma_list)) {
  
  beta <- c(0, 0)      # Coefficients
  gamma <- c(3.5, gamma_list[i])      # Coefficients
  
  mu   <- inv_logit(X %*% beta)
  phi  <- exp(X %*% gamma)
  
  p <- mu * phi
  q <- (1 - mu) * phi
  
  y <- rbeta(N, p, q)
  
  simulated[[i]] <- data.frame(x_1, comp = y)
  
  
  #Aaccount for inability of model to consider 0% or 100%
  simulated[[i]]$comp[simulated[[i]]$comp == 0] <-
    min(subset(simulated[[i]], simulated[[i]]$comp != 0)$comp) * (2 / 3)
  
  simulated[[i]]$comp[simulated[[i]]$comp == 1] <- 0.9999
  
  
  #create model matrix for predictors with both fixed and random effects
  X_comp  <- model.matrix(~ x_1,
                          data = simulated[[i]])
  
  
  plot(simulated[[i]])
  
  #RUN FINAL MODELS-----------------------------------------------------------------------------
  
  #pass data to stan
  stan_simulated = list(
    N = length(simulated[[i]]$comp),
    K = ncol(X_comp),
    y = simulated[[i]]$comp,
    X = X_comp
  )
  
  
  fit_beta_test[[i]] <-
    rstan::stan(
      file = here("0-stanmodelcodes","betareg_vardisp.stan"),
      data = stan_simulated,
      warmup = 1000,
      iter = 2000,
      chains = 4
    )
  
}



#Choose values of volume to predict for
pred.seq <-
  seq(
    from = min(simulated[[i]]$x_1) ,
    to = max(simulated[[i]]$x_1) ,
    length.out = 30
  )

#create original scale for plotting
scale_x <-
  scale_x_continuous(breaks = sapply(seq(
    from = min(predictor),
    to = max(predictor),
    by = 2),
    function(non_standard)
      (non_standard - mean(predictor)) / sd(predictor)),
    labels = round(seq(
      from = min(predictor),
      max(predictor),
      by = 2),
      digits = 1))


#adjust theme

My_Theme = theme(
  axis.title.x = element_text(size = 26,vjust = -0.75),
  axis.text.x = element_text(size = 24),
  axis.text.y = element_text(size = 24),
  axis.title.y = element_text(size = 26),
  legend.text = element_text(size = 26),
  legend.title = element_text(size = 26),
  legend.position = "bottom",
  legend.box.spacing = unit(25, "pt"))

#create empty lists
pred <-  list()
pred_mean <- list()
pred_PI95 <- list()


pred_phi <-  list()
pred_phi_mean <- list()
pred_phi_PI95 <- list()

pred_var_mean <- list()
pred_var_PI95 <- list()


#calculate predictions on the outcome scale

for (i in 1:3) {
  
  post <- extract(fit_beta_test[[i]])
  
  pred[[i]] <-  sapply(pred.seq , function(pred)
    (inv_logit(
      (post$beta[, 1] + 
         post$beta[, 2] * pred 
      ))
    )
  )
  
  pred_phi[[i]] <-  sapply(pred.seq , function(pred)
    (exp(
      (post$gamma[, 1] + 
         post$gamma[, 2] * pred 
      ))
    )
  )
  
  
  pred_mean[[i]] <- apply( pred[[i]] , 2 , mean )
  pred_PI95[[i]] <- apply( pred[[i]] , 2 , quantile, probs=c(0.025,0.975))
  pred_phi_mean[[i]] <- apply( pred_phi[[i]] , 2 , mean )
  pred_phi_PI95[[i]] <- apply( pred_phi[[i]] , 2 , quantile, probs=c(0.025,0.975))
  pred_var_mean[[i]] <- apply((pred[[i]] * (1 - pred[[i]])) / (pred_phi[[i]] + 1), 2, mean)
  pred_var_PI95[[i]] <- apply((pred[[i]] * (1 - pred[[i]])) / (pred_phi[[i]] + 1), 2, quantile, probs=c(0.025,0.975))
  
  
}


#plot original data points and model predictions

for (i in 1:3) {
  graph <- ggplot() + 
    geom_ribbon(aes(
      x = pred.seq,
      ymin = pred_mean[[i]] - sqrt(pred_var_mean[[i]]),
      ymax = pred_mean[[i]] + sqrt(pred_var_mean[[i]])
    ), alpha = 0.20) +
    ylim(c(0, 1)) +
    geom_line(aes(x = pred.seq, y = pred_mean[[i]]),
              linewidth = 1.5,
              colour = "#F8766D") + scale_x +
    geom_point(aes(x = simulated[[i]]$x_1, y = simulated[[i]]$comp), size = 2) +
    My_Theme + ylab("Predicted mean +/- SD of element") + xlab("Predictor")
  
  png(
    file = paste(
      here("1-part1","figures","sim_comp_pred"),i,".png",sep=""),
      height=1000,
      width=1000
  )
  
  print(graph)
  
  dev.off()
  
  graph <- ggplot() + 
    geom_ribbon(aes(
      x = pred.seq,
      ymin = sqrt(pred_var_PI95[[i]][1, ]),
      ymax = sqrt(pred_var_PI95[[i]][2, ])
    ), alpha = 0.20) +
    ylim(c(0, 0.35)) +
    geom_line(aes(x = pred.seq, y = sqrt(pred_var_mean[[i]])),
              linewidth = 1.5,
              colour = "#F8766D") + scale_x +
    My_Theme + ylab("SD of element (wt%)") + xlab("Predictor")
  
  png(
    file = paste(
      here("1-part1","figures","sim_comp_SD_pred"),i,".png",sep=""),
      height=1000,
      width=1000
  )
  
  print(graph)
  
  dev.off()
  
}
