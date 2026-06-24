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

mean_bg_roi <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/correct_PC/mean_ROI_RPE.txt"))
peak_RPE <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/correct_PC/peak_RPE.txt"))
exploratory_clusters <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/correct_PC/mean_exploratory_clusters_RPE.txt"))
reward_cluster <- read.csv(file.path(data_path, "fMRI/extracted_values_and_maps/winnowin_Q/dlpfc_reward_cluster.txt"))
load(file.path(data_path, "Behav/behav_final_redcap_n56.RData"))


############################################################################
###### Bilateral basal ganglia activity per group and reinforcer type ######
############################################################################

# structure data
mean_bg_roi <- mean_bg_roi %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("mean_basal_ganglia_alc") ~ "alcohol",
                                combination %in% c("mean_basal_ganglia_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer)) %>%
  arrange(aud_group, ID, reinforcer)
contrasts(mean_bg_roi$aud_group) <- c(-0.5, 0.5)
contrasts(mean_bg_roi$reinforcer) = c(0.5, -0.5)

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
  theme_light(base_size = 16, base_family = "Arial") +
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

#ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Addiction Neuroscience/revision_1/Figures", "basal_ganglia_roi.png"), width = 15, height =10, units='cm', dpi = 600, bg="white")

#########################################################################
###### MFG peak activity per group and reinforcer type ######
#########################################################################

# structure data
peak_RPE <- peak_RPE %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("peak_alc") ~ "alcohol",
                                combination %in% c("peak_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(peak_RPE$aud_group) <- c(-0.5, 0.5)
contrasts(peak_RPE$reinforcer) <- c(0.5, -0.5)

peak_RPE_aud <- peak_RPE %>%
  filter(aud_group=="AUD")
peak_RPE_hc <- peak_RPE %>%
  filter(aud_group=="HC")
peak_RPE_alc <- peak_RPE %>%
  filter(reinforcer=="alcohol")
peak_RPE_jui <- peak_RPE %>%
  filter(reinforcer=="juice")

###### post-hoc t-test reinforcer type within aud group ###### 

# outliers
peak_RPE_aud %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
peak_RPE_aud %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(peak_RPE_aud, x = "value", facet.by = "reinforcer")

# conduct test
ttest1<-t.test(peak_RPE_aud$value[peak_RPE_aud$reinforcer=='alcohol'], peak_RPE_aud$value[peak_RPE_aud$reinforcer=='juice'], paired=TRUE)
ttest1
p.adjust(ttest1$p.value,n=4)

###### post-hoc t-test reinforcer type within hc group ###### 

# outliers
peak_RPE_hc %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
peak_RPE_hc %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(peak_RPE_hc, x = "value", facet.by = "reinforcer")

# conduct test
ttest2<-t.test(peak_RPE_hc$value[peak_RPE_hc$reinforcer=='alcohol'], peak_RPE_hc$value[peak_RPE_hc$reinforcer=='juice'], paired=TRUE)
ttest2
p.adjust(ttest2$p.value,n=4)

###### post-hoc t-test groups within alc reinforcer ###### 

# outliers
peak_RPE_alc %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
peak_RPE_alc %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(peak_RPE_alc, x = "value", facet.by = "aud_group")

# homoscedasticity
peak_RPE_alc %>%
  levene_test(value ~ aud_group)

# conduct test
ttest3<-t.test(peak_RPE_alc$value ~ peak_RPE_alc$aud_group, var.equal=TRUE)
ttest3
p.adjust(ttest3$p.value,n=4)

###### post-hoc t-test groups within jui reinforcer ######

# outliers
peak_RPE_jui %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
peak_RPE_jui %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(peak_RPE_jui, x = "value", facet.by = "aud_group")

# homoscedasticity
peak_RPE_jui %>%
  levene_test(value ~ aud_group)

# conduct test
ttest4<-t.test(peak_RPE_jui$value ~ peak_RPE_jui$aud_group, var.equal=TRUE)
ttest4
p.adjust(ttest4$p.value,n=4)

# create plot

fig_peak_RPE <- ggplot(peak_RPE, aes(x=fct_rev(fct_infreq(reinforcer)), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("RPE-related activity in \n MNI [-51 9 49]") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 16, base_family = "Arial") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_peak_RPE

# ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Initial_draft/Figures", "Mean_ROI.png"), width = 15, height =10, units='cm', dpi = 600, bg="white")

#########################
##### Combined plots #####
#########################

ggarrange(fig_bg_roi, fig_peak_RPE,
          nrow = 1, ncol= 2,
          common.legend = T,
          legend ='bottom')

ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Addiction Neuroscience/revision_1/Figures", "Figure_6_plots.tiff"), width = 19, height = 9, units='cm', dpi=1000, bg="white")


#########################################################################
###### Exploratory RPE cluster activity per group and reinforcer type ######
#########################################################################

# structure data
exploratory_clusters <- exploratory_clusters %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("left_pariental_inf_alc",
                                                   "left_precentral_alc",
                                                   "left_temporal_inf_alc",
                                                   "left_temporal_inf_inner_alc",
                                                   "right_frontal_inf_alc",
                                                   "right_frontal_mid_alc") ~ "alcohol",
                                combination %in% c("left_pariental_inf_jui",
                                                   "left_precentral_jui",
                                                   "left_temporal_inf_jui",
                                                   "left_temporal_inf_inner_jui",
                                                   "right_frontal_inf_jui",
                                                   "right_frontal_mid_jui") ~ "juice"),
         region = case_when(combination %in% c("left_pariental_inf_alc",
                                               "left_pariental_inf_jui") ~ "Left superior parietal cortex",
                            combination %in% c("left_precentral_alc",
                                               "left_precentral_jui") ~ "Left middle frontal cortex",
                            combination %in% c("left_temporal_inf_alc",
                                               "left_temporal_inf_jui") ~ "Left middle temporal cortex",
                            combination %in% c("left_temporal_inf_inner_alc",
                                               "left_temporal_inf_inner_jui") ~ "Left inferior temporal cortex",
                            combination %in% c("right_frontal_inf_alc",
                                               "right_frontal_inf_jui") ~ "Right inferior frontal cortex",
                            combination %in% c("right_frontal_mid_alc",
                                               "right_frontal_mid_jui") ~ "Right middle frontal cortex"),
         region = factor(region, levels = c(
           "Left middle frontal cortex",
           "Right middle frontal cortex",
           "Right inferior frontal cortex",
           "Left middle temporal cortex",
           "Left inferior temporal cortex",
           "Left superior parietal cortex")),
         reinforcer = as.factor(reinforcer))
contrasts(exploratory_clusters$aud_group) <- c(-0.5, 0.5)
contrasts(exploratory_clusters$reinforcer) <- c(0.5, -0.5)

exploratory_clusters_aud <- exploratory_clusters %>%
  filter(aud_group=="AUD")
exploratory_clusters_hc <- exploratory_clusters %>%
  filter(aud_group=="HC")
exploratory_clusters_alc <- exploratory_clusters %>%
  filter(reinforcer=="alcohol")
exploratory_clusters_jui <- exploratory_clusters %>%
  filter(reinforcer=="juice")

cluster <- "left superior parietal cortex" # "left superior parietal cortex", "left middle frontal cortex", "left middle temporal cortex", "left inferior temporal cortex", "right inferior frontal cortex", "right middle frontal cortex"

###### post-hoc t-test reinforcer type within aud group ###### 

# outliers
exploratory_clusters_aud[exploratory_clusters_aud$region==cluster,] %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
exploratory_clusters_aud[exploratory_clusters_aud$region==cluster,] %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(exploratory_clusters_aud[exploratory_clusters_aud$region==cluster,], x = "value", facet.by = "reinforcer")

# conduct test
ttest5<-wilcox.test(exploratory_clusters_aud$value[exploratory_clusters_aud$reinforcer=='alcohol' & exploratory_clusters_aud$region == cluster], exploratory_clusters_aud$value[exploratory_clusters_aud$reinforcer=='juice' & exploratory_clusters_aud$region == cluster], paired=TRUE)
ttest5
p.adjust(ttest5$p.value,n=4)

###### post-hoc t-test reinforcer type within hc group ###### 

exploratory_clusters_hc[exploratory_clusters_hc$region==cluster,] %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
exploratory_clusters_hc[exploratory_clusters_hc$region==cluster,] %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(exploratory_clusters_hc[exploratory_clusters_hc$region==cluster,], x = "value", facet.by = "reinforcer")

# conduct test
ttest6<-t.test(exploratory_clusters_hc$value[exploratory_clusters_hc$reinforcer=='alcohol' & exploratory_clusters_hc$region == cluster], exploratory_clusters_hc$value[exploratory_clusters_hc$reinforcer=='juice' & exploratory_clusters_hc$region == cluster], paired=TRUE)
ttest6
p.adjust(ttest6$p.value,n=4)

###### post-hoc t-test groups within alc reinforcer ###### 

# outliers
exploratory_clusters_alc[exploratory_clusters_alc$region==cluster,] %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
exploratory_clusters_alc[exploratory_clusters_alc$region==cluster,] %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(exploratory_clusters_alc[exploratory_clusters_alc$region==cluster,], x = "value", facet.by = "aud_group")

# homoscedasticity
exploratory_clusters_alc[exploratory_clusters_alc$region==cluster,] %>%
  levene_test(value ~ aud_group)

# conduct test
ttest7<-t.test(exploratory_clusters_alc$value[exploratory_clusters_alc$region == cluster] ~ exploratory_clusters_alc$aud_group[exploratory_clusters_alc$region == cluster], var.equal=TRUE)
ttest7
p.adjust(ttest7$p.value,n=4)

###### post-hoc t-test groups within jui reinforcer ######

# outliers
exploratory_clusters_jui[exploratory_clusters_jui$region==cluster,] %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
exploratory_clusters_jui[exploratory_clusters_jui$region==cluster,] %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(exploratory_clusters_jui[exploratory_clusters_jui$region==cluster,], x = "value", facet.by = "aud_group")

# homoscedasticity
exploratory_clusters_jui[exploratory_clusters_jui$region==cluster,] %>%
  levene_test(value ~ aud_group)

# conduct test
ttest8<-t.test(exploratory_clusters_jui$value[exploratory_clusters_jui$region == cluster] ~ exploratory_clusters_jui$aud_group[exploratory_clusters_jui$region == cluster], var.equal=TRUE)
ttest8
p.adjust(ttest8$p.value,n=4)

# create plot

fig_expl_clusters <- ggplot(exploratory_clusters, aes(x=fct_infreq(aud_group), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin(position = position_dodge(width = 0.9)) +
  geom_boxplot(width = 0.1, size=0.8,
               position = position_dodge(width = 0.9)) +
  facet_wrap(~region, scales="fixed") +
  xlab("AUD group") +
  ylab("Mean RPE-related activity") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 18, base_family = "Aptos") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        #axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="reinforcer", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_expl_clusters

ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Addiction Neuroscience/revision_1/Figures", "Figure_S6_violin_plots.png"), width = 24, height = 16, units='cm', dpi=1000, bg="white")

#########################################################################
###### Exploratory reward cluster activity per group and reinforcer type ######
#########################################################################

# structure data
reward_cluster <- reward_cluster %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("dlpfc_alc") ~ "alcohol",
                                combination %in% c("dlpfc_jui") ~ "juice"),
         reinforcer = as.factor(reinforcer))
