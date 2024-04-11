##### Preparation #####

# import packages
rm(list=ls())
libs<-c("loo")
sapply(libs, require, character.only=TRUE)

###### define sample #####

sample <- 'n56' # n71, n53, n50

######
datapath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_DATA"
filepath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_Stan_Modeling"

##### Read input #####
if (sample == 'n71') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n71.txt'), header = T)
} else if (sample == 'n63') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n63.txt'), header = T)
} else if (sample == 'n60') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n60.txt'), header = T)
} else if (sample == 'n56') {
  #input<-read.table(file.path(datapath, 'Input/Stan_input_n56.txt'), header = T)
  input_h<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n56.txt'), header = T)
} else if (sample == 'n53') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n53.txt'), header = T)
} else if (sample == 'n50') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_n50.txt'), header = T)
} else if (sample == 'n60_aud') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_aud_n60.txt'), header = T)
} else if (sample == 'n60_hc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hc_n60.txt'), header = T)
} else if (sample == 'n56_aud') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_aud_n56.txt'), header = T)
} else if (sample == 'n56_hc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hc_n56.txt'), header = T)
} else if (sample == 'n56_aud_jui') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_jui_aud_n56.txt'), header = T)
} else if (sample == 'n56_hc_jui') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_jui_hc_n56.txt'), header = T)
} else if (sample == 'n56_aud_alc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_alc_aud_n56.txt'), header = T)
} else if (sample == 'n56_hc_alc') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_alc_hc_n56.txt'), header = T)
}

##### split data into 10 folds #####
fold <- kfold_split_grouped(K = 10, x = input_h$subjID)

write.table(fold, file = file.path(datapath, 'Input/fold_for_CV_n56.txt'), append = FALSE, sep = " ", dec = ".",
            row.names = F, col.names = F)
