##### Preparation #####

# import packages
rm(list=ls())
libs<-c("rstan", "stringr", "loo")
sapply(libs, require, character.only=TRUE)

###### define sample #####

sample <- 'n56' # n71, n53, n50

######

# activate these stan options -----------------------------------
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# only on windows:
Sys.setenv(LOCAL_CPPFLAGS = '-march=native')

#datapath<-"C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_CODE/Stan Modeling"
datapath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_DATA"
filepath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_Stan_Modeling"
#out_path<-'S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/Analysen/WP2_ILT/Stan Output'

# get model name
args <- commandArgs(trailingOnly = TRUE)
model_name <- args[1]
#model_name <- 'bandit2arm_delta_main_hierarchical'

## Prior predictive checks or fitting?
estimation = 1 # 0 = prior predictive check because likelihood is not evaluated; 1 = model fitting to real data

##### Read input #####
if (sample == 'n71') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n71.txt'), header = T)
} else if (sample == 'n63') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n63.txt'), header = T)
} else if (sample == 'n60') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n60.txt'), header = T)
} else if (sample == 'n56') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n56.txt'), header = T)
  fold<-read.table(file.path(datapath, 'Input/fold_for_CV_n56.txt'), header = F)
} else if (sample == 'n53') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n53.txt'), header = T)
} else if (sample == 'n50') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n50.txt'), header = T)
} else if (sample == 'n60_aud') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_aud_n60.txt'), header = T)
} else if (sample == 'n60_hc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hc_n60.txt'), header = T)
} else if (sample == 'n56_aud') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_aud_n56.txt'), header = T)
} else if (sample == 'n56_hc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hc_n56.txt'), header = T)
} else if (sample == 'n56_aud_jui') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_jui_aud_n56.txt'), header = T)
} else if (sample == 'n56_hc_jui') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_jui_hc_n56.txt'), header = T)
} else if (sample == 'n56_aud_alc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_alc_aud_n56.txt'), header = T)
} else if (sample == 'n56_hc_alc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_alc_hc_n56.txt'), header = T)
}

##### split data into 10 folds #####
input$fold <- fold

# Prepare a matrix with the number of post-warmup iterations by number of observations:
log_pd_kfold <- matrix(nrow = 36000, ncol = nrow(input))

##### fold loop #####

