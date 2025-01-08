##### Preparation #####

# import packages
rm(list=ls())
libs<-c("rstan", "stringr", "loo", "dplyr")
sapply(libs, require, character.only=TRUE)

###### define sample #####

sample <- 'n58' # n71, n53, n50

######

# activate these stan options -----------------------------------
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# only on windows:
Sys.setenv(LOCAL_CPPFLAGS = '-march=native')

#datapath<-"C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_CODE/Stan Modeling"
datapath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_DATA"
filepath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/WP2_ILT_CODE/02_Behav_and_Comp_Modeling"
#out_path<-'S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/Analysen/WP2_ILT/Stan Output'

# get model name
args <- commandArgs(trailingOnly = TRUE)
model_name <- args[1]
#model_name <- 'bandit2arm_delta_main_hierarchical'

## Prior predictive checks or fitting?
estimation = 1 # 0 = prior predictive check because likelihood is not evaluated; 1 = model fitting to real data

##### Read input #####
if (sample == 'n71') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n71.txt'), header = T)
} else if (sample == 'n56') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n56.txt'), header = T)
  fold<-read.table(file.path(datapath, 'Input/fold_for_CV_n56.txt'), header = F)
} else if (sample == 'n58') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n58.txt'), header = T)
  fold<-read.table(file.path(datapath, 'Input/fold_for_CV_n58.txt'), header = F)
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
  ntsub <- unlist(table(input_train$subjID,input_train$condition), use.names = F)
  
  ncond <- length(unique(input_train$condition))
  
  ntsub_non_na_jui <- c()
  ntsub_non_na_alc <- c()
  
  ## restructure choice and outcome data so that NAs are displayed at column end
  input_train_jui <- input_train[input_train$condition==0,]
  input_train_alc <- input_train[input_train$condition==1,]
  
  # choice juice
  choice_ntsub_jui <- as.data.frame(matrix(input_train_jui$choice,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
      choice_ntsub_non_na_jui <- na.omit(choice_ntsub_jui[,i]) # omit NAs
      ntsub_non_na_jui <- c(ntsub_non_na_jui,length(choice_ntsub_non_na_jui)) # count non-NA trials per subject
      choice_ntsub_non_na_as_list_jui <- as.list(choice_ntsub_non_na_jui) # transform choices without NAs to list
      pad_choice_jui <- ntsub[i,1]-length(choice_ntsub_non_na_as_list_jui) # number of missing trials per subject
      vec_pad_choice_jui <- rep(NA, pad_choice_jui) # create NA vector of length of missings
      padded_list_choice_jui <- append(choice_ntsub_non_na_as_list_jui, vec_pad_choice_jui) # pad non-NA trials and NA vector
      #print(choice_ntsub[,i])
      choice_ntsub_jui[,i] <- unlist(padded_list_choice_jui)
  }
  choice_ntsub_jui <- t(data.matrix(choice_ntsub_jui))
  choice_ntsub_jui[is.na(choice_ntsub_jui)] <- -999
  
  # choice alcohol
  choice_ntsub_alc <- as.data.frame(matrix(input_train_alc$choice,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
      choice_ntsub_non_na_alc <- na.omit(choice_ntsub_alc[,i]) # omit NAs
      ntsub_non_na_alc <- c(ntsub_non_na_alc,length(choice_ntsub_non_na_alc)) # count non-NA trials per subject
      choice_ntsub_non_na_as_list_alc <- as.list(choice_ntsub_non_na_alc) # transform choices without NAs to list
      pad_choice_alc <- ntsub[i,2]-length(choice_ntsub_non_na_as_list_alc) # number of missing trials per subject
      vec_pad_choice_alc <- rep(NA, pad_choice_alc) # create NA vector of length of missings
      padded_list_choice_alc <- append(choice_ntsub_non_na_as_list_alc, vec_pad_choice_alc) # pad non-NA trials and NA vector
      #print(choice_ntsub[,i])
      choice_ntsub_alc[,i] <- unlist(padded_list_choice_alc)
  }
  choice_ntsub_alc <- t(data.matrix(choice_ntsub_alc))
  choice_ntsub_alc[is.na(choice_ntsub_alc)] <- -999
  
  # combine
  choice_ntsub <- array(c(choice_ntsub_jui,choice_ntsub_alc), dim = c(nsub,50,2)) # choice
  ntsub_non_na <- cbind(matrix(t(ntsub_non_na_jui)),matrix(t(ntsub_non_na_alc)))# number of trials per subject
  
  # outcome juice
  outcome_ntsub_jui <- as.data.frame(matrix(input_train_jui$outcome,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
      outcome_ntsub_non_na_jui <- na.omit(outcome_ntsub_jui[,i]) # omit NAs
      outcome_ntsub_non_na_as_list_jui <- as.list(outcome_ntsub_non_na_jui) # transform choices without NAs to list
      pad_outcome_jui <- ntsub[i,1]-length(outcome_ntsub_non_na_as_list_jui) # number of missing trials per subject
      vec_pad_outcome_jui <- rep(NA, pad_outcome_jui) # create NA vector of length of missings
      padded_list_outcome_jui <- append(outcome_ntsub_non_na_as_list_jui, vec_pad_outcome_jui) # pad non-NA trials and NA vector
      #print(outcome_ntsub[,i])
      outcome_ntsub_jui[,i] <- unlist(padded_list_outcome_jui)
  }
  outcome_ntsub_jui <- t(data.matrix(outcome_ntsub_jui))
  outcome_ntsub_jui[is.na(outcome_ntsub_jui)] <- -999
  
  # outcome alcohol
  outcome_ntsub_alc <- as.data.frame(matrix(input_train_alc$outcome,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
      outcome_ntsub_non_na_alc <- na.omit(outcome_ntsub_alc[,i]) # omit NAs
      outcome_ntsub_non_na_as_list_alc <- as.list(outcome_ntsub_non_na_alc) # transform choices without NAs to list
      pad_outcome_alc <- ntsub[i,2]-length(outcome_ntsub_non_na_as_list_alc) # number of missing trials per subject
      vec_pad_outcome_alc <- rep(NA, pad_outcome_alc) # create NA vector of length of missings
      padded_list_outcome_alc <- append(outcome_ntsub_non_na_as_list_alc, vec_pad_outcome_alc) # pad non-NA trials and NA vector
      #print(outcome_ntsub[,i])
      outcome_ntsub_alc[,i] <- unlist(padded_list_outcome_alc)
  }
  outcome_ntsub_alc <- t(data.matrix(outcome_ntsub_alc))
  outcome_ntsub_alc[is.na(outcome_ntsub_alc)] <- -999
  
  # combine
  outcome_ntsub <- array(c(outcome_ntsub_jui,outcome_ntsub_alc), dim = c(nsub,50,2))
  
  ntmax <- ntsub[1,1]

  # subject- and visit-level variables
  num_subj_vars <- 1
  num_visit_vars <- 1
  if (sample != 'n60_aud' && sample != 'n60_hc' && sample != 'n56_hc' && sample != 'n56_aud') {
    df_aud_group <- input_train %>%
      group_by(subjID) %>%
      summarise_at(vars(group), list(group = mean), na.rm=F)
    aud_group <- array(data = c(unlist(df_aud_group$group)),
                       dim = c(nsub, num_subj_vars))
  }
  
  df_reinforcer_type_jui <- input_train_jui %>%
    group_by(subjID) %>%
    summarise_at(vars(condition), list(condition = mean), na.rm=F)
  df_reinforcer_type_alc <- input_train_alc %>%
    group_by(subjID) %>%
    summarise_at(vars(condition), list(condition = mean), na.rm=F)
  reinforcer_type <- array(data = c(unlist(df_reinforcer_type_jui$condition), unlist(df_reinforcer_type_alc$condition)),
                           dim = c(nsub, ncond, num_visit_vars))
  
  ##### stan input as named list ####
  
  stan_data_train <- list(
    N = nsub,
    C = ncond,
    T = nt,
    MT = ntmax,
    Tsubj = ntsub_non_na,
    choice = choice_ntsub,
    outcome = outcome_ntsub,
    kS = num_subj_vars, # number of subj-level variables (aud_group)
    subj_vars = aud_group,
    kV = num_visit_vars, # number of visit-level variables (reinforcer_type)
    visit_vars = reinforcer_type,
    run_estimation = estimation)
  
  ##### prepare test dataset ###################################################
  
  input_test <- input[input$fold == k,]
  
  nsub <- length(unique(input_test$subjID))
  nt <- length(input_test$trial)
  ntsub <- unlist(table(input_test$subjID,input_test$condition), use.names = F)
  
  ncond <- length(unique(input_test$condition))
  
  ntsub_non_na_jui <- c()
  ntsub_non_na_alc <- c()
  
  ## restructure choice and outcome data so that NAs are displayed at column end
  input_test_jui <- input_test[input_test$condition==0,]
  input_test_alc <- input_test[input_test$condition==1,]
  
  # choice juice
  choice_ntsub_jui <- as.data.frame(matrix(input_test_jui$choice,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
    choice_ntsub_non_na_jui <- na.omit(choice_ntsub_jui[,i]) # omit NAs
    ntsub_non_na_jui <- c(ntsub_non_na_jui,length(choice_ntsub_non_na_jui)) # count non-NA trials per subject
    choice_ntsub_non_na_as_list_jui <- as.list(choice_ntsub_non_na_jui) # transform choices without NAs to list
    pad_choice_jui <- ntsub[i,1]-length(choice_ntsub_non_na_as_list_jui) # number of missing trials per subject
    vec_pad_choice_jui <- rep(NA, pad_choice_jui) # create NA vector of length of missings
    padded_list_choice_jui <- append(choice_ntsub_non_na_as_list_jui, vec_pad_choice_jui) # pad non-NA trials and NA vector
    #print(choice_ntsub[,i])
    choice_ntsub_jui[,i] <- unlist(padded_list_choice_jui)
  }
  choice_ntsub_jui <- t(data.matrix(choice_ntsub_jui))
  choice_ntsub_jui[is.na(choice_ntsub_jui)] <- -999
  
  # choice alcohol
  choice_ntsub_alc <- as.data.frame(matrix(input_test_alc$choice,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
    choice_ntsub_non_na_alc <- na.omit(choice_ntsub_alc[,i]) # omit NAs
    ntsub_non_na_alc <- c(ntsub_non_na_alc,length(choice_ntsub_non_na_alc)) # count non-NA trials per subject
    choice_ntsub_non_na_as_list_alc <- as.list(choice_ntsub_non_na_alc) # transform choices without NAs to list
    pad_choice_alc <- ntsub[i,2]-length(choice_ntsub_non_na_as_list_alc) # number of missing trials per subject
    vec_pad_choice_alc <- rep(NA, pad_choice_alc) # create NA vector of length of missings
    padded_list_choice_alc <- append(choice_ntsub_non_na_as_list_alc, vec_pad_choice_alc) # pad non-NA trials and NA vector
    #print(choice_ntsub[,i])
    choice_ntsub_alc[,i] <- unlist(padded_list_choice_alc)
  }
  choice_ntsub_alc <- t(data.matrix(choice_ntsub_alc))
  choice_ntsub_alc[is.na(choice_ntsub_alc)] <- -999
  
  # combine
  choice_ntsub <- array(c(choice_ntsub_jui,choice_ntsub_alc), dim = c(nsub,50,2)) # choice
  ntsub_non_na <- cbind(matrix(t(ntsub_non_na_jui)),matrix(t(ntsub_non_na_alc)))# number of trials per subject
  
  # outcome juice
  outcome_ntsub_jui <- as.data.frame(matrix(input_test_jui$outcome,nrow=50,byrow = F))
  
  for (i in 1:nsub) {
    outcome_ntsub_non_na_jui <- na.omit(outcome_ntsub_jui[,i]) # omit NAs
    outcome_ntsub_non_na_as_list_jui <- as.list(outcome_ntsub_non_na_jui) # transform choices without NAs to list
    pad_outcome_jui <- ntsub[i,1]-length(outcome_ntsub_non_na_as_list_jui) # number of missing trials per subject
    vec_pad_outcome_jui <- rep(NA, pad_outcome_jui) # create NA vector of length of missings
    padded_list_outcome_jui <- append(outcome_ntsub_non_na_as_list_jui, vec_pad_outcome_jui) # pad non-NA trials and NA vector
    #print(outcome_ntsub[,i])
    outcome_ntsub_jui[,i] <- unlist(padded_list_outcome_jui)
  }
  outcome_ntsub_jui <- t(data.matrix(outcome_ntsub_jui))
  outcome_ntsub_jui[is.na(outcome_ntsub_jui)] <- -999
  
  # outcome alcohol
  outcome_ntsub_alc <- as.data.frame(matrix(input_test_alc$outcome,nrow=ntsub,byrow = F))
  
  for (i in 1:nsub) {
    outcome_ntsub_non_na_alc <- na.omit(outcome_ntsub_alc[,i]) # omit NAs
    outcome_ntsub_non_na_as_list_alc <- as.list(outcome_ntsub_non_na_alc) # transform choices without NAs to list
    pad_outcome_alc <- ntsub[i,2]-length(outcome_ntsub_non_na_as_list_alc) # number of missing trials per subject
    vec_pad_outcome_alc <- rep(NA, pad_outcome_alc) # create NA vector of length of missings
    padded_list_outcome_alc <- append(outcome_ntsub_non_na_as_list_alc, vec_pad_outcome_alc) # pad non-NA trials and NA vector
    #print(outcome_ntsub[,i])
    outcome_ntsub_alc[,i] <- unlist(padded_list_outcome_alc)
  }
  outcome_ntsub_alc <- t(data.matrix(outcome_ntsub_alc))
  outcome_ntsub_alc[is.na(outcome_ntsub_alc)] <- -999
  
  # combine
  outcome_ntsub <- array(c(outcome_ntsub_jui,outcome_ntsub_alc), dim = c(nsub,50,2))
  
  ntmax <- ntsub[1,1]
  
  # subject- and visit-level variables
  num_subj_vars <- 1
  num_visit_vars <- 1
  if (sample != 'n60_aud' && sample != 'n60_hc' && sample != 'n56_hc' && sample != 'n56_aud') {
    df_aud_group <- input_test %>%
      group_by(subjID) %>%
      summarise_at(vars(group), list(group = mean), na.rm=F)
    aud_group <- array(data = c(unlist(df_aud_group$group)),
                       dim = c(nsub, num_subj_vars))
  }
  
  df_reinforcer_type_jui <- input_test_jui %>%
    group_by(subjID) %>%
    summarise_at(vars(condition), list(condition = mean), na.rm=F)
  df_reinforcer_type_alc <- input_test_alc %>%
    group_by(subjID) %>%
    summarise_at(vars(condition), list(condition = mean), na.rm=F)
  reinforcer_type <- array(data = c(unlist(df_reinforcer_type_jui$condition), unlist(df_reinforcer_type_alc$condition)),
                           dim = c(nsub, ncond, num_visit_vars))
  
  ##### stan input as named list ####
  
  stan_data_test <- list(
    N = nsub,
    C = ncond,
    T = nt,
    MT = ntmax,
    Tsubj = ntsub_non_na,
    choice = choice_ntsub,
    outcome = outcome_ntsub,
    kS = num_subj_vars, # number of subj-level variables (aud_group)
    subj_vars = aud_group,
    kV = num_visit_vars, # number of visit-level variables (reinforcer_type)
    visit_vars = reinforcer_type,
    run_estimation = estimation)
  
  ##### Load Stan Model #####
  
  model_filename <- paste(model_name, ".stan", sep = "")
  stan_model <- stan_model(file = file.path(filepath, "Models", model_filename))
  #stanc(stan_model)
  
  ##### Fit Model on Train Data #####
  
  # Options
  s <- list(adapt_delta=0.9, stepsize=0.5)
  

  fit <- sampling(stan_model, data = stan_data_train, warmup = 1000, iter = 10000, chains = 4, verbose=TRUE, control=s)
  gen_test <- gqs(stan_model, draws = as.matrix(fit), data= stan_data_test)
  log_pd_kfold[, input$fold == k] <- extract_log_lik(gen_test, parameter_name = "log_lik")
  
} # fold

#elpd_kfold <- elpd(log_pd_kfold)

saveRDS(log_pd_kfold, file=file.path(filepath, 'Output', paste("log_pd_kfold_", model_name, "_", sample, ".rds", sep="")))
