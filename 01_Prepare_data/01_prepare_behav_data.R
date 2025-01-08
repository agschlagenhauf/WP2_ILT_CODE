### READ IN RAW BEHAVIORAL DATA AND CREATE ONE SINGLE DF ###
### MILENA MUSIAL 05/2023 ##################################

###### Preps ######

# clear
rm(list=ls())

libs<-c("tidyverse", "R.matlab", "stringr", "plyr", "dplyr")
#install.packages(libs)
sapply(libs, require, character.only=TRUE)

# define paths
redcap_path <- 'WP2_ILT_DATA/RedCap/'
data_path<-'WP2_ILT_DATA/Behav/raw/FilesReport_ILTdata_2023-05-24_1718/documents/'
behav_path <- 'WP2_ILT_DATA/Behav/'
input_path <- 'WP2_ILT_DATA/Input/'

# load redcap file to get final IDs
# load(file.path(redcap_path,"redcap_n71_new.RData"))

# subjects that should be excluded due to data collection errors
ID_excluded_data <- c(815,12240,12355,12390,12438,12564,12653,12885,12900,12956,12992,13065)

# define files

files<-list.files(data_path)
behav <- data.frame()

###### behav_final: combine all relevant vars of all subjects into a single df ######

# select vars
trial_vars<-c("a.side", "C", "rt", "R", "A", "MRI", "whichscanner", "ord", "subjn",
              "A", "vers.ord", "Drink.Type", "chosen.A", "chosen.J", "rating")

# loop across files
for (i in 1:length(files)) {
  
  list.t<-readMat(file.path(data_path, files[i], na.strings="", fsep = ""))
  
  subjn<-as.numeric(list.t[["subjn"]])
  
  if (! subjn %in% ID_excluded_data) { # check if ID among included IDs
  
    list.select<-list.t[c(trial_vars)] # select vars of interest
    
    # reformat vars
    a.side<-matrix(list.select[["a.side"]])
    A<-matrix(list.select[["A"]])
    C<-matrix(list.select[["C"]])
    R<-matrix(list.select[["R"]])
    rt<-matrix(list.select[["rt"]])
    ID<-matrix(rep(as.numeric(list.select[["subjn"]]), each=50))
    MRI<-matrix(rep(as.numeric(list.select[["whichscanner"]]), each=50))
    if (length(MRI) == 0) {                                               # if there's no 'whichscanner' variable
      MRI<-matrix(rep(as.numeric(list.select[["MRI"]]), each=50))
    }
    ord<-matrix(rep(as.numeric(list.select[["ord"]]), each=50))
    vers.ord<-matrix(rep(as.numeric(list.select[["vers.ord"]]), each=50))
    Drink.Type<-matrix(rep(c(list.select[["Drink.Type"]]), each=50))
    chosen.A<-matrix(rep(c(list.select[["chosen.A"]]), each=50))
    chosen.J<-matrix(rep(c(list.select[["chosen.J"]]), each=50))
    taste1<-matrix(rep(as.numeric(list.select[["rating"]][[1]]), each=50))
    crave1<-matrix(rep(as.numeric(list.select[["rating"]][[2]]), each=50))
    taste2<-matrix(rep(as.numeric(list.select[["rating"]][[3]]), each=50))
    crave2<-matrix(rep(as.numeric(list.select[["rating"]][[4]]), each=50))
    
    # combine all vars into df
    df.select<-data.frame(ID,A,a.side,C,R,rt,MRI,ord,vers.ord,Drink.Type,chosen.A,chosen.J,taste1,crave1,taste2,crave2)
    
    # bind single subject and block dfs to one big df
    behav<-rbind(behav, df.select)
    
  } # end if statement

} # end for loop

###### behav_final: format df ######

# renaming and formatting
behav_final <- behav %>%
  dplyr::rename(choice = A, 
         side = a.side, 
         correct = C,
         outcome = R, 
         scanner = MRI,
         ord_JA = ord,
         ord_AB = vers.ord,
         reinforcer_type = Drink.Type,
         chosen_A = chosen.A,
         chosen_J = chosen.J) %>% 
  mutate(ID = as_factor(ID),
         scanner = as_factor(scanner),
         ord_JA = factor(ord_JA, labels=c("J-A", 
                                          "A-J")),
         ord_AB = factor(ord_AB, labels=c("A-B", 
                                          "B-A")),
         reinforcer_type = as_factor(reinforcer_type),
         chosen_A = as_factor(chosen_A),
         chosen_J = as_factor(chosen_J),
         outcome = ifelse(outcome == -1, 0, 1)) # recode outcome (0=no reward, 1=reward)
         #correct = ifelse(correct==1, 2, 1)) # recode correct (2=correct card, 1=incorrect card)

