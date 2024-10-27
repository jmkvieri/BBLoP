#Load packages-------------------------------------------------------------------
library(here)
library(rstan)
library(reshape2)

#Helper functions--------------------------------------------------------------
inv_logit <- function(x) {
  1 / (1 + exp(-x))
}


#Simulate data-----------------------------------------------------------------

samples <- list()
cluster <- list()

sample_sizes <- c(rep(20, times = 20))

#create hypothetical clusters to group data into

for (i in 1:20) {
  cluster[[i]] <-
    rep(paste(letters[i], "_cluster", sep = ''), times = sample_sizes[[i]])
}


#create sequence to use as a hypothetical predictor
pred.seq <-
  seq(from = 0 ,
      to = 6 ,
      length.out = 20)


#now create hypothetical dataset

hypo_dataset <-
  as.data.frame(cbind(rep(pred.seq, times = 20), unlist(cluster)))
names(hypo_dataset) <- c("pred", "cluster")
hypo_dataset$pred <- as.numeric(hypo_dataset$pred)
hypo_dataset$cluster <- as.factor(hypo_dataset$cluster)

X <- model.matrix(~ pred, data = hypo_dataset)


#Simulate data from above based on random intercept only------------------------------

sim.int <-
  stan_model(file = here("0-stanmodelcodes","sim_beta_hierarchical_varint.stan"))

sims.int <-
  sampling(
    sim.int,
    data = list(
      N = nrow(hypo_dataset),
      N_cluster = length(unique(hypo_dataset$cluster)),
      K = ncol(X),
      cluster = as.numeric(hypo_dataset$cluster),
      X = X,
      sigma_real = 2.25,
      phi_real = 200,
      beta_real = c(0, 1.5)
    ),
    iter = 1,
    warmup = 0,
    chains = 1,
    algorithm = c("Fixed_param"),
    seed=1687
  )



#Simulate data from above based on random slope only------------------------------

sim.slo <-
  stan_model(file = here("0-stanmodelcodes","sim_beta_hierarchical_varslope.stan"))

sims.slo <-
  sampling(
    sim.slo,
    data = list(
      N = nrow(hypo_dataset),
      N_cluster = length(unique(hypo_dataset$cluster)),
      K = ncol(X),
      cluster = as.numeric(hypo_dataset$cluster),
      X = X,
      sigma_real = 1,
      phi_real = 200,
      beta_real = c(0, 0)
    ),
    iter = 1,
    warmup = 0,
    chains = 1,
    algorithm = c("Fixed_param"),
    seed=1687
  )



#Simulate data from above based on both random int and slope------------------------------

sim.intslo <-
  stan_model(file = here("0-stanmodelcodes","sim_beta_hierarchical_varintslope.stan"))

sims.intslo <-
  sampling(
    sim.intslo,
    data = list(
      N = nrow(hypo_dataset),
      N_cluster = length(unique(hypo_dataset$cluster)),
      K = ncol(X),
      cluster = as.numeric(hypo_dataset$cluster),
      X = X,
      sigma_real = c(.75, .75),
      phi_real = 200,
      beta_real = c(0, 0)
    ),
    iter = 1,
    warmup = 0,
    chains = 1,
    algorithm = c("Fixed_param"),
    seed=1687
  )



#Extract_samples and calculate mean preds--------------------------------------------------

#int only
post.int <- extract(sims.int)

mu_int_cluster <- list()

for (i in 1:length(unique(hypo_dataset$cluster))) {
  mu_int_cluster[[i]] <-  sapply(pred.seq , function(pred)
    (inv_logit(
      (post.int$beta[1, 1] +  post.int$z_m[1, i] * post.int$sigma_m) +
        (post.int$beta[1, 2] * pred)
    )))
}


#slope only
post.slo <- extract(sims.slo)

mu_slo_cluster <- list()

for (i in 1:length(unique(hypo_dataset$cluster))) {
  mu_slo_cluster[[i]] <-  sapply(pred.seq , function(pred)
    (inv_logit((
      post.slo$beta[1, 1]  +
        ((
          post.slo$beta[1, 2] +  post.slo$z_m[1, i] * post.slo$sigma_m
        )) * pred
    ))))
  
}


#int and slope
post.intslo <- extract(sims.intslo)

mu_intslo_cluster <- list()

for (i in 1:length(unique(hypo_dataset$cluster))) {
  mu_intslo_cluster[[i]] <-  sapply(pred.seq , function(pred)
    (inv_logit(
      post.intslo$beta[1, 1]  +  post.intslo$z[, 1, i] +
        (post.intslo$beta[1, 2]  +  post.intslo$z[, 2, i]) * pred
    )))
}


#Plot hypo simulations-----------------------------------------------------------------
png(file = here("2-part2","figures","simulated_multi.png"),
    width = 2394,
    height = 3543)

par(
  mfrow = c(3, 1),
  lwd = 5,
  cex = 5,
  mar = c(4, 4, 2, 2),
  omi = c(0.2, 0.2, 0.2, 0.2)
)

plot(
  NULL,
  xlim = c(0, 6),
  ylim = c(0, 1),
  xlab = "Predictor",
  ylab = "Prop. of alloying const.",
  main = bquote(
    paste(
      "a) Varying intercept (",
      ~ beta[0], "=", 0,
      ~ beta[1], "=", 1.5,
      ~ sigma,"=",2.25,
      ")"
    )
  )
)

for (i in 1:20) {
  lines(pred.seq, y = mu_int_cluster[[i]])
}

plot(
  NULL,
  xlim = c(0, 6),
  ylim = c(0, 1),
  xlab = "Predictor",
  ylab = "Prop. of alloying const.",
  main = bquote(
    paste(
      "a) Varying slope (",
      ~ beta[0],"=",0,
      ~ beta[1],"=",0,
      ~ sigma,"=",1,
      ")"
    )
  )
)

for (i in 1:20) {
  lines(pred.seq, y = mu_slo_cluster[[i]])
}

plot(
  NULL,
  xlim = c(0, 6),
  ylim = c(0, 1),
  xlab = "Predictor",
  ylab = "Prop. of alloying const.",
  main = bquote(
    paste(
      "a) Varying intercept and slope (",
      ~ beta[0],"=",0,",",
      ~ beta[1],"=",0,
      ~ sigma[0],"=",0.75,
      ~ sigma[1],"=",0.75,
      ")"
    )
  )
)

for (i in 1:20) {
  lines(pred.seq, y = mu_intslo_cluster[[i]])
}

dev.off()
