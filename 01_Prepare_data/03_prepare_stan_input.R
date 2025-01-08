# create Stan dfs

###### Preps ######

rm(list=ls())
#install.packages(c('tidyverse', 'stringr', 'dplyr', 'mice', 'naniar'))
libs<-c("tidyverse", "dplyr")
sapply(libs, require, character.only=TRUE)

# define paths
behav_path <- 'WP2_ILT_DATA/Behav/'
stan_path <- 'WP2_ILT_DATA/Input/'

###### sample n71 ######

for (sample in c("n71", "n58", "n56")) {
  
  # load behav files
  load(file.path(behav_path, paste("behav_final_redcap_", sample, ".RData", sep = ""), na.strings="", fsep = ""))
  
  # n 
  n <- length(unique(behav_final_redcap$ID))
  
  ###### create and save full sample Stan dfs ######
  
  # main model
  stan_input <- behav_final_redcap %>%
    select(ID_block,trial_block,correct,outcome) #%>%
  
  stan_input[is.na(stan_input)]<- NA
  
  write.table(stan_input, file=file.path(stan_path, paste('Stan_input_n', n, '.txt', sep="")), append = FALSE, sep = " ", dec = ".",
              row.names = F, col.names = c("subjID","trial","choice","outcome"))
  
  # hierarchical model
  stan_input_hie <- behav_final_redcap %>%
    select(ID,trial_block,aud_group,reinforcer_type,correct,outcome) %>%
    mutate(aud_group = ifelse(aud_group == 'AUD',1,0), # AUD=1,HC=0
           reinforcer_type = ifelse(reinforcer_type == 'A',1,0)) # alc=1, jui=0
  
  stan_input_hie[is.na(stan_input_hie)]<- NA
  
  write.table(stan_input_hie, file=file.path(stan_path, paste('Stan_input_hierarchical_n', n, '.txt', sep="")), append = FALSE, sep = " ", dec = ".",
              row.names = F, col.names = c("subjID","trial","group","condition","choice","outcome"))
  
  
}