contrasts(reward_cluster$aud_group) <- c(-0.5, 0.5)
contrasts(reward_cluster$reinforcer) <- c(0.5, -0.5)

reward_cluster_aud <- reward_cluster %>%
  filter(aud_group=="AUD")
reward_cluster_hc <- reward_cluster %>%
  filter(aud_group=="HC")
reward_cluster_alc <- reward_cluster %>%
  filter(reinforcer=="alcohol")
reward_cluster_jui <- reward_cluster %>%
  filter(reinforcer=="juice")

###### post-hoc t-test reinforcer type within aud group ###### 

# outliers
reward_cluster_aud %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
reward_cluster_aud %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(reward_cluster_aud, x = "value", facet.by = "reinforcer")

# conduct test
ttest9<-t.test(reward_cluster_aud$value[reward_cluster_aud$reinforcer=='alcohol'], reward_cluster_aud$value[reward_cluster_aud$reinforcer=='juice'], paired=TRUE)
ttest9
p.adjust(ttest9$p.value,n=4)

###### post-hoc t-test reinforcer type within hc group ###### 

reward_cluster_hc %>%
  group_by(reinforcer) %>%
  identify_outliers(value)

# normality
reward_cluster_hc %>%
  group_by(reinforcer) %>%
  shapiro_test(value)
