###### PREPARE DFS ######
###### Milena 11/2022 #####

rm(list=ls())
#install.packages(c('tidyverse', 'stringr', 'dplyr', 'mice', 'naniar'))
libs<-c("tidyverse", "stringr", "dplyr", 'mice', 'naniar')
sapply(libs, require, character.only=TRUE)

#####

# define paths
data_path<-'WP2_ILT_DATA/RedCap/'
behav_path <- 'WP2_ILT_DATA/Behav/'

##########################RedCap infos######################

##### load dfs #####

redcap_demo<-read.csv(file.path(data_path, "raw/TRR265ProjectB01WP2I-WP2demobaseline_DATA_2024-12-10_1541.csv", na.strings="", fsep = ""))
redcap_psycho<-read.csv(file.path(data_path, "raw/TRR265ProjectB01WP2I-WP2psychometric_DATA_2024-12-10_1210.csv", na.strings="", fsep = ""))
redcap_screening<-read.csv(file.path(data_path, "raw/TRR265TelephoneScree-B01WP2_DATA_2024-06-27_1023.csv", na.strings="", fsep = ""))
redcap_BA<-read.csv(file.path(data_path, "raw/TRR265BasicAssessmen-B01WP2DemoVars_DATA_2024-12-10_1552.csv", na.strings="", fsep = ""))
redcap_BA_HC<-read.csv(file.path(data_path, "raw/TRR265BasicAssessmen-B01WP2_DATA_2024-12-10_1541.csv", na.strings="", fsep = ""))
redcap_FU<-read.csv(file.path(data_path, "raw/TRR265BasicAssessmen-B01WP2DemoVars_DATA_2024-12-19_1630.csv", na.strings="", fsep = ""))

load(file.path(behav_path, "behav_final_n71.RData", na.strings="", fsep = ""))
behav_n71 <- behav_final

load(file.path(behav_path, "behav_final_n58.RData", na.strings="", fsep = ""))
behav_n58 <- behav_final

load(file.path(behav_path, "behav_final_n56.RData", na.strings="", fsep = ""))
behav_n56 <- behav_final

##### reformat and extract only relevant columns #####

