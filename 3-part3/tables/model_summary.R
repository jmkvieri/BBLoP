#Load packages and data--------------------------------------------------------
library(rstan)
library(xtable)
library(here)

load(here("3-part3","model_outputs","aginau_model.RData"))

#extract posterior samples
post <- extract(fit_muisca_aginau_multi)

summary_post <- round(as.data.frame(summary(fit_muisca_aginau_multi, pars=c("beta","gamma", "sigma_mun"), probs = c(0.025, 0.25, 0.50, 0.75, 0.975))$summary),digits=2)
summary_post <- summary_post[,!names(summary_post) %in% c("se_mean")]
summary_post$n_eff <- round(summary_post$n_eff,digits=0)


write.csv(summary_post, here("3-part3","tables","summary_post.csv"))

xtable(summary_post)