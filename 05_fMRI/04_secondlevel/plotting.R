###### Preps ######

# clear
rm(list=ls())

#install.packages('tidyverse', 'plyr')
libs<-c("tidyverse", "R.matlab", "stringr", "dplyr", "ggplot2", "ggpubr")
sapply(libs, require, character.only=TRUE)

# define paths
data_path <- 'C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/WP2_ILT_DATA'

nacc_main <- read.csv(file.path(data_path, "fMRI/PH_withC/extracted_values_and_maps/RPE_-8_21_-8_per_rtype.txt"))
load(file.path(data_path, "Behav/behav_final_redcap_n56.RData"))

###### Main Plot: NAcc activity per group and reinforcer type ######

# structure data
nacc_main <- nacc_main %>%
  mutate(ID = c(1:56),
         aud_group = factor(c(rep("HC",28), rep("AUD",28)), levels = c("HC", "AUD"))) %>%
  pivot_longer(!c("ID", "aud_group"), names_to = "combination", values_to = "value") %>%
  mutate(combination = as.factor(combination),
         reinforcer = case_when(combination %in% c("RPE_alc") ~ "alcohol",
                                combination %in% c("RPE_jui") ~ "juice"))

fig_main <- ggplot(nacc_main, aes(x=reinforcer, y=value, fill=reinforcer)) +
  geom_violin() +
  geom_boxplot(width = 0.1, size=0.8) +
  facet_wrap(~aud_group, scales="fixed") +
  xlab("group") +
  ylab("Mean RPE-related activity \n in left VS peak") +
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

png(file.path("C:/Users/musialm/OneDrive - Charité - Universitätsmedizin Berlin/PhD/04_B01/ILT/Manuscript/Figures", "NAcc_main.png"), width = 15, height = 10, units='cm', res = 600)
fig_main
dev.off()

