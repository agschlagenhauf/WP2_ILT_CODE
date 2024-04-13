##### Preparation #####

# import packages
rm(list=ls())
libs<-c("loo")
sapply(libs, require, character.only=TRUE)

###### define sample #####

sample <- 'n58' # n71, n53, n50

######
datapath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_DATA"
filepath<-"/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/ILT_Stan_Modeling"

##### Read input #####
if (sample == 'n71') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n71.txt'), header = T)
} else if (sample == 'n58') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n58.txt'), header = T)
} else if (sample == 'n56') {
  input<-read.table(file.path(datapath, 'Input/Stan_input_hierarchical_n56.txt'), header = T)
} 

##### split data into 10 folds #####
fold <- kfold_split_grouped(K = 10, x = input$subjID)

write.table(fold, file = file.path(datapath, paste('Input/fold_for_CV_', sample, '.txt', sep ="")), append = FALSE, sep = " ", dec = ".",
            row.names = F, col.names = F)
