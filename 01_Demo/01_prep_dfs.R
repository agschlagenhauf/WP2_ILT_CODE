###### PREPARE DFS ######
###### Milena 11/2022 #####

rm(list=ls())
# install.packages('tidyverse', 'stringr', 'dplyr')
libs<-c("tidyverse", "stringr", "dplyr")
sapply(libs, require, character.only=TRUE)

###### define sample #####

sample <- 'n60' # n71, n53, n50

######

# define paths
data_path<-'C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_DATA/RedCap'
behav_path <- 'C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_DATA/Behav/'

##########################RedCap infos######################

##### load dfs #####
redcap<-read.csv(file.path(data_path, "TRR265ProjectB01WP2I-DataForWP2Analysis_DATA_2024-06-18_1751.csv", na.strings=""))
redcap_BA<-read.csv(file.path(data_path, "TRR265BasicAssessmen-B01WP2DemoVars_DATA_2024-06-18_1753.csv", na.strings=""))
behav <- load(file.path(behav_path, "behav_final_n58.RData", na.strings=""))

## extract subject with valid data

# exlcude subjects due to data collection errors
redcap <- redcap[ !(redcap$participant_id %in% c(815,12240,12355,12390,12438,12564,12653,12885,12900,12956,12992,13065)), ]

# exlcude subjects due to head movement & behav exclusion criteria

# exclude subjects based on performance
ID_excl <- as.vector(read.table(file.path(behav_path, 'ID_excluded_n58.txt'), header = F)$V1)
redcap <- dplyr::filter(redcap, !(participant_id %in% ID_excl))

# reformat and extract only relevant columns
redcap<-select(redcap, all_of(c('participant_id', 'b01_age', 'bx_sozio_gender', 'bx_aud_aud', 'bx_aud_sum', 'bx_audit_sum', 'bx_qsu_smoking', 'bx_sozio_graduat', 'bx_scid_sub1_sum')))

redcap <- redcap %>%
  
  # rename vars
  dplyr::rename(ID = participant_id,
         age = b01_age,
         gender = bx_sozio_gender,
         aud_group = bx_aud_aud,
         aud_sum= bx_aud_sum,
         audit_sum = bx_audit_sum,
         smoker = bx_qsu_smoking,
         graduat = bx_sozio_graduat,
         can_sum = bx_scid_sub1_sum) %>%
  
  # create factors
  mutate(ID=as.factor(ID),
         aud_group=factor(aud_group, labels=c("HC",
                                               "AUD")),
         gender=factor(gender, labels=c("female",
                                         "male")),
         smoker=factor(smoker, labels=c("no",
                                        "yes")),
         graduat=factor(graduat, labels=c("Schüler/in, besuche eine allgemein bildende Vollzeitschule",
                                          "Realschulabschluss (Mittlere Reife)",
                                          "Fachhochschulreife, Abschluss Fachoberschule",
                                          "Allgemeine oder fachgebundene Hochschulreife/ Abitur (Gymnasium bzw. EOS, auch EOS mit Lehre)",
                                          "Einen anderen Schulabschluss"))) %>%
  
  # replace missing values
  mutate(aud_group = replace(aud_group, is.na(aud_group), "HC"),
         aud_sum= replace(aud_sum, is.na(aud_sum), 0),
         smoker = replace(smoker, is.na(smoker), "yes"))

# add infos from BA
redcap_BA <- redcap_BA %>%
  rename(ID = participant_id) %>%
  filter(redcap_event_name == "erhebungszeitpunkt_arm_1")
redcap_new <- merge.data.frame(redcap, redcap_BA, by = "ID", all.x = T)

# num of subjs
nsub<-length(redcap$ID)

# save redcap file
save(file=file.path(data_path, paste("redcap_n", nsub, ".RData", sep="")), redcap)
