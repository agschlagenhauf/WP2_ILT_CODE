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
  
  int kV; // number of visit-level predictors (reinforcer_type)
  real visit_vars[N,C,kV]; //visit-level variable matrix (centered) (renforcer_type per subject and visit)
  
  int<lower = 0, upper = 1> run_estimation; // a switch to evaluate the likelihood
}

// transformed input 
transformed data {
  vector[2] initV;  // initial values for EV, both choices have a value of 0.5
  initV = rep_vector(0.5, 2);
  real initabsPE;
  initabsPE = 0.5; /// 
  real initAlpha;
  initAlpha = 0.5;
}

// output - posterior distribution should be sought
parameters {
  
  // Declare all parameters as vectors for vectorizing
  // hyperparameters (group-level means)
  vector[3] mu_jui; // fixed intercepts for the 4 parameters, for HC and juice (these are coded as 0)
  vector[3] mu_alc; // fixed intercepts for the 4 parameters, for HC and juice (these are coded as 0)
  
  //variance of random intercepts across subjects
  real<lower=0> tau_subj_s;
  real<lower=0> gamma_subj_s;
  real<lower=0> C_subj_s;
  
  //non-centered parameterization effect on subj-level
  vector[N] tau_subj_raw_alc;
  vector[N] gamma_subj_raw_alc;
  vector[N] C_subj_raw_alc;
  
  vector[N] tau_subj_raw_jui;
  vector[N] gamma_subj_raw_jui;
  vector[N] C_subj_raw_jui;
  
}

transformed parameters {
  
  // initialize condition-in-subject-level parameters
  vector<lower=0, upper=100>[N] tau_alc; // bring tau to range between 0 and 100
  vector[N] tau_normal_alc; // tau without range
  vector<lower=0, upper=1>[N] gamma_alc; // bring gamma to range between 0 and 1
  vector[N] gamma_normal_alc; // gamma without range
  vector<lower=0, upper=1>[N] C_const_alc; // bring C to range between 0 and 1
  vector[N] C_normal_alc; // C without range
  
  vector<lower=0, upper=100>[N] tau_jui; // bring tau to range between 0 and 100
  vector[N] tau_normal_jui; // tau without range
  vector<lower=0, upper=1>[N] gamma_jui; // bring gamma to range between 0 and 1
  vector[N] gamma_normal_jui; // gamma without range
  vector<lower=0, upper=1>[N] C_const_jui; // bring C to range between 0 and 1
  vector[N] C_normal_jui; // C without range

  //random intercepts per subject
  vector[N] tau_vars_alc = tau_subj_s*tau_subj_raw_alc;
  vector[N] gamma_vars_alc = gamma_subj_s*gamma_subj_raw_alc;
  vector[N] C_vars_alc = C_subj_s*C_subj_raw_alc;
  
  vector[N] tau_vars_jui = tau_subj_s*tau_subj_raw_jui;
  vector[N] gamma_vars_jui = gamma_subj_s*gamma_subj_raw_jui;
  vector[N] C_vars_jui = C_subj_s*C_subj_raw_jui;
  
  // subject loop
  for (s in 1:N) {
    
    // condition loop
    for (v in 1:C) { // for every condition
      
          // fixed and random intercepts
          tau_normal_jui[s] = mu_jui[2] + tau_vars_jui[s];
          gamma_normal_jui[s] = mu_jui[3] + gamma_vars_jui[s];
          C_normal_jui[s] = mu_jui[4] + C_vars_jui[s];
          
          //transform to range [0,1] or [0,100]
          tau_jui[s] = Phi_approx(tau_normal_jui[s])*100;
          gamma_jui[s] = Phi_approx(gamma_normal_jui[s]);
          C_const_jui[s] = Phi_approx(C_normal_jui[s]);
          
          // fixed and random intercepts
          tau_normal_alc[s] = mu_alc[2] + tau_vars_alc[s];
          gamma_normal_alc[s] = mu_alc[3] + gamma_vars_alc[s];
          C_normal_alc[s] = mu_alc[4] + C_vars_alc[s];
          
          //transform to range [0,1] or [0,100]
          tau_alc[s] = Phi_approx(tau_normal_alc[s])*100;
          gamma_alc[s] = Phi_approx(gamma_normal_alc[s]);
          C_const_alc[s] = Phi_approx(C_normal_alc[s]);

    }

  }
  
}


