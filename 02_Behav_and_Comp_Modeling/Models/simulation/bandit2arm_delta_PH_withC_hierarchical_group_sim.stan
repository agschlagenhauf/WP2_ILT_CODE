// MILENA MUSIAL 12/2023

// input
data {
  int<lower=1> N; // number of subjects
  int<lower=1> C; // number of visits
  int<lower=1> T; // total number of trials (observations) across subjects
  int<lower=1> MT; // max number of trials / subject / condition
  
  int<lower=1, upper=MT> Tsubj[N, C]; // actual number of trials / subject / condition
  
  //int<lower=-999, upper=1> choice[N, MT, C]; // choice of correct (1) or incorrect (0) card / trial / subject / condition
  int<lower=-999, upper=1> outcome[N, MT, C];  // outcome / trial / subject / condition
  
  int kS; // number of subj-level predictors (aud_group)
  real subj_vars[N,kS]; //subj-level variable matrix - aud_group per subject
  int kV; // number of visit-level predictors (reinforcer_type)
  real visit_vars[N,C,kV]; //visit-level variable matrix (renforcer_type per subject and visit)
  
  // Declare all parameters as vectors for vectorizing
  // hyperparameters (group-level means)
  vector[4] mu; // fixed intercepts for the 4 parameters, for HC and juice (these are coded as 0)

  // Subject-level raw parameters (fixed slope of aud group)
  vector[kS] A_sub_m;    // learning rate
  vector[kS] tau_sub_m;  // inverse temperature
  vector[kS] gamma_sub_m; // decay constant
  vector[kS] C_sub_m; // arbitrary constant
  
  //within subject SD (variance of random intercepts across subjects)
  real<lower=0> A_subj_s;
  real<lower=0> tau_subj_s;
  real<lower=0> gamma_subj_s;
  real<lower=0> C_subj_s;
  
  //non-centered parameterization effect on subj-level
  vector[N] A_subj_raw;
  vector[N] tau_subj_raw;
  vector[N] gamma_subj_raw;
  vector[N] C_subj_raw;
  
}

// transformed input 
transformed data {
  
  vector[2] initV;  // initial values for EV, both choices have a value of 0.5
  initV = rep_vector(0.5, 2);
  real initabsPE;
  initabsPE = 0.5;
  
}

generated quantities {
  
  // For posterior predictive check
  int y_pred[N,MT,C];
  
  // condition-in-subject-level parameters
  matrix<lower=0, upper=1>[N,C] A; // bring alpha to range between 0 and 1
  matrix[N,C] A_normal; // raw alpha without range
  matrix<lower=0, upper=100>[N,C] tau; // bring tau to range between 0 and 100
  matrix[N,C] tau_normal; // tau without range
  matrix<lower=0, upper=1>[N,C] gamma; // bring gamma to range between 0 and 1
  matrix[N,C] gamma_normal; // gamma without range
  matrix<lower=0, upper=1>[N,C] C_const; // bring C to range between 0 and 1
  matrix[N,C] C_normal; // C without range
  
  // Define mean group-level parameter values
  real<lower=0, upper=1> mu_A; // initialize mean of posterior
  real<lower=0, upper=100> mu_tau;
  real<lower=0, upper=1> mu_gamma;
  real<lower=0, upper=1> mu_C;

  // Set all PE and ev predictions to -999 (avoids NULL values)
  for (s in 1:N) {
    for (v in 1:C) {
      for (t in 1:MT) {
        y_pred[s,t,v] = -999;
      }
    }
  }

  { // local section, this saves time and space
  
    //random intercepts per subject
    vector[N] A_vars = A_subj_s*A_subj_raw;
    vector[N] tau_vars = tau_subj_s*tau_subj_raw;
    vector[N] gamma_vars = gamma_subj_s*gamma_subj_raw;
    vector[N] C_vars = C_subj_s*C_subj_raw;
    
    // subject loop linear mixed model
    for (s in 1:N) {
      
      // condition loop
      for (v in 1:C) { // for every condition
        
        // fixed and random intercepts
        A_normal[s,v] = mu[1] + A_vars[s]; // fixed intercept + random intercept per subject
        tau_normal[s,v] = mu[2] + tau_vars[s];
        gamma_normal[s,v] = mu[3] + gamma_vars[s];
        C_normal[s,v] = mu[4] + C_vars[s];
        
        for (kv in 1:kV) { 
          
          for (ks in 1:kS) { 
            //fixed effects of subject-level variables
            A_normal[s,v] += subj_vars[s,ks]*A_sub_m[ks]; // predictor * fixed slope
            tau_normal[s,v] += subj_vars[s,ks]*tau_sub_m[ks];
            gamma_normal[s,v] += subj_vars[s,ks]*gamma_sub_m[ks];
            C_normal[s,v] += subj_vars[s,ks]*C_sub_m[ks];
            
          }
          
        }
      
      }
      
      //transform to range [0,1] or [0,100]
      A[s,] = Phi_approx(A_normal[s,]);
      tau[s,] = Phi_approx(tau_normal[s,])*100;
      gamma[s,] = Phi_approx(gamma_normal[s,]);
      C_const[s,] = Phi_approx(C_normal[s,]);
  
    }
    
    // calculate fixed intercepts of parameters
    mu_A   = Phi_approx(mu[1]); 
    mu_tau = Phi_approx(mu[2]) * 100;
    mu_gamma   = Phi_approx(mu[3]);
    mu_C   = Phi_approx(mu[4]);
    
    // subject loop RL part   
    for (s in 1:N) {
      
      vector[2] ev; // expected value
      real PE;      // prediction error
      real absPE; // absolute prediction error
      real k; // learning rate

      for (v in 1:C) {
        
        // initialize values
        ev = initV;
        absPE = initabsPE;
        k = A[s,v];
        
        // quantities of interest
        for (t in 1:Tsubj[s,v]) {
          
          // generate prediction for current trial
          // if estimation = 1, we draw from the posterior
          // if estimation = 0, we equally draw from the posterior, but the posterior is equal to the prior as likelihood is not evaluated
          y_pred[s,t,v] = bernoulli_logit_rng(tau[s,v] * (ev[2]-ev[1])); // following the recommendation to use the same function as in model block but with rng ending
          
          // Pearce Hall learning rate
          k = gamma[s,v]*C_const[s,v]*absPE + (1-gamma[s,v])*k;
          
          // prediction error
          PE = outcome[s,t,v] - ev[y_pred[s,t,v]+1];
          
          // value updating (learning)
          ev[y_pred[s,t,v]+1] += k * PE;
        
        } // trial loop
    
      } // condition loop
  
    } // subject loop

  } // local section
  
} // generated quiantities