ggqqplot(reward_cluster_hc, x = "value", facet.by = "reinforcer")

# conduct test
ttest10<-t.test(reward_cluster_hc$value[reward_cluster_hc$reinforcer=='alcohol'], reward_cluster_hc$value[reward_cluster_hc$reinforcer=='juice'], paired=TRUE)
ttest10
p.adjust(ttest10$p.value,n=4)

###### post-hoc t-test groups within alc reinforcer ###### 

# outliers
reward_cluster_alc %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
reward_cluster_alc %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(reward_cluster_alc, x = "value", facet.by = "aud_group")

# homoscedasticity
reward_cluster_alc %>%
  levene_test(value ~ aud_group)

# conduct test
ttest11<-t.test(reward_cluster_alc$value ~ reward_cluster_alc$aud_group, var.equal=TRUE)
ttest11
p.adjust(ttest11$p.value,n=4)

###### post-hoc t-test groups within jui reinforcer ######

# outliers
reward_cluster_jui %>%
  group_by(aud_group) %>%
  identify_outliers(value)

# normality
reward_cluster_jui %>%
  group_by(aud_group) %>%
  shapiro_test(value)
ggqqplot(reward_cluster_jui, x = "value", facet.by = "aud_group")

# homoscedasticity
reward_cluster_jui %>%
  levene_test(value ~ aud_group)

# conduct test
ttest12<-t.test(reward_cluster_jui$value ~ reward_cluster_jui$aud_group, var.equal=TRUE)
ttest12
p.adjust(ttest12$p.value,n=4)

# create plot

fig_reward_clusters <- ggplot(reward_cluster, aes(x=fct_infreq(reinforcer), y=value, fill=fct_rev(fct_infreq(reinforcer)))) +
  geom_violin(position = position_dodge(width = 0.9)) +
  geom_boxplot(width = 0.1, size=0.8,
               position = position_dodge(width = 0.9)) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("AUD group") +
  ylab("Mean reward-related activity") +
  ylim(-0.1, 0.1) +
  theme_light(base_size = 18, base_family = "Arial") +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("juice", "alcohol"),
                    palette = "Pastel1",
                    direction = -1)
fig_reward_clusters

ggsave(file.path("/Users/milenamusial/Library/CloudStorage/OneDrive-Charité-UniversitätsmedizinBerlin/PhD/04_B01/ILT/Manuscript/Addiction Neuroscience/revision_1/Figures", "Figure_reward_clusters_violin_plots.png"),
       width = 14, height =12, units='cm', dpi=1000, bg="white")


