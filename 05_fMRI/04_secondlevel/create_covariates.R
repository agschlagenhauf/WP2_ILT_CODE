###################################################################
##### create covariate files used for 2nd level fMRI analyses #####
###################################################################

##### preps #####

rm(list=ls())

libs<-c("tidyverse", "stringr", "plyr", "dplyr", "fastDummies")
sapply(libs, require, character.only=TRUE)

data_path<-'C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_DATA/'

load(file.path(data_path,"RedCap/redcap_n56_new_imputed.RData"))
load(file.path(data_path,"Behav/behav_final_n56.RData"))
params <- read.table(file.path(data_path, 'Stan_Output/PH_withC/Params_PH_withC_init05_n58.txt'), header = T)

# restructure behav df
behav_final <- behav_final %>%
  select(ID, reinforcer_type, taste1, taste2, crave1, crave2) %>%
  mutate(taste_diff = taste2-taste1,
         crave_diff = crave2-crave1) %>%
  distinct() %>%
  pivot_wider(names_from = reinforcer_type, values_from = c(taste1, taste2, taste_diff, crave1, crave2, crave_diff)) %>%
  rowwise() %>%
  mutate(taste_A = (taste1_A + taste2_A)/2,
         taste_J = (taste1_J + taste2_J)/2,
         crave_A = (crave1_A + crave2_A)/2,
         crave_J = (crave1_J + crave2_J)/2) %>%
  mutate(taste_AJ_diff = taste_A - taste_J,
         crave_AJ_diff = crave_A - crave_J) %>%
  mutate(taste_AJ = (taste_A + taste_J)/2,
         crave_AJ = (crave_A + crave_J)/2)

# restructure params df
params <- params %>%
  select(ID, reinforcer_type, p_correct, alpha, tau, gamma, C) %>%
  pivot_wider(names_from = reinforcer_type, values_from = c(p_correct, alpha, tau, gamma, C)) %>%
  mutate(ID = as.factor(ID))

# merge
df <- left_join(redcap_new_imputed, behav_final)
df <- left_join(df, params)

df <- df %>%
  arrange(aud_group, ID)

df <- dummy_cols(df, select_columns = c("screen_handeness", "MRI"))
  
###########################################
##### create specific covariate files #####
###########################################

##### standard covariates #####

covariates <- df %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days)

covariates_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days)

covariates_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days)

write.table(covariates, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

###########################################

##### standard covariates + age #####

covariates_age <- df %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age)

covariates_age_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age)

covariates_age_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age)

write.table(covariates_age, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_age_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_age_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_age_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

##### severity measures only ######

covariates_audit <- df %>%
  select(MRI_audit_sum)

covariates_audit_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(MRI_audit_sum)

covariates_audit_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(MRI_audit_sum)

write.table(covariates_audit, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_audit_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_audit_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_audit_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_audit_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_audit_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


covariates_drinkspast3months <- df %>%
  select(BA_drinks_past3months)

covariates_drinkspast3months_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(BA_drinks_past3months)

covariates_drinkspast3months_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(BA_drinks_past3months)

write.table(covariates_drinkspast3months, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_drinks3months_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_drinkspast3months_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_drinks3months_AUD_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_drinkspast3months_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_drinks3months_HC_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


covariates_uppsp <- df %>%
  select(uppsp_total)

covariates_uppsp_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(uppsp_total)

covariates_uppsp_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(uppsp_total)

write.table(covariates_uppsp, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_uppsp_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_uppsp_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_uppsp_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_uppsp_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_uppsp_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


covariates_cohs <- df %>%
  select(cohs_total)

covariates_cohs_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(cohs_total)

covariates_cohs_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(cohs_total)

write.table(covariates_cohs, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_cohs_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_cohs_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_cohs_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_cohs_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_cohs_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


covariates_oci <- df %>%
  select(oci_total)

covariates_oci_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(oci_total)

covariates_oci_HC <- df %>%
  filter(aud_group=="HC") %>%
  select(oci_total)

write.table(covariates_oci, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_oci_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_oci_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_oci_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_oci_HC, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_oci_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


#### standard covariates + age + taste and craving ratings #####

covariates_age_taste_crave_AJ_diff <- df %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age, taste_AJ_diff, crave_AJ_diff)

write.table(covariates_age_taste_crave_AJ_diff, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_taste_crave_AJ_diff_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

covariates_age_taste_crave_AJ <- df %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age, taste_AJ, crave_AJ)

write.table(covariates_age_taste_crave_AJ, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_taste_crave_AJ_diff_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)



##### standard covariates + age + taste and craving ratings + basic severity measures #####

covariates_age_taste_crave_severity <- df %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age, taste_AJ_diff, crave_AJ_diff, MRI_audit_sum, BA_drinks_past3months)

covariates_age_taste_crave_severity_aud <- df %>%
  filter(aud_group == "AUD") %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age, taste_AJ_diff, crave_AJ_diff, MRI_audit_sum, BA_drinks_past3months)

covariates_age_taste_crave_severity_hc <- df %>%
  filter(aud_group == "HC") %>%
  select(screen_handeness_1, screen_handeness_3, MRI_2, BA_smoking_days, age, taste_AJ_diff, crave_AJ_diff, MRI_audit_sum, BA_drinks_past3months)

write.table(covariates_age_taste_crave_severity, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_age_taste_crave_severity_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_taste_crave_severity_aud, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_age_taste_crave_severity_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_taste_crave_severity_hc, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/02_ILT/01_spm12_2nd_level/covariates/covariates_age_taste_crave_severity_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

