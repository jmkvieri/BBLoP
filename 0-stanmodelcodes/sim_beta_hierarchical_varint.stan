data {
  int<lower=1> N;                        // sample size
  int<lower=1> N_cluster;               // number of clusters
  int<lower=1> K;                        // K predictors
  int cluster[N];                        // cluster id
  matrix[N,K] X;                         // predictor matrix
  real<lower=0> sigma_real;              // fixed sigma
  real<lower=0> phi_real;                // fixed phi
  vector[K] beta_real;                   // fixed reg coef
}

model {
}

generated quantities {
  vector[K] beta;                       // reg coefficient hyper-priors
  vector[N_cluster] z_m;                // vector of intercepts
  real<lower=0> sigma_m;               // sd for intercept
  real<lower=0> phi;                   // population phi
  vector[N] mu;                        // mean prediction
  vector[N] y_rep;                     // simulated outcome
  
  sigma_m = sigma_real;
  phi = phi_real;
  beta = beta_real;
  
  // for non-centered parameterisation
  for (i in 1:N_cluster) {
    z_m[i] = normal_rng(0,1);
  }
  
  
  //linear function
  for (i in 1:N) {
    mu[i] = inv_logit(X[i] * beta + z_m[cluster[i]]*sigma_m);
  }
  
  
  for (i in 1:N) { 
    real mu_new;
    
    mu_new = inv_logit(X[i] * beta + z_m[cluster[i]]*sigma_m);
    
    y_rep[i] = beta_rng(mu_new * phi, (1.0 - mu_new) * phi); 
  }
}
