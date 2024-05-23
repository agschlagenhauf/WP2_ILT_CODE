##### Preparation #####

# import packages
rm(list=ls())
libs<-c("rstan", "stringr")
sapply(libs, require, character.only=TRUE)

# activate these stan options -----------------------------------
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# only on windows:
Sys.setenv(LOCAL_CPPFLAGS = '-march=native')

datapath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_DATA"
out_path <- '/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/WP2_ILT_CODE/02_Behav_and_Comp_Modeling/'

#########
sample <- 'n58'

# set estimation for stan data 
estimation <- 1

# get model name
args <- commandArgs(trailingOnly = TRUE)
model_name <- args[1] # which model should be fitted to data (simulation model code)?
model_name
input_fit_rds <- args[2] # which fit object should be used as input (mean parameter estimates)?
input_fit_rds

##### Read input #####

# load real input
if (model_name == 'bandit2arm_delta_PH_withC_sim') {
  load(file.path(datapath,"Input/stan_data_bandit2arm_delta_PH_withC_n58.RData")) # Behav and redcap data
} else if (model_name == 'bandit2arm_delta_PH_withC_hierarchical_group_sim') {
  load(file.path(datapath,"Input/stan_data_bandit2arm_delta_PH_withC_hierarchical_group_n58.RData")) # Behav and redcap data
}

# load fit object 
fit <- readRDS(file.path(out_path, 'Output', input_fit_rds))

# load posterior means as input for simulation
if (model_name == 'bandit2arm_delta_PH_withC_sim') {
  # extract posterior means for all parameters to use them as input for simulation
  mu_pr_postmean <- as.vector(summary(fit, pars="mu_pr")$summary[, c("mean")]) 
  sigma_postmean <- as.vector(summary(fit, pars="sigma")$summary[, c("mean")]) 
  A_pr_postmean <- as.vector(summary(fit, pars="A_pr")$summary[, c("mean")]) 
  tau_pr_postmean <- as.vector(summary(fit, pars="tau_pr")$summary[, c("mean")]) 
  gamma_pr_postmean <- as.vector(summary(fit, pars="gamma_pr")$summary[, c("mean")]) 
  C_pr_postmean <- as.vector(summary(fit, pars="C_pr")$summary[, c("mean")]) 
} else if (model_name == 'bandit2arm_delta_PH_withC_hierarchical_group_sim') {
  mu_postmean <- as.vector(summary(fit, pars="mu")$summary[, c("mean")]) 
  A_sub_m_postmean <- as.vector(summary(fit, pars="A_sub_m")$summary[, c("mean")]) 
  tau_sub_m_postmean <- as.vector(summary(fit, pars="tau_sub_m")$summary[, c("mean")]) 
  gamma_sub_m_postmean <- as.vector(summary(fit, pars="gamma_sub_m")$summary[, c("mean")]) 
  C_sub_m_postmean <- as.vector(summary(fit, pars="C_sub_m")$summary[, c("mean")])
  A_subj_s_postmean <- as.vector(summary(fit, pars="A_subj_s")$summary[, c("mean")]) 
  tau_subj_s_postmean <- as.vector(summary(fit, pars="tau_subj_s")$summary[, c("mean")])
  gamma_subj_s_postmean <- as.vector(summary(fit, pars="gamma_subj_s")$summary[, c("mean")])
  C_subj_s_postmean <- as.vector(summary(fit, pars="C_subj_s")$summary[, c("mean")])
  A_subj_raw_postmean <- as.vector(summary(fit, pars="A_subj_raw")$summary[, c("mean")])
  tau_subj_raw_postmean <- as.vector(summary(fit, pars="tau_subj_raw")$summary[, c("mean")])
  gamma_subj_raw_postmean <- as.vector(summary(fit, pars="gamma_subj_raw")$summary[, c("mean")])
  C_subj_raw_postmean <- as.vector(summary(fit, pars="C_subj_raw")$summary[, c("mean")])
}

##### Load Stan Model #####

model_filename <- paste(model_name, ".stan", sep = "")
stan_model<- file.path(out_path, "Models", "simulation", model_filename)
stanc(stan_model)

##### Fitting #####
  
# stan input as named list
if (model_name == 'bandit2arm_delta_PH_withC_sim') {
  sim_data <- list(N = stan_data$N, 
                   T = stan_data$T,
                   MT = stan_data$MT,
                   Tsubj = stan_data$Tsubj,
                   outcome = stan_data$outcome,
                   mu_pr = mu_pr_postmean,
                   sigma = sigma_postmean,
                   A_pr = A_pr_postmean,
                   tau_pr = tau_pr_postmean,
                   gamma_pr = gamma_pr_postmean,
                   C_pr = C_pr_postmean)
} else if (model_name == 'bandit2arm_delta_PH_withC_hierarchical_group_sim') {
  sim_data <- list(N = stan_data$N,
                   C = stan_data$C,
                   T = stan_data$T,
                   MT = stan_data$MT,
                   Tsubj = stan_data$Tsubj,
                   outcome = stan_data$outcome,
                   kS = stan_data$kS, # number of subj-level variables (aud_group)
                   subj_vars = stan_data$subj_vars,
                   kV = stan_data$kV, # number of visit-level variables (reinforcer_type)
                   visit_vars = stan_data$visit_vars,
                   mu = mu_postmean,
                   A_sub_m = array(A_sub_m_postmean),
                   tau_sub_m = array(tau_sub_m_postmean),
                   gamma_sub_m = array(gamma_sub_m_postmean),
                   C_sub_m = array(C_sub_m_postmean),
                   A_subj_s = A_subj_s_postmean,
                   tau_subj_s = tau_subj_s_postmean,
                   gamma_subj_s = gamma_subj_s_postmean,
                   C_subj_s = C_subj_s_postmean,
                   A_subj_raw = array(A_subj_raw_postmean),
                   tau_subj_raw = array(tau_subj_raw_postmean),
                   gamma_subj_raw = array(gamma_subj_raw_postmean),
                   C_subj_raw = array(C_subj_raw_postmean))
}

# Options
if (model_name == 'bandit2arm_delta_PH_withC_sim') {
  s <- list(adapt_delta=0.999, stepsize=0.1, max_treedepth=12)
} else if (model_name == 'bandit2arm_delta_PH_withC_hierarchical_group_sim') {
  s <- list(adapt_delta=0.9, stepsize=0.5)
}  

# Fit
fit <- stan(file = stan_model, 
            data = sim_data, 
            iter = 1, 
            chains = 1, 
            algorithm = "Fixed_param",
            verbose = TRUE, 
            control = s)

# Save fitted object as RDS

output_filename <- paste("sim_", Sys.Date(), '_', model_name, "_", sample, ".rds", sep="")
saveRDS(fit, file=file.path(out_path, "Output/Parameter_Recovery", output_filename))
