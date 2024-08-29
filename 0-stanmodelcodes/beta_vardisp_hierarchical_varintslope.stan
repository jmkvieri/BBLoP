data {
  int<lower=1> N;                 // sample size
  int<lower=1> N_mun;             // number of clusters (municipalities)
  array[N] int mun;               // municipality id
  int<lower=1> K;                 // K predictors fixed and varying effects
  matrix[N, K] X;                 // predictor matrix fixed and varying effects
  vector<lower=0, upper=1>[N] y;  // response 
}

parameters {
  vector[K] beta;                 // reg coefficient hyper-priors for mu
  vector[K] z_m[N_mun];           // non-centered
  vector<lower=0>[K] sigma_mun;   // sd for intercept and slopes
  cholesky_factor_corr[K] L_m;   // correlation matrix for int and slopes
  vector[K] gamma;               // reg coefficients (fixed) for phi
}

transformed parameters {
  
  vector[K] beta_mun[N_mun];            // matrix of intercepts and slopes
  
  for (n in 1:N_mun) {
    beta_mun[n] = diag_pre_multiply(sigma_mun, L_m) * z_m[n];
  }
  
}


model {
  vector[N] mu;                        // mean of beta dist
  vector[N] phi;                       // precision of peta dist
  vector[N] p;                         // shape parameter for beta dist
  vector[N] q;                         // shape parameter for beta dist
  
  
  //LINEAR FUNCTIONS
  for (i in 1:N) { 
    mu[i] = inv_logit(X[i,] * (beta + beta_mun[mun[i]])); 
    phi[i] = exp(X[i] * gamma);
    p[i] = mu[i] * phi[i];
    q[i] = (1.0 - mu[i]) * phi[i];
  }
  
  
  // PRIORS
  beta[1] ~ normal(0, 1.5);
  beta[2:K] ~ normal(0, 1);
  gamma ~ normal(0, 2);
  sigma_mun ~ normal(0, 1);
  L_m ~ lkj_corr_cholesky(2);
  
  for (n in 1:N_mun){
    
    z_m[n] ~ std_normal();
    
  }
  
  // LIKELIHOOD
  y ~ beta(p, q);
}


generated quantities {
  vector[N] y_rep;
  vector[N] log_lik;
  vector[N] mu_rep;
  
  for (i in 1 : N) {
    real mu_new;
    real phi_new;
    
    mu_new = inv_logit(X[i,] * (beta +  beta_mun[mun[i]])); 
    phi_new = exp(X[i] * gamma);
    
    mu_rep[i] =  inv_logit(X[i,] * (beta + beta_mun[mun[i]]));
    y_rep[i] = beta_rng(mu_new * phi_new, (1.0 - mu_new) * phi_new);
    
    log_lik[i] = beta_lpdf(y[i] | mu_new * phi_new, (1.0 - mu_new) * phi_new);
    
  }
  
}
