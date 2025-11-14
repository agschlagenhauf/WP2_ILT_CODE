###### Preps ######

# clear
rm(list=ls())

#install.packages('tidyverse', 'plyr')
libs<-c("tidyverse", "R.matlab", "stringr", "dplyr", "ggplot2", "ggpubr", "bayestestR", "emmeans", "performance")
sapply(libs, require, character.only=TRUE)

# define paths
data_path <- '/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/WP2_ILT_DATA'

mean_bg_roi <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/mean_ROI_RPE.txt"))
exploratory_nacc <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/exploratory_nacc.txt"))
exploratory_nacc_caudate <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/nacc_caudate.txt"))
exploratory_parietal <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/exploratory_parietal.txt"))
load(file.path(data_path, "Behav/behav_final_redcap_n56.RData"))

###### Bilateral basal ganglia activity per group and reinforcer type ######

# structure data
mean_bg_roi <- mean_bg_roi %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("mean_rpe_alc_roi") ~ "alcohol",
                                combination %in% c("mean_rpe_jui_roi") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(mean_bg_roi$aud_group)
contrasts(mean_bg_roi$reinforcer) = (contr.treatment(2)-1)*(-1)

# model comparison
model_roi_intercept <- lm(value ~ 1, data=mean_bg_roi)
model_roi_group <- lm(value ~ 1 + aud_group, data=mean_bg_roi)
model_roi_reinforcer <- lm(value ~ 1 + reinforcer, data=mean_bg_roi)
model_roi_both <- lm(value ~ 1 + aud_group + reinforcer, data=mean_bg_roi)
model_roi_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=mean_bg_roi)

anova(model_roi_intercept, model_roi_group, model_roi_reinforcer, model_roi_both, model_roi_interaction)
bayesfactor_models(model_roi_intercept, model_roi_group, model_roi_reinforcer, model_roi_both, model_roi_interaction, denominator = model_roi_intercept)

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



###### Left NAcc activity per group and reinforcer type ######

# structure data
exploratory_nacc <- exploratory_nacc %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("nacc_alc") ~ "alcohol",
                                combination %in% c("nacc_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_nacc$aud_group)
contrasts(exploratory_nacc$reinforcer) = (contr.treatment(2)-1)*(-1)

# model comparison
model_nacc_intercept <- lm(value ~ 1, data=exploratory_nacc)
model_nacc_group <- lm(value ~ 1 + aud_group, data=exploratory_nacc)
model_nacc_reinforcer <- lm(value ~ 1 + reinforcer, data=exploratory_nacc)
model_nacc_both <- lm(value ~ 1 + aud_group + reinforcer, data=exploratory_nacc)
model_nacc_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=exploratory_nacc)

anova(model_nacc_intercept, model_nacc_group, model_nacc_reinforcer, model_nacc_both, model_nacc_interaction)
bayesfactor_models(model_nacc_intercept, model_nacc_group, model_nacc_reinforcer, model_nacc_both, model_nacc_interaction, denominator = model_nacc_intercept)

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


###### Bilateral nacc caudate activity per group and reinforcer type ######

# structure data
exploratory_nacc_caudate <- exploratory_nacc_caudate %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("nacc_caudate_alc") ~ "alcohol",
                                combination %in% c("nacc_caudate_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_nacc_caudate$aud_group)
contrasts(exploratory_nacc_caudate$reinforcer) = (contr.treatment(2)-1)*(-1)

# model comparison
model_nc_intercept <- lm(value ~ 1, data=exploratory_nacc_caudate)
model_nc_group <- lm(value ~ 1 + aud_group, data=exploratory_nacc_caudate)
model_nc_reinforcer <- lm(value ~ 1 + reinforcer, data=exploratory_nacc_caudate)
model_nc_both <- lm(value ~ 1 + aud_group + reinforcer, data=exploratory_nacc_caudate)
model_nc_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=exploratory_nacc_caudate)

summary(model_nc_interaction)
anova(model_nc_intercept, model_nc_group, model_nc_reinforcer, model_nc_both, model_nc_interaction)
bayesfactor_models(model_nc_intercept, model_nc_group, model_nc_reinforcer, model_nc_both, model_nc_interaction, denominator = model_nc_intercept)

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

ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Extracted_values_nacc_caudate.png"), width = 15, height =11, units='cm', dpi = 600, bg="white")


###### Left parietal cortex activity per group and reinforcer type ######

# structure data
exploratory_parietal <- exploratory_parietal %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("parietal_alc") ~ "alcohol",
                                combination %in% c("parietal_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_parietal$aud_group)
contrasts(exploratory_parietal$reinforcer) = (contr.treatment(2)-1)*(-1)

# model comparison
model_par_intercept <- lm(value ~ 1, data=exploratory_parietal)
model_par_group <- lm(value ~ 1 + aud_group, data=exploratory_parietal)
model_par_reinforcer <- lm(value ~ 1 + reinforcer, data=exploratory_parietal)
model_par_both <- lm(value ~ 1 + aud_group + reinforcer, data=exploratory_parietal)
model_par_interaction <- lm(value ~ 1 + aud_group*reinforcer, data=exploratory_parietal)

check_model(model_par_interaction)

anova(model_par_intercept, model_par_group, model_par_reinforcer, model_par_both, model_par_interaction)
bayesfactor_models(model_par_intercept, model_par_group, model_par_reinforcer, model_par_both, model_par_interaction, denominator = model_par_intercept)

summary(model_par_interaction)
summary(emmeans(model_par_interaction, specs = pairwise ~ aud_group|reinforcer, lmer.df = "satterthwaite", adjust = "bonf", ), infer=TRUE)
summary(emmeans(model_par_interaction, specs = pairwise ~ reinforcer|aud_group, lmer.df = "satterthwaite", adjust = "bonf", ), infer=TRUE)


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


##### Combined plot #####

ggarrange(fig_expl_par, fig_bg_roi, fig_expl_nacc,
          nrow = 1, ncol= 3,
          common.legend = T,
          legend ='bottom')

ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Extracted_values_combined.png"), width = 40, height =11, units='cm', dpi = 600, bg="white")