redcap_demo <- redcap_demo %>%
  
  # select relevant columns
  select(c('participant_id', 'b01_date', 'b01_age', 'bx_sozio_gender', 'bx_aud_aud', 
           'bx_aud_sum', 'bx_audit_sum', 'bx_qsu_smoking', 'bx_sozio_graduat', 
           'bx_scid_sub1_sum')) %>%
  
  # rename vars
  dplyr::rename(ID = participant_id,
               MRI_date = b01_date,
               age = b01_age,
               gender = bx_sozio_gender,
               aud_group = bx_aud_aud,
               aud_sum= bx_aud_sum,
               BA_audit_sum = bx_audit_sum,
               smoker = bx_qsu_smoking,
               graduat = bx_sozio_graduat,
               BA_can_sum = bx_scid_sub1_sum) %>%
  
  # create factors
  mutate(MRI_date = as.Date(MRI_date, format= "%Y-%m-%d"),
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
  mutate(aud_group = replace(aud_group, is.na(aud_group), "HC"), # when AUDIT-C negative, SCID was not conducted and aud_sum is therefore NA
         aud_sum= replace(aud_sum, is.na(aud_sum), 0),
         smoker = replace(smoker, is.na(smoker), "yes")) # missing value for ID12493, but QF questionnaire reveals they are a current smoker

##### add info from other dataframes #####

# add handedness info from telephone screening

redcap_screening <- redcap_screening %>%
  dplyr::rename(ID = "participant_id")

redcap_new <- merge.data.frame(redcap_demo, redcap_screening, by = "ID", all.x = T)

# add scanner info from behav data
scanner_df <- behav_final %>%
  mutate(scanner = as.numeric(scanner)) %>%
  group_by(ID) %>%
  dplyr::summarise(MRI = mean(scanner, na.rm=F))
redcap_new <- merge.data.frame(redcap_new, scanner_df, by = "ID", all.x = T)

# add variables from Basic Assessment

BA_df <- redcap_FU %>%
  filter(redcap_event_name == "erhebungszeitpunkt_arm_1") %>%
  filter(redcap_repeat_instrument != "at_home_audit") %>%
  select(! c(redcap_event_name, redcap_repeat_instrument, redcap_repeat_instance, bx_qf1_fu_sum, bx_qf2_fu_sum, bx_qf3_fu_sum, 
             bx_qf4_fu_sum, timestamp_audit, bx_athome_audit_sum)) %>%
  dplyr::rename(ID = participant_id,
               BA_date = bx_date,
               smoking_days = bx_qf_tab_06,
               format = bx_qf_tab_07,
               BA_drinks_past3months = bx_qf1_sum,
               BA_drinks_weekday = bx_qf2_sum,
               BA_drinks_weekendday = bx_qf3_sum,
               BA_drinks_lastday = bx_qf4_sum) %>%
  mutate(smoking_days_3m = case_when(format == 1 ~ smoking_days,
                                     format == 2 ~ smoking_days*4.33*3),
         BA_date = as.Date(BA_date, format= "%Y-%m-%d")) %>%
  select(! c(smoking_days, format))
redcap_new <- merge.data.frame(redcap_new, BA_df, by = "ID", all.x = T)

BA_HC_df <- redcap_BA_HC %>%
  filter(redcap_event_name == "erhebungszeitpunkt_arm_1") %>%
  select(! c(redcap_event_name, redcap_repeat_instance, redcap_repeat_instrument)) %>%
  dplyr::rename(ID = participant_id,
                BA_date = bx_date,
                smoking_days = bx_qf_tab_06,
                format = bx_qf_tab_07,
                BA_drinks_past3months = bx_qf1_sum,
                BA_drinks_weekday = bx_qf2_sum,
                BA_drinks_weekendday = bx_qf3_sum,
                BA_drinks_lastday = bx_qf4_sum) %>%
  mutate(smoking_days_3m = case_when(format == 1 ~ smoking_days,
                                     format == 2 ~ smoking_days*4.33*3),
         BA_date = as.Date(BA_date, format= "%Y-%m-%d")) %>%
  select(! c(smoking_days, format))
redcap_new <- merge.data.frame(redcap_new, BA_HC_df, by = "ID", all.x = T)

redcap_new <- redcap_new %>%
  mutate(BA_date = coalesce(BA_date.y, BA_date.x),
         BA_smoking_days = coalesce(smoking_days_3m.y, smoking_days_3m.x),
         BA_drinks_past3months = coalesce(BA_drinks_past3months.y, BA_drinks_past3months.x),
         BA_drinks_weekday = coalesce(BA_drinks_weekday.y, BA_drinks_weekday.x),
         BA_drinks_weekendday = coalesce(BA_drinks_weekendday.y, BA_drinks_weekendday.x),
         BA_drinks_lastday = coalesce(BA_drinks_lastday.y, BA_drinks_lastday.x)
  ) %>%
  mutate(days_since_BA = as.numeric(MRI_date - BA_date)) %>%
  select(! c(BA_date.x, BA_date.y, smoking_days_3m.x, smoking_days_3m.y, BA_drinks_past3months.x, BA_drinks_past3months.y, 
             BA_drinks_weekday.x, BA_drinks_weekday.y, BA_drinks_weekendday.x, BA_drinks_weekendday.y,
             BA_drinks_lastday.x, BA_drinks_lastday.y))

# # add variables from follow-ups
# 
# FU_df <- redcap_FU %>%
#   filter(redcap_event_name %in% c("followup_1_arm_1", "followup_2_arm_1", "followup_3_arm_1")) %>%
#   select(! c(redcap_repeat_instrument, redcap_repeat_instance, bx_qf1_sum, bx_qf2_sum, bx_qf3_sum, 
#              bx_qf4_sum, bx_qf_tab_06, bx_qf_tab_07)) %>%
#   dplyr::rename(ID = participant_id,
#                 date = bx_date,
#                 drinks_past3months = bx_qf1_fu_sum,
#                 drinks_weekday = bx_qf2_fu_sum,
#                 drinks_weekendday = bx_qf3_fu_sum,
#                 drinks_lastday = bx_qf4_fu_sum,
#                 audit_sum = bx_athome_audit_sum,
#                 audit_date = timestamp_audit) %>%
#   mutate(redcap_event_name = dplyr::recode(redcap_event_name, 
#                                     "followup_1_arm_1" = "FU1",
#                                     "followup_2_arm_1" = "FU2",
#                                     "followup_3_arm_1" = "FU3"),
#          date = as.Date(date, format= "%Y-%m-%d"),
#          audit_date = substr(audit_date, start = 1, stop = 10),
#          audit_date = as.Date(audit_date, format= "%Y-%m-%d")) %>%
#   pivot_wider(id_cols = ID, 
#               names_from = redcap_event_name, 
#               values_from = c(date, drinks_past3months, drinks_weekday, drinks_weekendday,
#                               drinks_lastday, audit_date, audit_sum),
#               names_glue = "{redcap_event_name}_{.value}",
#               names_vary = "slowest")
# redcap_new <- merge.data.frame(redcap_new, FU_df, by = "ID", all.x = T)

##### process and merge psychometric df #####

# UPPSP
redcap_psycho <- redcap_psycho %>%
  rowwise() %>%
  dplyr::mutate(
    uppsp_negative_urgency = mean(c_across(starts_with("b01_uppsp_nu")), na.rm = F),
    uppsp_premeditation = mean(c_across(starts_with("b01_uppsp_pm")), na.rm = F),
    uppsp_perseverance = mean(c_across(starts_with("b01_uppsp_ps")), na.rm = F),
    uppsp_sensation_seeking = mean(c_across(starts_with("b01_uppsp_ss")), na.rm = F),
    uppsp_positive_urgency = mean(c_across(starts_with("b01_uppsp_ps")), na.rm = F),
    uppsp_total = mean(c_across(starts_with("uppsp_")), na.rm = F)
  ) %>%
  ungroup()

# OCI-R
redcap_psycho <- redcap_psycho %>%
  rowwise() %>%
  dplyr::mutate(
    oci_hoarding = sum(c_across(starts_with("oci_hoard")), na.rm = F),
    oci_checking = sum(c_across(starts_with("oci_check")), na.rm = F),
    oci_ordering = sum(c_across(starts_with("oci_order")), na.rm = F),
    oci_neutralising = sum(c_across(starts_with("oci_neutral")), na.rm = F),
    oci_washing = sum(c_across(starts_with("oci_wash")), na.rm = F),
    oci_obsessing = sum(c_across(starts_with("oci_obsess")), na.rm = F),
    oci_total = sum(oci_hoarding, oci_checking, oci_ordering, oci_neutralising, oci_washing, oci_obsessing, na.rm = F)
  ) %>%
  ungroup()

# COHS
redcap_psycho <- redcap_psycho %>%
  rowwise() %>%
  dplyr::mutate(
    cohs_routine = mean(c(b01_cohs_01, b01_cohs_02, b01_cohs_04, b01_cohs_06,
                        b01_cohs_07, b01_cohs_10, b01_cohs_12, b01_cohs_13,
                        b01_cohs_14, b01_cohs_15, b01_cohs_17, b01_cohs_18,
                        b01_cohs_20, b01_cohs_22, b01_cohs_24, b01_cohs_27),
                        na.rm = F),
    cohs_automaticity = mean(c(b01_cohs_03, b01_cohs_05, b01_cohs_08, b01_cohs_09,
                            b01_cohs_11, b01_cohs_16, b01_cohs_19, b01_cohs_21,
                            b01_cohs_23, b01_cohs_25, b01_cohs_26),
                            na.rm = F),
    cohs_total = mean(c(cohs_routine, cohs_automaticity), na.rm = F)
  ) %>%
  ungroup()

# SRE
redcap_psycho <- redcap_psycho %>%
  rowwise() %>%
  dplyr::mutate(
    sre_first5times = mean(c(b01_sre_01a, b01_sre_02a, b01_sre_03a, b01_sre_04a),
                        na.rm = TRUE),
    sre_last3drinkingmonths = mean(c(b01_sre_05a, b01_sre_06a, b01_sre_07a, b01_sre_08a),
                           na.rm = TRUE),
    sre_heaviestdrinking = mean(c(b01_sre_09a, b01_sre_10a, b01_sre_11a, b01_sre_12a),
                           na.rm = TRUE),
    sre_total = mean(c(sre_first5times, sre_last3drinkingmonths, sre_heaviestdrinking),
                     na.rm = TRUE)
  ) %>%
  ungroup()

# merge
redcap_psycho <- redcap_psycho %>%
  dplyr::rename(ID = "participant_id",
                MRI_audit_sum = "b01_athome_audit_sum",
                bdi_total = "b01_bdi_sum") %>%
  select(ID,
         MRI_audit_sum,
         bdi_total,
         uppsp_negative_urgency,
         uppsp_premeditation,
         uppsp_perseverance,
         uppsp_sensation_seeking,
         uppsp_positive_urgency,
         uppsp_total,
         cohs_automaticity,
         cohs_routine,
         cohs_total,
         oci_hoarding,
         oci_checking,
         oci_ordering,
         oci_neutralising,
         oci_washing,
         oci_obsessing,
         oci_total,
         sre_first5times,
         sre_last3drinkingmonths,
         sre_heaviestdrinking,
         sre_total)

redcap_new <- merge.data.frame(redcap_new, redcap_psycho, by = "ID", all.x = T)

##### replace missing values #####

# visualize missings
vis_miss(redcap_new)

# NAs in these variables indicate the questionnaire wasn't filled out because no overall consumption was indicated 
redcap_new <- redcap_new %>%
  mutate(ID = as.factor(ID),
         BA_smoking_days = replace_na(BA_smoking_days, 0),
         BA_can_sum = replace_na(BA_can_sum, 0),
         BA_drinks_past3months = replace_na(BA_drinks_past3months, 0),
         BA_drinks_weekday = replace_na(BA_drinks_weekday, 0),
         BA_drinks_weekendday = replace_na(BA_drinks_weekendday, 0),
         BA_drinks_lastday = replace_na(BA_drinks_lastday, 0))

# visualize missings
vis_miss(redcap_new)

###### exclude subjects to create different samples and safe dfs ######

# n71
redcap_new <- dplyr::filter(redcap_new, (ID %in% behav_n71$ID))
behav_final_redcap <- merge(behav_n71,redcap_new,by='ID',all.x = TRUE)

nsub<-length(redcap_new$ID)

save(file=file.path(data_path, paste("redcap_n", nsub, "_new.RData", sep="")), redcap_new)
save(file=file.path(behav_path, paste("behav_final_redcap_n", nsub, ".RData", sep="")), behav_final_redcap)

# n58
redcap_new <- dplyr::filter(redcap_new, (ID %in% behav_n58$ID))
behav_final_redcap <- merge(behav_n58,redcap_new,by='ID',all.x = TRUE)

nsub<-length(redcap_new$ID)

save(file=file.path(data_path, paste("redcap_n", nsub, "_new.RData", sep="")), redcap_new)
save(file=file.path(behav_path, paste("behav_final_redcap_n", nsub, ".RData", sep="")), behav_final_redcap)

###### impute missing values for 12995 for fmri analysis and safe ######

redcap_new <- dplyr::filter(redcap_new, (ID %in% behav_n56$ID))
behav_final_redcap <- merge(behav_n56,redcap_new,by='ID',all.x = TRUE)

nsub<-length(redcap_new$ID)

# visualize missings
vis_miss(redcap_new)

init = mice(redcap_new, maxit=0) 
meth = init$method
predM = init$predictorMatrix

# exclude variables as predictors
predM[, c("ID", "MRI_date", "MRI", "BA_date", "days_since_BA",
          "MRI_audit_sum", "bdi_total", 
          "uppsp_negative_urgency", "uppsp_premeditation",
          "uppsp_perseverance", "uppsp_sensation_seeking", "uppsp_positive_urgency",
          "uppsp_total", "oci_hoarding", "oci_checking", "oci_ordering", "oci_neutralising",
          "oci_washing", "oci_obsessing", "oci_total",
          "cohs_automaticity", "cohs_routine", "cohs_total",
          "sre_first5times", "sre_last3drinkingmonths", "sre_heaviestdrinking", "sre_total")]=0

# exclude variables from imputation
meth[c("graduat", 
       "bdi_total",
       "uppsp_negative_urgency", "uppsp_premeditation", "uppsp_perseverance", "uppsp_sensation_seeking", "uppsp_positive_urgency",
       "oci_hoarding", "oci_checking", "oci_ordering", "oci_neutralising", "oci_washing", "oci_obsessing",
       "cohs_automaticity", "cohs_routine",
       "sre_first5times", "sre_last3drinkingmonths", "sre_heaviestdrinking", "sre_total")]=""

# impute
imputed_data <- mice(redcap_new, m=5, method=meth, predictorMatrix=predM, print=TRUE)
redcap_new_imputed <- complete(imputed_data)

# visualize missings
vis_miss(redcap_new_imputed)

# create imputed df
redcap_new_imputed <- dplyr::filter(redcap_new_imputed, (ID %in% behav_n56$ID))

# save
save(file=file.path(data_path, paste("redcap_n", nsub, "_new.RData", sep="")), redcap_new)
save(file=file.path(data_path, paste("redcap_n", nsub, "_new_imputed.RData", sep="")), redcap_new_imputed)
save(file=file.path(behav_path, paste("behav_final_redcap_n", nsub, ".RData", sep="")), behav_final_redcap)
