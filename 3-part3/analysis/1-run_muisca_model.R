#Load data and packages--------------------------------------------------------
library(here)
library(rstan)

#use cleaned dataset produced by running "clean_data.R" in folder "./3-part3/data"

load(here("3-part3","data","cleaned_data.RData"))


#Pre-process data----------------------------------------------------------------------------

data_new <- muisca_data

#SUBSET DATA
#subset to XRF and pXRF for better cross-comparability
#and with recorded variables (volume, municipality, either votive figure or adornment) of interest
#exclude analyses above >0.85 Cu as these are unlikely to provide precise estimates of Ag-in-Au

data_new <-
  subset(
    data_new,
      data_new$method %in% c('XRF', 'pXRF') &
      data_new$cu_norm < 0.85 &
      !is.na(data_new$volume)  &
      !is.na(data_new$municipality) &
      data_new$object_type %in% c('Adornment', 'Votive figure')
  )


#scale data to take values on the whole of the unit interval (0,1), to avoid predictions
#above 40wt% Ag-in-Au, as such values are scientifically implausible

data_new$aginau <- data_new$aginau / 0.4

#drop unused levels after subsetting
data_new <- droplevels(data_new)


#standardise continuous variables for regression
data_new$volume_std <- scale(data_new$volume)


#order data alphabetically according to municipality of recovery
data_aginau <- data_new[order(data_new$combined), ]
rownames(data_aginau) <- 1:243


#save final dataset

save(
  data_aginau,
  file = here("3-part3","data","aginau_data.RData")
)




#create model matrix for predictors with both fixed and random effects
X_aginau  <- model.matrix(~ volume_std +
                            object_type,
                          data = data_aginau)



#RUN FINAL MODELS-----------------------------------------------------------------------------

#pass data to stan
stan_data_aginau = list(
  N = length(data_aginau$aginau),
  K = ncol(X_aginau),
  N_mun = length(unique(data_aginau$combined)),
  mun = as.numeric(as.factor(data_aginau$combined)),
  y = data_aginau$aginau,
  X = X_aginau
)


fit_muisca_aginau_multi <-
  rstan::stan(
    file = here("0-stanmodelcodes","beta_vardisp_hierarchical_varintslope.stan"),
    data = stan_data_aginau,
    warmup = 1000,
    iter = 3000,
    chains = 4,
    cores = 4,
    control = list(adapt_delta = 0.99,
                   max_treedepth = 11)
  )




#save final model

save(
  fit_muisca_aginau_multi,
  file = here("3-part3","model_outputs","aginau_model.RData")
)
