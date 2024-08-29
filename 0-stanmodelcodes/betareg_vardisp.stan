data {
  int<lower=1> N;                 // sample size
  int<lower=1> K;                 // K predictors
  matrix[N, K] X;                 // predictor matrix
  vector<lower=0, upper=1>[N] y; // response 
}


parameters {
  vector[K] beta;          // reg coefficients for mu
  vector[K] gamma;         // reg coefficients for phi
  
}


model {
  vector[N] mu;                        // mean of beta dist
  vector[N] phi;                       // precision of beta dist
  vector[N] p;                         // shape parameter for beta dist
  vector[N] q;                         // shape parameter for beta dist
  
  
  //LINEAR FUNCTIONS
  for (i in 1:N) { 
    mu[i] = inv_logit(X[i] * beta); 
    phi[i] = exp(X[i] * gamma);
    p[i] = mu[i] * phi[i];
    q[i] = (1.0 - mu[i]) * phi[i];
  }
  
  //PRIORS  
  beta[1] ~ normal(0, 1.5);
  beta[2:K] ~ normal(0, 1);
  gamma ~ normal(0, 2);
  
  
  // LIKELIHOOD
  y ~ beta(p, q);
}


generated quantities {
  vector[N] mu_rep;
  vector[N] y_rep;
  vector[N] log_lik;
  
  for (i in 1 : N) {
    real mu_new;
    real phi_new;
    
    mu_new = inv_logit(X[i] * beta);
    phi_new = exp(X[i] * gamma);
    
    y_rep[i] = beta_rng(mu_new * phi_new, (1.0 - mu_new) * phi_new);
    mu_rep[i] = inv_logit(X[i] * beta);
    
    log_lik[i] = beta_lpdf(y[i] | mu_new * phi_new, (1.0 - mu_new) * phi_new);
    
  }
}
