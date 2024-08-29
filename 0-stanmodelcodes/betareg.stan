data {
  int<lower=1> N;                 // sample size
  int<lower=1> K;                 // K predictors
  matrix[N, K] X;                 // predictor matrix
  vector<lower=0, upper=1>[N] y; // compositional response 
}


parameters {
  vector[K] beta;                   // reg coefficients for mu
  real<lower=0> phi;                // precision of beta dist    
}


model {
  vector[N] mu;                        // mean of beta dist
  vector[N] p;                         // shape parameter for beta dist
  vector[N] q;                         // shape parameter for beta dist
  
  
  //LINEAR FUNCTION
  for (i in 1:N) { 
    mu[i] = inv_logit(X[i] * beta); 
    p[i] = mu[i] * phi;
    q[i] = (1.0 - mu[i]) * phi;
  }
  
  //PRIORS  
  beta[1] ~ normal(0, 1.5);
  beta[2:K] ~ normal(0, 1);
  phi ~ uniform(0,500);
  
  
  // LIKELIHOOD
  y ~ beta(p, q);
}


generated quantities {
  vector[N] mu_rep;
  vector[N] y_rep;
  vector[N] log_lik;
  
  for (i in 1 : N) {
    real mu_new;
    
    mu_new = inv_logit(X[i] * beta);
    
    y_rep[i] = beta_rng(mu_new * phi, (1.0 - mu_new) * phi);
    mu_rep[i] = inv_logit(X[i] * beta);
    
    log_lik[i] = beta_lpdf(y[i] | mu_new * phi, (1.0 - mu_new) * phi);
    
  }
}
