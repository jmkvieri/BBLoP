data {
  int<lower=1> N;                       // sample size
  int<lower=1> N_cluster;               // number of clusters
  int<lower=1> K;                       // K predictors
  int cluster[N];                       // cluster id
  matrix[N,K] X;                        // predictor matrix
  real<lower=0> sigma_real;             // fixed sigma
  real<lower=0> phi_real;               // fixed phi
  vector[K] beta_real;                  // fixed reg coef
}

model {
}

generated quantities {
  vector[K] beta;                       // reg coefficient hyper-priors
  vector[N_cluster] z_m;                // vector of slopes (non_centered)
  vector[N_cluster] z;                  // vector of slopes
  real<lower=0> sigma_m;               // sd for slope
  real<lower=0> phi;                   // population phi
  vector[N] mu;                        // mean prediction
  vector[N] y_rep;                    // simulated outcome

  sigma_m = sigma_real;
  phi = phi_real;
  beta = beta_real;
  
  // for non-centered parameterisation
  for (i in 1:N_cluster) {
  z_m[i] = normal_rng(0,1);
  }
  
  for (i in 1:N_cluster) {
  z[i] = z_m[i] * sigma_m;
  }
  
  //linear function
  for (i in 1:N) {
   mu[i] = inv_logit(beta[1] + (beta[2] + z[cluster[i]])*X[i,2]);
  }


  for (i in 1:N) { 
    real mu_new;
      
    mu_new = inv_logit(beta[1] + (beta[2] + z[cluster[i]])*X[i,2]);
    
    y_rep[i] = beta_rng(mu_new * phi, (1.0 - mu_new) * phi); 
  }
}