model {
  
  // define prior distributions
  
  // hyperparameters (group-level means)
  mu_jui ~ normal(0, 1);
  mu_alc ~ normal(0, 1);
  
  //SDs of visit-level effects across subjects
  tau_subj_s ~ cauchy(0,2);
  gamma_subj_s ~ cauchy(0,2);
  C_subj_s ~ cauchy(0,2);
    
  //NCP variance effect on subj-level effects
  tau_subj_raw_jui ~ normal(0,1);
  gamma_subj_raw_jui ~ normal(0,1);
  C_subj_raw_jui ~ normal(0,1);
    
  tau_subj_raw_alc ~ normal(0,1);
  gamma_subj_raw_alc ~ normal(0,1);
  C_subj_raw_alc ~ normal(0,1);
  
  // only execute this part if we want to evaluate likelihood (fit real data)
  if (run_estimation==1){

    // subject loop
    for (s in 1:N) {
      
      // define needed variables
      vector[2] ev; // expected value for both options
      real PE;      // prediction error
      real absPE; // absolute prediction error
      real k; // learning rate per trial
    
      // condition loop
      for (v in 1:C) {
        
        // set initial values
        ev = initV;
        absPE = initabsPE;
        k = initAlpha;
        
        if (v == 1) {
          
            // trial loop
            for (t in 1:Tsubj[s,v]) {
            
              // how does choice relate to inverse temperature and action value
              choice[s,t,v] ~ bernoulli_logit(tau_jui[s] * (ev[2]-ev[1])); // inverse temp * Q
              
              // Pearce Hall learning rate
              k = gamma_jui[s]*C_const_jui[s]*absPE + (1-gamma_jui[s])*k; // decay constant * arbitrary constant * absolute PE from last trial + (1-decay constant) * learning rate from last trial
                                                        // if decay constant close to 1: dynamic learning rate will be strongly affected by PEs from last trial and only weakly affected by learning rate from previous trial (high fluctuation)
                                                        // if decay constant close to 0: dynamic learning rate will be weakly affected by PEs from last trial and strongly affected by learning rate from previous trial (low fluctuation)
    
            
              // prediction error
              PE = outcome[s,t,v] - ev[choice[s,t,v]+1]; // outcome - Q of choice taken
              absPE = abs(PE);
              
              // value updating (learning)
              ev[choice[s,t,v]+1] += k * PE; // Q + dynamic alpha * PE
              
            }
      
        } else if (v == 2) {
          
            // trial loop
            for (t in 1:Tsubj[s,v]) {
            
              // how does choice relate to inverse temperature and action value
              choice[s,t,v] ~ bernoulli_logit(tau_alc[s] * (ev[2]-ev[1])); // inverse temp * Q
              
              // Pearce Hall learning rate
              k = gamma_alc[s]*C_const_alc[s]*absPE + (1-gamma_alc[s])*k; // decay constant * arbitrary constant * absolute PE from last trial + (1-decay constant) * learning rate from last trial
                                                        // if decay constant close to 1: dynamic learning rate will be strongly affected by PEs from last trial and only weakly affected by learning rate from previous trial (high fluctuation)
                                                        // if decay constant close to 0: dynamic learning rate will be weakly affected by PEs from last trial and strongly affected by learning rate from previous trial (low fluctuation)
    
            
              // prediction error
              PE = outcome[s,t,v] - ev[choice[s,t,v]+1]; // outcome - Q of choice taken
              absPE = abs(PE);
              
              // value updating (learning)
              ev[choice[s,t,v]+1] += k * PE; // Q + dynamic alpha * PE                                                                                    
      
            } // trial loop
      
          } // if loop
    
        } // condition loop
  
      } // subject loop
  
    } // run estimation loop

} // model block

