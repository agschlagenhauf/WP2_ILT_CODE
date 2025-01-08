###################################################################
##### create covariate files used for 2nd level fMRI analyses #####
###################################################################

rm(list=ls())

libs<-c("tidyverse", "stringr", "plyr", "dplyr")
sapply(libs, require, character.only=TRUE)

data_path<-'WP2_ILT_DATA'

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

##### create specific covariate files #####

# standard
covariates <- df %>%
  select(screen_handeness, MRI, smoking_days)

covariates_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(screen_handeness, MRI, smoking_days)


# age
covariates_age <- df %>%
  select(screen_handeness, MRI, smoking_days, age)


# severity measures
covariates_audit <- df %>%
  select(audit_sum_wp2)

covariates_audit_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(audit_sum_wp2)


covariates_drinkspast3months <- df %>%
  select(drinks_past3months)

covariates_drinkspast3months_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(drinks_past3months)


covariates_uppsp <- df %>%
  select(uppsp_total)

covariates_uppsp_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(uppsp_total)


covariates_cohs <- df %>%
  select(cohs_total)

covariates_cohs_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(cohs_total)


covariates_oci <- df %>%
  select(oci_total)

covariates_oci_AUD <- df %>%
  filter(aud_group=="AUD") %>%
  select(oci_total)


# taste and craving ratings
covariates_taste_crave_AJ_diff_ONLY <- df %>%
  select(taste_AJ_diff, crave_AJ_diff)


# age, taste, and craving ratings
covariates_age_taste_crave_AJ <- df %>%
  select(screen_handeness, MRI, smoking_days, age, taste_AJ, crave_AJ)

covariates_age_taste_crave_AJ_diff <- df %>%
  select(screen_handeness, MRI, smoking_days, age, taste_AJ_diff, crave_AJ_diff)

covariates_age_taste_crave_A <- df %>%
  select(screen_handeness, MRI, smoking_days, age, taste_A, crave_A)

covariates_age_taste_crave_J <- df %>%
  select(screen_handeness, MRI, smoking_days, age, taste_J, crave_J)

# severity
covariates_age_taste_crave_severity <- df %>%
  select(screen_handeness, MRI, smoking_days, age, taste_AJ_diff, crave_AJ_diff, audit_sum_wp2, drinks_past3months)

covariates_age_taste_crave_severity_aud <- df %>%
  filter(aud_group == "AUD") %>%
  select(screen_handeness, MRI, smoking_days, age, taste_AJ_diff, crave_AJ_diff, audit_sum_wp2, drinks_past3months)


# all combined
covariates_all_aud <- df %>%
  filter(aud_group == "AUD") %>%
  select(screen_handeness, MRI, smoking_days, age, taste_AJ_diff, crave_AJ_diff, audit_sum_wp2, drinks_past3months, uppsp_total, cohs_total, oci_total)

covariates_all_hc <- df %>%
  filter(aud_group == "HC") %>%
  select(screen_handeness, MRI, smoking_days, age, taste_AJ_diff, crave_AJ_diff, audit_sum_wp2, drinks_past3months, uppsp_total, cohs_total, oci_total)

##### save csv #####

# covariates regular
write.table(covariates, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# regular + age
write.table(covariates_age, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# audit only
write.table(covariates_audit, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_audit_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_audit_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_audit_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# drinks only
write.table(covariates_drinkspast3months, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_drinks3months_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_drinkspast3months_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_drinks3months_AUD_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# uppsp only
write.table(covariates_uppsp, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_uppsp_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_uppsp_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_uppsp_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# oci only
write.table(covariates_oci, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_oci_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_oci_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_oci_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# cohs only
write.table(covariates_cohs, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_cohs_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_cohs_AUD, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_cohs_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

# taste crave only
write.table(covariates_taste_crave_AJ_diff_ONLY, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_only_taste_crave_AJ_diff_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)


# regular + taste crave
write.table(covariates_taste_crave_AJ, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_taste_crave_AJ_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_taste_crave_AJ_diff, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_taste_crave_AJ_diff_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)



# regular + age + taste crave
write.table(covariates_age_taste_crave_AJ, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_AJ_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_taste_crave_AJ_diff, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_AJ_diff_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_taste_crave_A, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_A_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_taste_crave_J, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_J_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

# regular + age + taste crave + severity
write.table(covariates_age_taste_crave_severity, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_severity_n56.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_age_taste_crave_severity_aud, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_severity_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

# regular + age + taste crave + psycho
write.table(covariates_all_aud, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_psycho_aud_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)

write.table(covariates_all_hc, file="S:/AG/AG-Schlagenhauf_TRR265/Daten/B01/WP2_DATA/derivatives/03_spm12_2nd_level/covariates/covariates_age_taste_crave_psycho_hc_n28.txt", 
            append = FALSE, 
            sep = " ", 
            dec = ".",
            row.names = F,
            col.names = F)
