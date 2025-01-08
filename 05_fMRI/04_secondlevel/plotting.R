###### Preps ######

# clear
rm(list=ls())

#install.packages('tidyverse', 'plyr')
libs<-c("tidyverse", "R.matlab", "stringr", "dplyr", "ggplot2", "ggpubr")
sapply(libs, require, character.only=TRUE)

# define paths
data_path <- 'WP2_ILT_DATA'

nacc_main <- read.csv(file.path(data_path, "fMRI/PH_withC/MAIN_RPE_NAcc_per_reinforcer_across_groups.txt"))
nacc_atc <- read.csv(file.path(data_path, "fMRI/PH_withC/ATC_RPE_NAcc_per_reinforcer_across_groups.txt"))
load(file.path(data_path, "Behav/behav_final_redcap_n56.RData"))

###### Main Plot: NAcc activity per group and reinforcer type ######

# structure data
nacc_main <- nacc_main %>%
  mutate(ID = c(1:56),
         aud_group = as.factor(c(rep("HC",28), rep("AUD",28)))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("alc_left_nacc", "alc_right_nacc") ~ "alcohol",
                                combination %in% c("jui_left_nacc", "jui_right_nacc") ~ "juice"),
         region = case_when(combination %in% c("alc_left_nacc", "jui_left_nacc") ~ "left_Nacc",
                            combination %in% c("jui_right_nacc", "alc_right_nacc") ~ "right_Nacc"))

nacc_main_left <- nacc_main %>%
  filter(region == "left_Nacc")
nacc_main_right <- nacc_main %>%
  filter(region == "right_Nacc")

fig_main_left_nacc <- ggplot(nacc_main_left, aes(x=reinforcer, y=value, fill=reinforcer)) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean RPE-related activity \n Left NAcc") +
  ylim(-0.1, 0.08) +
  theme_light(base_size = 18) +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("alcohol", "juice"),
                    palette = "Accent")

fig_main_right_nacc <- ggplot(nacc_main_right, aes(x=reinforcer, y=value, fill=reinforcer)) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean RPE-related activity \n Right NAcc") +
  ylim(-0.1, 0.08) +
  theme_light(base_size = 18) +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("alcohol", "juice"),
                    palette = "Accent")

main_peak_plot <- ggarrange(fig_main_left_nacc, fig_main_right_nacc,
          labels = c("B", "C"),
          ncol = 2, nrow = 1,
          common.legend = TRUE, legend="bottom")

png("NAcc_main.png", width = 18, height = 10, units='cm', res = 600)
main_peak_plot
dev.off()

###### Exploratory plot: Correlation NAcc alc>jui in AUD - psychometric measures

# structure data
nacc_atc <- nacc_atc %>%
  mutate(ID = c(1:56),
         aud_group = as.factor(c(rep("HC",28), rep("AUD",28)))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("left_nacc_alc", "right_nacc_alc") ~ "alcohol",
                                combination %in% c("left_nacc_jui", "right_nacc_jui") ~ "juice"),
         region = case_when(combination %in% c("left_nacc_alc", "left_nacc_jui") ~ "left_Nacc",
                            combination %in% c("right_nacc_jui", "right_nacc_alc") ~ "right_Nacc"))

nacc_atc_left <- nacc_atc %>%
  filter(region == "left_Nacc")
nacc_atc_right <- nacc_atc %>%
  filter(region == "right_Nacc")

fig_atc_left_nacc <- ggplot(nacc_atc_left, aes(x=reinforcer, y=value, fill=reinforcer)) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean RPE-related activity \n Left NAcc") +
  ylim(-0.1, 0.08) +
  theme_light(base_size = 18) +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("alcohol", "juice"),
                    palette = "Accent")

fig_atc_right_nacc <- ggplot(nacc_atc_right, aes(x=reinforcer, y=value, fill=reinforcer)) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean RPE-related activity \n Right NAcc") +
  ylim(-0.1, 0.08) +
  theme_light(base_size = 18) +
  theme(legend.position = "right") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position = "bottom") +
  scale_fill_brewer(name="Reinforcer type", 
                    labels=c("alcohol", "juice"),
                    palette = "Accent")

atc_peak_plot <- ggarrange(fig_atc_left_nacc, fig_atc_right_nacc,
                            labels = c("B", "C"),
                            ncol = 2, nrow = 1,
                            common.legend = TRUE, legend="bottom")

png("NAcc_atc.png", width = 18, height = 10, units='cm', res = 600)
atc_peak_plot
dev.off()