generated quantities {
  
  // Define mean group-level parameter values
  real<lower=0, upper=100> mu_tau_jui;
  real<lower=0, upper=1> mu_gamma_jui;
  real<lower=0, upper=1> mu_C_jui;
  
  real<lower=0, upper=100> mu_tau_alc;
  real<lower=0, upper=1> mu_gamma_alc;
  real<lower=0, upper=1> mu_C_alc;

  // For log likelihood calculation
  real log_lik[N,MT,C];
  real log_lik_s_b[N,C];
  real log_lik_s[N];
  
  // for choice propability calculation (of chosen option)
  real softmax_ev_chosen[N,MT,C];

  // For posterior predictive check
  int y_pred[N,MT,C];
  
  // extracting PEs per subject and trial
  real PE_pred[N,MT,C];
  
  // extracting q values per subject and trial
  real ev_pred[N,MT,C,2];
  real ev_chosen_pred[N,MT,C];
  
  // extracting dynamic learning rate per subject and trial
  real k_pred[N,MT,C];

  // Set all PE and ev predictions to -999 (avoids NULL values)
  for (s in 1:N) {
    log_lik_s[s] = -999;
    for (v in 1:C) {
      log_lik_s_b[s,v] = -999;
      for (t in 1:MT) {
        y_pred[s,t,v] = -999;
        PE_pred[s,t,v] = -999;
        ev_chosen_pred[s,t,v] = -999;
        k_pred[s,t,v] = -999;
        softmax_ev_chosen[s,t,v] = -999;
        log_lik[s,t,v] = -999;
        for (c in 1:2) {
          ev_pred[s,t,v,c] = -999;
        }
      }
    }
  }
  
  // calculate fixed intercepts of parameters
  mu_tau_jui = Phi_approx(mu_jui[2]) * 100;
  mu_gamma_jui   = Phi_approx(mu_jui[3]);
  mu_C_jui   = Phi_approx(mu_jui[4]);
  
  mu_tau_alc = Phi_approx(mu_alc[2]) * 100;
  mu_gamma_alc   = Phi_approx(mu_alc[3]);
  mu_C_alc   = Phi_approx(mu_alc[4]);

  { // local section, this saves time and space
    for (s in 1:N) {
      
      vector[2] ev; // expected value
      real PE;      // prediction error
      real absPE; // absolute prediction error
      real k; // learning rate
      vector[2] softmax_ev; // softmax per ev
      
      log_lik_s[s] = 0;

      for (v in 1:C) {
        
        // initialize values
        ev = initV;
        absPE = initabsPE;
        k = initAlpha;
        log_lik_s_b[s,v] = 0;
        
        if (v == 1) {
          
          // quantities of interest
          for (t in 1:Tsubj[s,v]) {
            
            // generate prediction for current trial
            // if estimation = 1, we draw from the posterior
            // if estimation = 0, we equally draw from the posterior, but the posterior is equal to the prior as likelihood is not evaluated
            y_pred[s,t,v] = bernoulli_logit_rng(tau_jui[s] * (ev[2]-ev[1])); // following the recommendation to use the same function as in model block but with rng ending
            
            // if estimation = 1, compute quantities of interest based on actual choices
            if (run_estimation==1){
              
              // compute log likelihood of current trial
              log_lik[s,t,v] = bernoulli_logit_lpmf(choice[s,t,v] | tau_jui[s] * (ev[2]-ev[1]));
              log_lik_s_b[s,v] += bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
              log_lik_s[s] += bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
              
              // compute choice probability
              softmax_ev = softmax(tau_jui[s]*ev);
              
              softmax_ev_chosen[s,t,v] = softmax_ev[choice[s,t,v]+1];
              
              // Pearce Hall learning rate
              k = gamma_jui[s]*C_const_jui[s]*absPE + (1-gamma_jui[s])*k;
              k_pred[s,t,v] = k;
              
              // prediction error
              PE = outcome[s,t,v] - ev[choice[s,t,v]+1];
              PE_pred[s,t,v] = PE;
              
              // value updating (learning)
              ev[choice[s,t,v]+1] += k * PE;
              
              ev_pred[s,t,v,1] = ev[1]; // copy both evs into pred
              ev_pred[s,t,v,2] = ev[2]; // copy both evs into pred
              
              ev_chosen_pred[s,t,v] = ev[choice[s,t,v]+1];
          
          }
        
          // if estimation = 0, compute quantities of interest based on simulated choices
          if (run_estimation==0){
          
            // compute log likelihood of current trial
            log_lik[s,t,v] = bernoulli_logit_lpmf(y_pred[s,t,v] | tau_jui[s] * (ev[2]-ev[1]));
            log_lik_s_b[s,v] += bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            log_lik_s[s] += bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
          
            // Pearce Hall learning rate
            k = gamma_jui[s]*C_const_jui[s]*absPE + (1-gamma_jui[s])*k;
            k_pred[s,t,v] = k;
            
            // prediction error
            PE = outcome[s,t,v] - ev[y_pred[s,t,v]+1];
            PE_pred[s,t,v] = PE;
            
            // value updating (learning)
            ev[y_pred[s,t,v]+1] += k * PE;
          
            ev_pred[s,t,v,1] = ev[1]; // copy both evs into pred
            ev_pred[s,t,v,2] = ev[2]; // copy both evs into pred
            
            ev_chosen_pred[s,t,v] = ev[y_pred[s,t,v]+1];
          
          }
        
        } // trial loop
        
       } else if (v == 2) {
         
          // quantities of interest
          for (t in 1:Tsubj[s,v]) {
            
            // generate prediction for current trial
            // if estimation = 1, we draw from the posterior
            // if estimation = 0, we equally draw from the posterior, but the posterior is equal to the prior as likelihood is not evaluated
            y_pred[s,t,v] = bernoulli_logit_rng(tau_alc[s] * (ev[2]-ev[1])); // following the recommendation to use the same function as in model block but with rng ending
            
            // if estimation = 1, compute quantities of interest based on actual choices
            if (run_estimation==1){
              
              // compute log likelihood of current trial
              log_lik[s,t,v] = bernoulli_logit_lpmf(choice[s,t,v] | tau_alc[s] * (ev[2]-ev[1]));
              log_lik_s_b[s,v] += bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
              log_lik_s[s] += bernoulli_logit_lpmf(choice[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
              
              // compute choice probability
              softmax_ev = softmax(tau_alc[s]*ev);
              
              softmax_ev_chosen[s,t,v] = softmax_ev[choice[s,t,v]+1];
              
              // Pearce Hall learning rate
              k = gamma_alc[s]*C_const_alc[s]*absPE + (1-gamma_alc[s])*k;
              k_pred[s,t,v] = k;
              
              // prediction error
              PE = outcome[s,t,v] - ev[choice[s,t,v]+1];
              PE_pred[s,t,v] = PE;
              
              // value updating (learning)
              ev[choice[s,t,v]+1] += k * PE;
              
              ev_pred[s,t,v,1] = ev[1]; // copy both evs into pred
              ev_pred[s,t,v,2] = ev[2]; // copy both evs into pred
              
              ev_chosen_pred[s,t,v] = ev[choice[s,t,v]+1];
          
          }
        
          // if estimation = 0, compute quantities of interest based on simulated choices
          if (run_estimation==0){
          
            // compute log likelihood of current trial
            log_lik[s,t,v] = bernoulli_logit_lpmf(y_pred[s,t,v] | tau_alc[s] * (ev[2]-ev[1]));
            log_lik_s_b[s,v] += bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
            log_lik_s[s] += bernoulli_logit_lpmf(y_pred[s,t,v] | tau[s,v] * (ev[2]-ev[1]));
          
            // Pearce Hall learning rate
            k = gamma_alc[s]*C_const_alc[s]*absPE + (1-gamma_alc[s])*k;
            k_pred[s,t,v] = k;
            
            // prediction error
            PE = outcome[s,t,v] - ev[y_pred[s,t,v]+1];
            PE_pred[s,t,v] = PE;
            
            // value updating (learning)
            ev[y_pred[s,t,v]+1] += k * PE;
          
            ev_pred[s,t,v,1] = ev[1]; // copy both evs into pred
            ev_pred[s,t,v,2] = ev[2]; // copy both evs into pred
            
            ev_chosen_pred[s,t,v] = ev[y_pred[s,t,v]+1];
          
          }
          
        } // trial loop
        
       } // if loop
    
      } // condition loop
  
    } // subject loop

  } // local section
  
} // generated quiantities
