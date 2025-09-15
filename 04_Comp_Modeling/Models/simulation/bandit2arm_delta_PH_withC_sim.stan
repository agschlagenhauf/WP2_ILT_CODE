// MILENA MUSIAL 12/2023

// input
data {
  int<lower=1> N; // subjects
  int<lower=1> T; // total number of trials across subjects
  int<lower=1> MT; // max number of trials / subject
  int<lower=1, upper=MT> Tsubj[N]; // actual number of trials / subject
  //int<lower=-999, upper=2> choice[N, MT]; // choice of correct (1) or incorrect (0) card
  int<lower=-999, upper=1> outcome[N, MT];  // outcome 
  //int<lower = 0, upper = 1> run_estimation; // a switch to evaluate the likelihood
  
  // Hyper(group)-parameters
  vector[4] mu_pr; // group level means for the 4 parameters
  vector<lower=0>[4] sigma; // group level variance for the 4 parameters

  // Subject-level raw parameters (for Matt trick - efficient way of sampling)
  vector[N] A_pr;    // initial learning rate
  vector[N] tau_pr;  // inverse temperature
  vector[N] gamma_pr; // decay constant
  vector[N] C_pr; // arbitrary constant
}

// transformed input 
transformed data {
  
  vector[2] initV;  // initial values for EV, both choices have a value of 0.5
  initV = rep_vector(0.5, 2); // set initial Q value to 0.5 (middle btw. 0 and 1)
  real initabsPE;
  initabsPE = 0.5;
}

generated quantities {
  
  // For posterior predictive check
  int y_pred[N,MT];
  
  // subject-level parameters
  vector<lower=0, upper=1>[N] A; // bring alpha to range between 0 and 1
  vector<lower=0, upper=100>[N] tau; // bring tau to range between 0 and 20
  vector<lower=0, upper=1>[N] gamma; // bring gamma to range between 0 and 1 (as in Theresas code)
  vector<lower=0, upper=1>[N] C; // arbitrary constant 
  
  // For group level parameters
  real<lower=0, upper=1> mu_A; // initialize mean of posterior
  real<lower=0, upper=100> mu_tau;
  real<lower=0, upper=1> mu_gamma;
  real<lower=0, upper=1> mu_C;
  
  // Set all PE, ev, A and choice predictions to -999 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:MT) {
      y_pred[i, t] = -999;
    }
  }
  
  { // local section, this saves time and space
  
    // compute subject-level parameters: group mean per parameter + individual subject parameter * group level variance
    for (i in 1:N) { // subject loop
      A[i]   = Phi_approx(mu_pr[1]  + sigma[1]  * A_pr[i]);
      tau[i] = Phi_approx(mu_pr[2] + sigma[2] * tau_pr[i]) * 100;
      gamma[i] = Phi_approx(mu_pr[3] + sigma[3] * gamma_pr[i]);
      C[i] = Phi_approx(mu_pr[4]  + sigma[4]  * C_pr[i]);
    }
    
    // calculate mean of posterior
    mu_A = Phi_approx(mu_pr[1]);
    mu_tau = Phi_approx(mu_pr[2]) * 100; 
    mu_gamma = Phi_approx(mu_pr[3]); 
    mu_C = Phi_approx(mu_pr[4]);// times 10 as same done for tau?
  
    for (i in 1:N) {
      vector[2] ev; // expected value
      real PE;      // prediction error
      real absPE; // absolute prediction error
      real k; // learning rate
      vector[2] softmax_ev; // softmax per ev

      // initialize values
      ev = initV;
      absPE = initabsPE;
      k = A[i];
      
      // quantities of interest
      for (t in 1:Tsubj[i]) {
        
        // generate posterior prediction for current trial
        y_pred[i,t] = bernoulli_logit_rng(tau[i] * (ev[2]-ev[1])); // following the recommendation to use the same function as in model block but with rng ending
          
        // Pearce Hall learning rate
        k = gamma[i]*C[i]*absPE + (1-gamma[i])*k;
          
        // prediction error
        PE = outcome[i,t] - ev[y_pred[i,t]+1];
          
        // value updating (learning)
        ev[y_pred[i,t]+1] += k * PE;
        
      }
    
    }
  
  }

}

