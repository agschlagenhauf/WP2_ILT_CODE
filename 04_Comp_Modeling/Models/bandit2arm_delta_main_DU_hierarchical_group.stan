// MILENA MUSIAL 12/2023

// input
data {
  int<lower=1> N; // number of subjects
  int<lower=1> C; // number of visits
  int<lower=1> T; // total number of trials (observations) across subjects
  int<lower=1> MT; // max number of trials / subject / condition
  
  int<lower=1, upper=MT> Tsubj[N, C]; // actual number of trials / subject / condition
  
  int<lower=-999, upper=1> choice[N, MT, C]; // choice of correct (1) or incorrect (0) card / trial / subject / condition
  int<lower=-999, upper=1> outcome[N, MT, C];  // outcome / trial / subject / condition
  
  int kS; // number of subj-level predictors (aud_group)
  real subj_vars[N,kS]; //subj-level variable matrix - aud_group per subject
  int kV; // number of visit-level predictors (reinforcer_type)
  real visit_vars[N,C,kV]; //visit-level variable matrix (renforcer_type per subject and visit)
  
  int<lower = 0, upper = 1> run_estimation; // a switch to evaluate the likelihood
}

// transformed input 
transformed data {
  vector[2] initV;  // initial values for EV, both choices have a value of 0.5
  initV = rep_vector(0.5, 2);
}

// output - posterior distribution should be sought
parameters {
  
  // Declare all parameters as vectors for vectorizing
  // hyperparameters (group-level means)
  vector[2] mu; // fixed intercepts for the 4 parameters, for HC and juice (these are coded as 0)

  // Subject-level raw parameters (fixed slope of aud group)
  vector[kS] A_sub_m;    // learning rate
  vector[kS] tau_sub_m;  // inverse temperature
  
  //within subject SD (variance of random intercepts across subjects)
  real<lower=0> A_subj_s;
  real<lower=0> tau_subj_s;
  
  //non-centered parameterization effect on subj-level
  vector[N] A_subj_raw;
  vector[N] tau_subj_raw;
  
}

transformed parameters {
  
  // initialize condition-in-subject-level parameters
  matrix<lower=0, upper=1>[N,C] A; // bring alpha to range between 0 and 1
  matrix[N,C] A_normal; // raw alpha without range
  matrix<lower=0, upper=100>[N,C] tau; // bring tau to range between 0 and 100
  matrix[N,C] tau_normal; // tau without range
  
  //random intercepts per subject
  vector[N] A_vars = A_subj_s*A_subj_raw;
  vector[N] tau_vars = tau_subj_s*tau_subj_raw;
  
  // subject loop
  for (s in 1:N) {
    
    // condition loop
    for (v in 1:C) { // for every condition
      
      // fixed and random intercepts
      A_normal[s,v] = mu[1] + A_vars[s]; // fixed intercept + random intercept per subject
      tau_normal[s,v] = mu[2] + tau_vars[s];
      
      for (kv in 1:kV) { 
        
        for (ks in 1:kS) { 
          //fixed effects of subject-level variables
          A_normal[s,v] += subj_vars[s,ks]*A_sub_m[ks]; // predictor * fixed slope
          tau_normal[s,v] += subj_vars[s,ks]*tau_sub_m[ks];
          
        }
        
      }
    
    }
    
    //transform to range [0,1] or [0,100]
    A[s,] = Phi_approx(A_normal[s,]);
    tau[s,] = Phi_approx(tau_normal[s,])*100;
    
  }
  
}


