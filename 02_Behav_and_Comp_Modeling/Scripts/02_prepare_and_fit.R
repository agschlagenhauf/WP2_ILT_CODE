##### Preparation #####

# import packages
rm(list=ls())
libs<-c("rstan", "stringr")
sapply(libs, require, character.only=TRUE)

###### define sample #####

sample <- 'n58' # n71, n53, n50

## Prior predictive checks or fitting?
estimation = 1 # 0 = prior predictive check because likelihood is not evaluated; 1 = model fitting to real data

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

##### Read input #####
if (sample == 'n71') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n71.txt'), header = T)
} else if (sample == 'n63') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n63.txt'), header = T)
} else if (sample == 'n60') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n60.txt'), header = T)
} else if (sample == 'n56') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n56.txt'), header = T)
} else if (sample == 'n58') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n58.txt'), header = T)
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

nsub <- length(unique(input$subjID))
nt <- length(input$trial)
ntsub <- unlist(table(input$subjID), use.names = F)

ntsub_non_na <- c()

# restructure choice and outcome data so that NAs are displayed at column end
choice_ntsub <- as.data.frame(matrix(input$choice,nrow=ntsub,byrow = F))
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

outcome_ntsub <- as.data.frame(matrix(input$outcome,nrow=ntsub,byrow = F))
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
stan_data <- list(N = nsub, 
                  T = nt,
                  MT = ntmax,
                  Tsubj = ntsub_non_na,
                  choice = choice_ntsub,
                  outcome = outcome_ntsub,
                  run_estimation = estimation) # 0 = prior predictive check because likelihood is not evaluated; 1 = model fitting to real data

input_filename <- paste("stan_data_", model_name, "_", sample, ".RData", sep="")
save(file=file.path(datapath, "Input", input_filename), stan_data)

##### Load Stan Model #####

model_filename <- paste(model_name, ".stan", sep = "")
stan_model<- file.path(filepath, "Models", model_filename)
stanc(stan_model)


##### Fit Model #####

# Options
s <- list(adapt_delta=0.999, stepsize=0.1)

# Fit
fit <- stan(file = stan_model, data = stan_data, warmup =1000, iter = 10000, chains = 4, verbose=TRUE, control=s)


##### Save fitted object as RDS #####
output_filename <- paste("fit_", sample ,'_', Sys.Date(), '_', model_name, '_estimation', estimation, '_delta', s$adapt_delta, '_stepsize', s$stepsize, ".rds", sep="")
saveRDS(fit, file=file.path(filepath, "Output", output_filename))

