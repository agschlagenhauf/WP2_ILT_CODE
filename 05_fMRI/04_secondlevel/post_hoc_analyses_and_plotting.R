###################
###### Preps ######
###################

# clear
rm(list=ls())

#install.packages('tidyverse', 'plyr')
libs<-c("tidyverse", "R.matlab", "stringr", "dplyr", "ggplot2", "ggpubr", "bayestestR", "emmeans", "performance", "estimatr", "sjPlot", "rstatix")
sapply(libs, require, character.only=TRUE)

# define paths
data_path <- '/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/WP2_ILT_DATA'

mean_bg_roi <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/mean_ROI_RPE.txt"))
exploratory_nacc <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/exploratory_nacc.txt"))
exploratory_nacc_caudate <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/nacc_caudate.txt"))
exploratory_parietal <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/exploratory_parietal.txt"))
load(file.path(data_path, "Behav/behav_final_redcap_n56.RData"))
# load(file.path(data_path, "Behav/behav_final_n56.RData"))
# load(file.path(data_path, "RedCap/redcap_n56_new.RData"))
# 
# behav_rating <- behav_final %>%
#   group_by(ID,reinforcer_type) %>%
#   dplyr::select(ID,reinforcer_type,ID_block,taste1, taste2, crave1, crave2) %>%
#   distinct() %>%
#   mutate(taste_diff=taste2-taste1,
#          crave_diff=crave2-crave1,
#          taste_mean = ((taste1 + taste2)/2),
#          crave_mean = ((crave1 + crave2)/2))
# behav_rating <- merge(behav_rating,redcap_new,by="ID",all.x = T)
# behav_rating <- behav_rating %>% arrange(aud_group, ID, reinforcer_type)


############################################################################
###### Bilateral basal ganglia activity per group and reinforcer type ######
############################################################################

# structure data
mean_bg_roi <- mean_bg_roi %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("mean_rpe_alc_roi") ~ "alcohol",
                                combination %in% c("mean_rpe_jui_roi") ~ "juice"),
         reinforcer = as.factor(reinforcer)) %>%
  arrange(aud_group, ID, reinforcer)
contrasts(mean_bg_roi$aud_group) <- c(-0.5, 0.5)
contrasts(mean_bg_roi$reinforcer) = c(0.5, -0.5)

# behav_rating$mean_bg_roi <- as.numeric(mean_bg_roi$value)

# model comparison
model_roi_intercept <- lm(value ~ 1, data=mean_bg_roi)
check_model(model_roi_intercept)
# model_roi_group <- lm(value ~ 1 + aud_group, data=mean_bg_roi)
# model_roi_reinforcer <- lm(value ~ 1 + reinforcer, data=mean_bg_roi)
# model_roi_both <- lm(value ~ 1 + aud_group + reinforcer, data=mean_bg_roi)
model_roi_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=mean_bg_roi)
check_model(model_roi_interaction)
model_roi_interaction_rob <- lm_robust(value ~ 1 + aud_group*reinforcer, data=mean_bg_roi)

tab_model(model_roi_interaction,
          dv.labels=c("model_roi_interaction"), digits=2, digits.re=2, df.method = "satterthwaite",
          show.se=TRUE, show.stat=TRUE, show.df=TRUE, show.ci= 0.95,CSS = css_theme("cells"))#
tab_model(model_roi_interaction_rob,
          dv.labels=c("model_roi_interaction"), digits=2, digits.re=2, df.method = "normal",
          show.se=TRUE, show.stat=TRUE, show.df=TRUE, show.ci= 0.95,CSS = css_theme("cells"))#

bayesfactor_models(model_roi_intercept, model_roi_interaction, denominator = model_roi_intercept)

