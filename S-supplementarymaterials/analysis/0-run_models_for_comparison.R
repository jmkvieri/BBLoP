#Load data and packages--------------------------------------------------------

library(rstan)
library(here)

load(here("3-part3","data","aginau_data.RData"))
load(here("3-part3","model_outputs","aginau_model.RData"))


#Run models for comparison-----------------------------------------------------


#create model matrix for predictors with both fixed and random effects
X_aginau  <- model.matrix(~ volume_std +
                            object_type,
                          data = data_aginau)


#pass data to stan
stan_data_aginau = list(
  N = length(data_aginau$aginau),
  K = ncol(X_aginau),
  N_mun = length(unique(data_aginau$combined)),
  mun = as.numeric(as.factor(data_aginau$combined)),
  y = data_aginau$aginau,
  X = X_aginau
)




#NON-HIERARCHICAL VAR DISP BETAREG

fit_muisca_aginau_beta_vardisp <-
  rstan::stan(
    file = "./0-stanmodelcodes/betareg_vardisp.stan",
    data = stan_data_aginau,
    warmup = 1000,
    iter = 3000,
    chains = 4,
    cores = 4,
    control = list(adapt_delta = 0.99,
                   max_treedepth = 11)
  )

#NON-HIERARCHICAL BETAREG WITHOUT VAR DISP

fit_muisca_aginau_beta_novardisp <-
  rstan::stan(
    file = "./0-stanmodelcodes/betareg.stan",
    data = stan_data_aginau,
    warmup = 1000,
    iter = 3000,
    chains = 4,
    cores = 4,
    control = list(adapt_delta = 0.99,
                   max_treedepth = 11)
  )



#save models

save(
  fit_muisca_aginau_beta_vardisp,
  file = here("S-supplementarymaterials","model_outputs","aginau_model1_for_comparison.RData")
)

save(
  fit_muisca_aginau_beta_novardisp,
  file = here("S-supplementarymaterials","model_outputs","aginau_model2_for_comparison.RData")
)