# creating new vars
behav_final <- behav_final %>%
  mutate(block = factor(ifelse(ord_JA == "J-A" & reinforcer_type == "J" | # var coding block number
                                 ord_JA == "A-J" & reinforcer_type == "A", 1,2)), 
         ID_block = paste(ID, '00', block, sep = "")) %>% # var combining ID and block number
  mutate(trial_block = rep(c(1:50),times=142)) %>%
  mutate(trial_ID = rep(c(1:100),times=71)) %>%
  mutate(stay = ifelse(lag(choice)==choice,1,0)) %>% # var coding if participant repeated the choice from the previous trial
  mutate(stay = ifelse(trial_block==1,NA,stay)) %>%
  mutate(win_stay = ifelse(lag(choice)==choice&lag(outcome)==1,1,0)) %>% # var coding if participant repeated the choice from the previous trial if it was rewarded in previous trial
  mutate(win_stay = ifelse(trial_block==1|is.na(stay),NA,win_stay)) %>%
  mutate(nowin_switch = ifelse(lag(choice)!=choice&lag(outcome)==0,1,0)) %>% # var coding if participant switched the choice from the previous trial if it was not rewarded in previous trial
  mutate(nowin_switch = ifelse(trial_block==1|is.na(stay),NA,nowin_switch))

# sort
behav_final <- behav_final %>%
  arrange(ID,reinforcer_type)

# get n
n <- length(unique(behav_final$ID))

###### save behav df full sample (without data collection errors) ######

save(file=file.path(behav_path, paste("behav_final_n", n, ".RData", sep="")), behav_final)
write.table(behav_final, file=file.path(behav_path, paste("behav_final_n", n, ".txt", sep="")), append = FALSE, sep = " ", dec = ".",
            row.names = F, col.names = T)

###### exclude subjects based on performance ######

# get p correct per ID and block and trial
df_c_ID_block_trialbin <- behav_final %>%
  mutate(trial_bin = ntile(trial_block, n=5)) %>%
  group_by(ID,reinforcer_type,trial_bin) %>%
  summarise_at(vars(correct), list(p_correct = mean), na.rm=T) %>%
  mutate(trial_bin = as.factor(trial_bin))

df_c_ID_block_trialbin_wide <- pivot_wider(df_c_ID_block_trialbin, id_cols="ID", names_from = c(reinforcer_type, trial_bin), values_from = c(p_correct))

df_c_ID_block_trialbin_excl <- df_c_ID_block_trialbin[df_c_ID_block_trialbin$trial_bin==5&df_c_ID_block_trialbin$p_correct<=0.6,] # less than 61% correct in last 5 trials

ID_excl_correct <- c(unique(df_c_ID_block_trialbin_excl$ID))
length(ID_excl_correct)

behav_final <- filter(behav_final, !(ID %in% ID_excl_correct))

# get n
n <- length(unique(behav_final$ID))

###### save behav df behavioral sample ######

save(file=file.path(behav_path, paste("behav_final_n", n, ".RData", sep="")), behav_final)
write.table(behav_final, file=file.path(behav_path, paste("behav_final_n", n, ".txt", sep="")), append = FALSE, sep = " ", dec = ".",
            row.names = F, col.names = T)

###### exclude subjects based on fMRI movement parameters ######

ID_excl_move <- c(12343, 12654)

behav_final <- filter(behav_final, !(ID %in% ID_excl_move))

# get n
n <- length(unique(behav_final$ID))

###### save behav df mri sample ######

save(file=file.path(behav_path, paste("behav_final_n", n, ".RData", sep="")), behav_final)
write.table(behav_final, file=file.path(behav_path, paste("behav_final_n", n, ".txt", sep="")), append = FALSE, sep = " ", dec = ".",
            row.names = F, col.names = T)