model {
  
  // define prior distributions
  
  // hyperparameters (group-level means)
  mu ~ normal(0,1);
  
  // Subject-level raw parameters
  A_sub_m ~ normal(0,1);
  tau_sub_m ~ normal(0,1);
  
  //SDs of visit-level effects across subjects
  A_subj_s ~ cauchy(0,2);
  tau_subj_s ~ cauchy(0,2);
    
  //NCP variance effect on subj-level effects
  A_subj_raw ~ normal(0,1);
  tau_subj_raw ~ normal(0,1);
  
  // only execute this part if we want to evaluate likelihood (fit real data)
  if (run_estimation==1){

    // subject loop
    for (s in 1:N) {
      
      // define needed variables
      vector[2] ev; // expected value for both options
      real ev_chosen; // expected value of chosen choice
      vector[2] PE_fict; // prediction error for reward fictive updating (for unchosen options)
      real PE_chosen;      // prediction error
      
      // condition loop
      for (v in 1:C) {
        
        // set initial values
        ev = initV;
        ev_chosen = initV[1];
        
        // trial loop
        for (t in 1:Tsubj[s,v]) {
        
          // how does choice relate to inverse temperature and action value
          choice[s,t,v] ~ bernoulli_logit(tau[s,v] * (ev[2]-ev[1])); // inverse temp * Q
        
          // prediction error
          PE_chosen = outcome[s,t,v] - ev[choice[s,t,v]+1]; // outcome - Q of choice taken
          PE_fict = abs(outcome[s,t,v]-1) - ev; // opposite of outcome (0 if real outcome 1, 1 if real outcme 0) - Q of chosen and unchosen cards
          
          // store chosen Q value before updating
          ev_chosen = ev[choice[s,t,v]+1];
        
          // First, update Q for all cards w/ fictive updating
          ev += A[s,v] * PE_fict;
        
          // value updating (learning)
          ev[choice[s,t,v]+1] = ev_chosen + A[s,v] * PE_chosen; // Q + dynamic alpha * PE                                                                                    
      
        }
        
      }
    
    }
  
  }
  
}

