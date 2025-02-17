###### EMA data ######

###### Preps ######

# clear
rm(list=ls())

libs<-c("tidyverse", "dplyr", "arrow")
#install.packages(libs)
sapply(libs, require, character.only=TRUE)

ema_path <- 'WP2_ILT_DATA/EMA/'
demo_path <- 'WP2_ILT_DATA/RedCap/'

ema_data <- read_parquet(file.path(ema_path, "raw/milena.parquet"))
load(file.path(demo_path, "redcap_n56_new.RData"))

###### Format df ######

ema_data <- ema_data %>%
  select(participant_id, date, sampling_day, g_alc) %>%
  dplyr::rename(ID = participant_id,
                date_time = date) %>%
  mutate(date = as.Date(date_time),
         log_g_alc = log(g_alc+1)) %>%
  filter(ID %in% redcap_new$ID) %>%
  drop_na()

# create redcap df containing ema subjects
redcap_new <- redcap_new[redcap_new$ID %in% ema_data$ID, ]

# get n
n <- length(unique(ema_data$ID))

###### save dfs ######
save(file=file.path(ema_path, paste("ema_data_n", n, ".RData", sep="")), ema_data)
save(file=file.path(demo_path, paste("redcap_n", n, "_new.RData", sep="")), redcap_new)