# create plot
fig_bg_roi <- ggplot(mean_bg_roi, aes(x=fct_rev(fct_infreq(reinforcer)), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean \n RPE-related activity") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 18, base_family = "Aptos") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_bg_roi

# ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Mean_ROI.png"), width = 15, height =10, units='cm', dpi = 600, bg="white")

# check correlation taste - activity
cor.test(behav_rating$crave_mean, behav_rating$mean_bg_roi)
plot(behav_rating$crave_mean, behav_rating$mean_bg_roi)

##############################################################
###### Left NAcc activity per group and reinforcer type ######
##############################################################

# structure data
exploratory_nacc <- exploratory_nacc %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("nacc_alc") ~ "alcohol",
                                combination %in% c("nacc_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_nacc$aud_group) <- c(-0.5, 0.5)
contrasts(exploratory_nacc$reinforcer) <- c(0.5, -0.5)

# model comparison
model_nacc_intercept <- lm(value ~ 1, data=exploratory_nacc)
check_model(model_nacc_intercept)
# model_nacc_group <- lm(value ~ 1 + aud_group, data=exploratory_nacc)
# model_nacc_reinforcer <- lm(value ~ 1 + reinforcer, data=exploratory_nacc)
# model_nacc_both <- lm(value ~ 1 + aud_group + reinforcer, data=exploratory_nacc)
model_nacc_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=exploratory_nacc)
check_model(model_nacc_interaction)
model_nacc_interaction_rob <- lm_robust(value ~ 1 + aud_group*reinforcer, data=exploratory_nacc)

tab_model(model_nacc_interaction,
          dv.labels=c("model_roi_interaction"), digits=2, digits.re=2, df.method = "satterthwaite",
          show.se=TRUE, show.stat=TRUE, show.df=TRUE, show.ci= 0.95,CSS = css_theme("cells"))#
tab_model(model_nacc_interaction_rob,
          dv.labels=c("model_roi_interaction"), digits=2, digits.re=2, df.method = "normal",
          show.se=TRUE, show.stat=TRUE, show.df=TRUE, show.ci= 0.95,CSS = css_theme("cells"))#

bayesfactor_models(model_nacc_intercept, model_nacc_interaction, denominator = model_nacc_intercept)

# create plot
fig_expl_nacc <- ggplot(exploratory_nacc, aes(x=fct_rev(fct_infreq(reinforcer)), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("RPE-related activity\nin (MNI [-12 23 -6])") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 18, base_family = "Aptos") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_expl_nacc

# ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Exploratory_NAcc.png"), width = 15, height =10, units='cm', dpi = 600, bg="white")

###########################################################################
###### Bilateral nacc caudate activity per group and reinforcer type ######
###########################################################################

# structure data
exploratory_nacc_caudate <- exploratory_nacc_caudate %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("nacc_caudate_alc") ~ "alcohol",
                                combination %in% c("nacc_caudate_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_nacc_caudate$aud_group) <- c(-0.5, 0.5)
contrasts(exploratory_nacc_caudate$reinforcer) <- c(0.5, -0.5)

# model comparison
model_nc_intercept <- lm(value ~ 1, data=exploratory_nacc_caudate)
check_model(model_nc_intercept)
# model_nc_group <- lm(value ~ 1 + aud_group, data=exploratory_nacc_caudate)
# model_nc_reinforcer <- lm(value ~ 1 + reinforcer, data=exploratory_nacc_caudate)
# model_nc_both <- lm(value ~ 1 + aud_group + reinforcer, data=exploratory_nacc_caudate)
model_nc_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=exploratory_nacc_caudate)
check_model(model_nc_interaction)
model_nc_interaction_rob <- lm_robust(value ~ 1 + aud_group*reinforcer, data=exploratory_nacc_caudate)

tab_model(model_nc_interaction,
          dv.labels=c("model_roi_interaction"), digits=2, digits.re=2, df.method = "satterthwaite",
          show.se=TRUE, show.stat=TRUE, show.df=TRUE, show.ci= 0.95,CSS = css_theme("cells"))
tab_model(model_nc_interaction_rob,
          dv.labels=c("model_roi_interaction"), digits=2, digits.re=2, df.method = "normal",
          show.se=TRUE, show.stat=TRUE, show.df=TRUE, show.ci= 0.95,CSS = css_theme("cells"))

bayesfactor_models(model_nc_intercept, model_nc_interaction, denominator = model_nc_intercept)

# create plot
fig_nacc_caudate <- ggplot(exploratory_nacc_caudate, aes(x=fct_rev(fct_infreq(reinforcer)), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean RPE-related activity \n in left caudate and \n right nucleus accumbens") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 18, base_family = "Aptos") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_nacc_caudate

#ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Extracted_values_nacc_caudate.png"), width = 15, height =11, units='cm', dpi = 600, bg="white")

#########################################################################
###### Left parietal cortex activity per group and reinforcer type ######
#########################################################################

# structure data
exploratory_parietal <- exploratory_parietal %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("parietal_alc") ~ "alcohol",
                                combination %in% c("parietal_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_parietal$aud_group) <- c(-0.5, 0.5)
contrasts(exploratory_parietal$reinforcer) <- c(0.5, -0.5)

# behav_rating$exploratory_parietal <- as.numeric(exploratory_parietal$value)

exploratory_parietal_aud <- exploratory_parietal %>%
  filter(aud_group=="AUD")
exploratory_parietal_hc <- exploratory_parietal %>%
  filter(aud_group=="HC")
exploratory_parietal_alc <- exploratory_parietal %>%
  filter(reinforcer=="alcohol")
exploratory_parietal_jui <- exploratory_parietal %>%
  filter(reinforcer=="juice")

###### post-hoc t-test reinforcer type within aud group ###### 

# outliers
exploratory_parietal_aud %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
exploratory_parietal_aud %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(exploratory_parietal_aud, x = "value", facet.by = "reinforcer")

# conduct test
ttest1<-t.test(exploratory_parietal_aud$value[exploratory_parietal_aud$reinforcer=='alcohol'], exploratory_parietal_aud$value[exploratory_parietal_aud$reinforcer=='juice'], paired=TRUE)
ttest1
p.adjust(ttest1$p.value,n=4)

###### post-hoc t-test reinforcer type within hc group ###### 

# outliers
exploratory_parietal_hc %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
exploratory_parietal_hc %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(exploratory_parietal_hc, x = "value", facet.by = "reinforcer")

# conduct test
ttest2<-t.test(exploratory_parietal_hc$value[exploratory_parietal_hc$reinforcer=='alcohol'], exploratory_parietal_hc$value[exploratory_parietal_hc$reinforcer=='juice'], paired=TRUE)
ttest2
p.adjust(ttest2$p.value,n=4)

###### post-hoc t-test groups within alc reinforcer ###### 

# outliers
exploratory_parietal_alc %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
exploratory_parietal_alc %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(exploratory_parietal_alc, x = "value", facet.by = "aud_group")

# homoscedasticity
exploratory_parietal_alc %>%
  levene_test(value ~ aud_group)

# conduct test
ttest3<-t.test(exploratory_parietal_alc$value ~ exploratory_parietal_alc$aud_group, var.equal=TRUE)
ttest3
p.adjust(ttest3$p.value,n=4)

###### post-hoc t-test groups within jui reinforcer ######

# outliers
exploratory_parietal_jui %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
exploratory_parietal_jui %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(exploratory_parietal_jui, x = "value", facet.by = "aud_group")

# homoscedasticity
exploratory_parietal_jui %>%
  levene_test(value ~ aud_group)

# conduct test
ttest4<-t.test(exploratory_parietal_jui$value ~ exploratory_parietal_jui$aud_group, var.equal=TRUE)
ttest4
p.adjust(ttest4$p.value,n=4)

# create plot

fig_expl_par <- ggplot(exploratory_parietal, aes(x=fct_rev(fct_infreq(reinforcer)), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean \n RPE-related activity") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 18, base_family = "Aptos") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_expl_par

# ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Mean_ROI.png"), width = 15, height =10, units='cm', dpi = 600, bg="white")

# # check correlation taste - activity
# cor.test(behav_rating$taste_mean, behav_rating$exploratory_parietal)
# plot(behav_rating$taste_mean, behav_rating$exploratory_parietal)
# 
# corr_df <- behav_rating %>%
#   select(taste_mean, crave_mean, mean_bg_roi, exploratory_parietal)
# 
# rcorr(as.matrix(corr_df))
# chart.Correlation(corr_df)

#########################
##### Combined plot #####
#########################

ggarrange(fig_expl_par, fig_bg_roi, fig_expl_nacc,
          nrow = 1, ncol= 3,
          common.legend = T,
          legend ='bottom')

#ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Extracted_values_combined.png"), width = 40, height =11, units='cm', dpi = 600, bg="white")

