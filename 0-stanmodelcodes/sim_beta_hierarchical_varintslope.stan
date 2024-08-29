data {
  int<lower=1> N;                       // sample size
  int<lower=1> N_cluster;               // number of clusters
  int<lower=1> K;                      // K predictors
  int cluster[N];                      // cluster id
  matrix[N,K] X;                       // predictor matrix
  vector[K] sigma_real;               // fixed sigma
  real<lower=0> phi_real;             // fixed phi
  vector[K] beta_real;                // fixed reg coef
}

model {
}

generated quantities {
  vector[K] beta;                     // reg coefficient hyper-priors
  
  matrix[K,N_cluster] z_m;            // matrix of intercepts and slopes (non-centered)
  matrix[K,N_cluster] z;              // matrix of intercepts and slopes
  vector<lower=0>[K] sigma_m;         // sd for intercept and slope
  cholesky_factor_corr[K] L_m;        // correlation matrix
  
  real<lower=0> phi;                   // population phi
  vector[N] mu;                        // transformed
  vector[N] y_rep;

  sigma_m = sigma_real;
  phi = phi_real;
  beta = beta_real;
  L_m = lkj_corr_cholesky_rng(2, 0.2); // for simulating corr between ints and slopes
  
  for (i in 1:K) {
    for (j in 1:N_cluster) {
        z_m[i, j] = normal_rng(0,1);
    }
  }
  
  z = diag_pre_multiply(sigma_m,L_m)*z_m;
  
  //linear function
  for (i in 1:N) {
  mu[i] = inv_logit(X[i,] * (beta + z[,cluster[i]]) );
  }

  for (i in 1:N) { 
    real mu_new;
      
    mu_new = inv_logit(X[i,] * (beta + z[,cluster[i]]) );
    
    y_rep[i] = beta_rng(mu_new * phi, (1.0 - mu_new) * phi); 
  }
}
