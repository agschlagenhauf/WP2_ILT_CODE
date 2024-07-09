###### Preps ######

# clear
rm(list=ls())

#install.packages('tidyverse', 'plyr')
libs<-c("tidyverse", "R.matlab", "stringr", "dplyr", "ggplot2", "ggpubr")
sapply(libs, require, character.only=TRUE)

# define paths
second_level_path <- 'C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_DATA/fMRI'

nacc <- read.csv(file.path(second_level_path, "peak_values", "nacc_per_reinforcer_type.txt", na.strings=""))

# plot
nacc <- nacc %>%
  mutate(ID = c(1:56),
         aud_group = as.factor(c(rep("HC",28), rep("AUD",28)))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("alc_left", "alc_right") ~ "alcohol",
                                combination %in% c("jui_left", "jui_right") ~ "juice"),
         region = case_when(combination %in% c("alc_left", "jui_left") ~ "left_Nacc",
                            combination %in% c("jui_right", "alc_right") ~ "right_Nacc"))

nacc_left <- nacc %>%
  filter(region == "left_Nacc")
nacc_right <- nacc %>%
  filter(region == "right_Nacc")

fig_left_nacc <- ggplot(nacc_left, aes(x=reinforcer, y=value, fill=reinforcer)) +
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

fig_right_nacc <- ggplot(nacc_right, aes(x=reinforcer, y=value, fill=reinforcer)) +
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

peak_plot <- ggarrange(fig_left_nacc, fig_right_nacc,
          labels = c("B", "C"),
          ncol = 2, nrow = 1,
          common.legend = TRUE, legend="bottom")

png("NAcc_peak.png", width = 18, height = 10, units='cm', res = 600)
peak_plot
dev.off()