generated quantities {
  
  // Define mean group-level parameter values
  real<lower=0, upper=1> mu_A; // initialize mean of posterior
  real<lower=0, upper=100> mu_tau;

  // For log likelihood calculation
  real log_lik[N,MT,C];
  real log_lik_s_b[N,C];
  real log_lik_s[N];
  
  // for choice propability calculation (of chosen option)
  real softmax_ev_chosen[N,MT,C];

  // For posterior predictive check
  int y_pred[N,MT,C];
  
  // extracting PEs per subject and trial
  real PE_pred[N,MT,C,2];
  real PE_chosen_pred[N,MT,C];
  
  // extracting q values per subject and trial
  real ev_pred[N,MT,C,2];
  real ev_chosen_pred[N,MT,C];

  // Set all PE and ev predictions to -999 (avoids NULL values)
  for (s in 1:N) {
    log_lik_s[s] = -999;
    for (v in 1:C) {
      log_lik_s_b[s,v] = -999;
      for (t in 1:MT) {
        y_pred[s,t,v] = -999;
        PE_chosen_pred[s,t,v] = -999;
        ev_chosen_pred[s,t,v] = -999;
        softmax_ev_chosen[s,t,v] = -999;
        log_lik[s,t,v] = -999;
        for (c in 1:2) {
          ev_pred[s,t,v,c] = -999;
          PE_pred[s,t,v,c] = -999;
        }
      }
    }
  }
  
  // calculate fixed intercepts of parameters
  mu_A   = Phi_approx(mu[1]); 
  mu_tau = Phi_approx(mu[2]) * 100;

  { // local section, this saves time and space
    for (s in 1:N) {
      
      vector[2] ev; // expected value
      real ev_chosen;
      vector[2] PE_fict; // prediction error
      real PE_chosen;
      vector[2] softmax_ev; // softmax per ev
      
      log_lik_s[s] = 0;

      for (v in 1:C) {
        
        // initialize values
        ev = initV;
        log_lik_s_b[s,v] = 0;
      
        // quantities of interest
        for (t in 1:Tsubj[s,v]) {
          
          // generate prediction for current trial
          // if estimation = 1, we draw from the posterior
          // if estimation = 0, we equally draw from the posterior, but the posterior is equal to the prior as likelihood is not evaluated
          y_pred[s,t,v] = bernoulli_logit_rng(tau[s,v] * (ev[2]-ev[1])); // following the recommendation to use the same function as in model block but with rng ending
          
          // if estimation = 1, compute quantities of interest based on actual choices
          if (run_estimation==1){
            
            // compute log likelihood of current trial
            log_lik[s,t,v] = bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            log_lik_s_b[s,v] += bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            log_lik_s[s] += bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            
            // compute choice probability
            softmax_ev = softmax(tau[s,v]*ev);
            softmax_ev_chosen[s,t,v] = softmax_ev[choice[s,t,v]+1];
            
            // prediction error
            PE_fict = abs(outcome[s,t,v]-1) - ev; // opposite of outcome (0 if real outcome 1, 1 if real outcme 0) - Q of chosen and unchosen cards
            PE_chosen = outcome[s,t,v] - ev[choice[s,t,v]+1];
            
            PE_pred[s,t,v,1] = PE_fict[1]; // copy both RPEs into pred
            PE_pred[s,t,v,2] = PE_fict[2]; // copy both RPEs into pred
            PE_pred[s,t,v,choice[s,t,v]+1] = PE_chosen; // replace RPE for chosen option
            
            PE_chosen_pred[s,t,v] = PE_chosen; // save PEs of chosen option only
            
            // store chosen Q value
            ev_chosen = ev[choice[s,t,v]+1];
          
            // First, update Q for all cards w/ fictive updating
            ev += A[s,v] * PE_fict;
          
            // Replace Q values of chosen deck with correct values using stored values
            ev[choice[s,t,v]+1] = ev_chosen + A[s,v] * PE_chosen;                                                                                   //??? do we need to update Q-values separately per choice?
            
            ev_pred[s,t,v,1] = ev[1]; // copy both evs into pred
            ev_pred[s,t,v,2] = ev[2]; // copy both evs into pred
            
            ev_chosen_pred[s,t,v] = ev[choice[s,t,v]+1]; // save ev of chosen option only
          
          }
        
          // if estimation = 0, compute quantities of interest based on simulated choices
          if (run_estimation==0){
          
            // compute log likelihood of current trial
            log_lik[s,t,v] = bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            log_lik_s_b[s,v] += bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            log_lik_s[s] += bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
          
            // prediction error
            PE_fict = abs(outcome[s,t,v]-1) - ev; // opposite of outcome (0 if real outcome 1, 1 if real outcme 0) - Q of chosen and unchosen cards
            PE_chosen = outcome[s,t,v] - ev[y_pred[s,t,v]+1];
            
            PE_pred[s,t,v,1] = PE_fict[1]; // copy both RPEs into pred
            PE_pred[s,t,v,2] = PE_fict[2]; // copy both RPEs into pred
            PE_pred[s,t,v,y_pred[s,t,v]+1] = PE_chosen; // replace RPE for chosen option
            
            PE_chosen_pred[s,t,v] = PE_chosen; // save PEs of chosen option only
            
            // store chosen Q value
            ev_chosen = ev[y_pred[s,t,v]+1];
          
            // First, update Q for all cards w/ fictive updating
            ev += A[s,v] * PE_fict;
          
            // Replace Q values of chosen deck with correct values using stored values
            ev[y_pred[s,t,v]+1] = ev_chosen + A[s,v] * PE_chosen;                                                                                   //??? do we need to update Q-values separately per choice?
            
            ev_pred[s,t,v,1] = ev[1]; // copy both evs into pred
            ev_pred[s,t,v,2] = ev[2]; // copy both evs into pred
            
            ev_chosen_pred[s,t,v] = ev[y_pred[s,t,v]+1]; // save ev of chosen option only
          
          }
        
        } // trial loop
    
      } // condition loop
  
    } // subject loop

  } // local section
  
} // generated quiantities