for (k in 1:10) {
  
  ##### prepare train dataset ##################################################
  
  input_train <- input[input$fold != k,]

  nsub <- length(unique(input_train$subjID))
  nt <- length(input_train$trial)
  ntsub <- unlist(table(input_train$subjID), use.names = F)
  
  ntsub_non_na <- c()
  
  # restructure choice and outcome data so that NAs are displayed at column end
  choice_ntsub <- as.data.frame(matrix(input_train$choice,nrow=ntsub,byrow = F))
  for (i in 1:nsub) {
    choice_ntsub_non_na <- na.omit(choice_ntsub[,i])
    ntsub_non_na <- c(ntsub_non_na,length(choice_ntsub_non_na))
    choice_ntsub_non_na_as_list <- as.list(choice_ntsub_non_na)
    pad_choice <- ntsub[i]-length(choice_ntsub_non_na_as_list)
    vec_pad_choice <- rep(NA, pad_choice)
    padded_list_choice <- append(choice_ntsub_non_na_as_list, vec_pad_choice)
    #print(choice_ntsub[,i])
    choice_ntsub[,i] <- unlist(padded_list_choice)
  }
  choice_ntsub <- t(data.matrix(choice_ntsub))
  choice_ntsub[is.na(choice_ntsub)] <- -999
  
  outcome_ntsub <- as.data.frame(matrix(input_train$outcome,nrow=ntsub,byrow = F))
  for (i in 1:nsub) {
    outcome_ntsub_non_na <- na.omit(outcome_ntsub[,i])
    outcome_ntsub_non_na_as_list <- as.list(outcome_ntsub_non_na)
    pad_outcome <- ntsub[i]-length(outcome_ntsub_non_na_as_list)
    vec_pad_outcome <- rep(NA, pad_outcome)
    padded_list_outcome <- append(outcome_ntsub_non_na_as_list, vec_pad_outcome)
    #print(outcome_ntsub[,i])
    outcome_ntsub[,i] <- unlist(padded_list_outcome)
  }
  outcome_ntsub <- t(data.matrix(outcome_ntsub))
  outcome_ntsub[is.na(outcome_ntsub)] <- -999
  
  ntmax <- length(padded_list_choice)
  ntsub <- as.numeric(ntsub)
  
  # stan input as named list
  stan_data_train <-  list(N = nsub, 
                      T = nt,
                      MT = ntmax,
                      Tsubj = ntsub_non_na,
                      choice = choice_ntsub,
                      outcome = outcome_ntsub,
                      run_estimation = estimation) # 0 = prior predictive check because likelihood is not evaluated; 1 = model fitting to real data
  
  ##### prepare test dataset ###################################################
  
  input_test <- input[input$fold == k,]
  
  nsub <- length(unique(input_test$subjID))
  nt <- length(input_test$trial)
  ntsub <- unlist(table(input_test$subjID), use.names = F)
  
  ntsub_non_na <- c()
  
  # restructure choice and outcome data so that NAs are displayed at column end
  choice_ntsub <- as.data.frame(matrix(input_test$choice,nrow=ntsub,byrow = F))
  for (i in 1:nsub) {
    choice_ntsub_non_na <- na.omit(choice_ntsub[,i])
    ntsub_non_na <- c(ntsub_non_na,length(choice_ntsub_non_na))
    choice_ntsub_non_na_as_list <- as.list(choice_ntsub_non_na)
    pad_choice <- ntsub[i]-length(choice_ntsub_non_na_as_list)
    vec_pad_choice <- rep(NA, pad_choice)
    padded_list_choice <- append(choice_ntsub_non_na_as_list, vec_pad_choice)
    #print(choice_ntsub[,i])
    choice_ntsub[,i] <- unlist(padded_list_choice)
  }
  choice_ntsub <- t(data.matrix(choice_ntsub))
  choice_ntsub[is.na(choice_ntsub)] <- -999
  
  outcome_ntsub <- as.data.frame(matrix(input_test$outcome,nrow=ntsub,byrow = F))
  for (i in 1:nsub) {
    outcome_ntsub_non_na <- na.omit(outcome_ntsub[,i])
    outcome_ntsub_non_na_as_list <- as.list(outcome_ntsub_non_na)
    pad_outcome <- ntsub[i]-length(outcome_ntsub_non_na_as_list)
    vec_pad_outcome <- rep(NA, pad_outcome)
    padded_list_outcome <- append(outcome_ntsub_non_na_as_list, vec_pad_outcome)
    #print(outcome_ntsub[,i])
    outcome_ntsub[,i] <- unlist(padded_list_outcome)
  }
  outcome_ntsub <- t(data.matrix(outcome_ntsub))
  outcome_ntsub[is.na(outcome_ntsub)] <- -999
  
  ntmax <- length(padded_list_choice)
  ntsub <- as.numeric(ntsub)
  
  # stan input as named list
  stan_data_test <-  list(N = nsub, 
                          T = nt,
                          MT = ntmax,
                          Tsubj = ntsub_non_na,
                          choice = choice_ntsub,
                          outcome = outcome_ntsub,
                          run_estimation = estimation) # 0 = prior predictive check because likelihood is not evaluated; 1 = model fitting to real data
  
  
  ##### Load Stan Model #####
  
  model_filename <- paste(model_name, ".stan", sep = "")
  stan_model <- stan_model(file = file.path(filepath, "Models", model_filename))
  #stanc(stan_model)
  
  # Options
  s <- list(adapt_delta=0.99, stepsize=0.1)
  
  ##### Fit Model on Train Data #####

  fit <- sampling(stan_model, data = stan_data_train, warmup = 1000, iter = 10000, chains = 4, verbose=TRUE, control=s)
  gen_test <- gqs(stan_model, draws = as.matrix(fit), data= stan_data_test)
  log_pd_kfold[, input$fold == k] <- extract_log_lik(gen_test, parameter_name = "log_lik")
  
}

elpd_kfold <- elpd(log_pd_kfold)

save(file=file.path(filepath, 'Output', paste("elpd_kfold_", model_name, "_", sample, ".RData", sep="")), elpd_kfold)
