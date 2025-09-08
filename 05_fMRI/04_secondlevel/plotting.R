###### Preps ######

# clear
rm(list=ls())

#install.packages('tidyverse', 'plyr')
libs<-c("tidyverse", "R.matlab", "stringr", "dplyr", "ggplot2", "ggpubr")
sapply(libs, require, character.only=TRUE)

# define paths
data_path <- 'WP2_ILT_DATA'

nacc_main <- read.csv(file.path(data_path, "fMRI/PH_withC/MAIN_RPE_NAcc_per_reinforcer_across_groups_t1.txt"))
load(file.path(data_path, "Behav/behav_final_redcap_n56.RData"))

###### Main Plot: NAcc activity per group and reinforcer type ######

# structure data
nacc_main <- nacc_main %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
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
  ylab("Mean RPE-related activity \n in left VS") +
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
  ylab("Mean RPE-related activity \n in right VS") +
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
          labels = c("C", "D"),
          ncol = 2, nrow = 1,
          common.legend = TRUE, legend="bottom")

png(file.path("Manuscript/Figures", "NAcc_main.png"), width = 18, height = 10, units='cm', res = 600)
main_peak_plot
dev.off()

