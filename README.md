# Drug-related prediction error encoding in addiction

This repository contains all code used to produce the results in the manuscript 'Learning from Alcohol Rewards: Neural Signatures of Drug-Related Reward Prediction Errors in Alcohol Use Disorder'.

## 00_Experiment
Contains Matlab code of the Instrumental Learning Task performed during fMRI
## 01_Prepare_data
Contains R code used to prepare data frames used for behavioral, demographic, and computational modeling analyses
## 02_Demo
Contains R code inside a Quarto notebook used to perform demographic data analyses
## 03_Behav
Contains R Code inside a Quarto notebook used for behavioral data analysis
## 04_Comp_Modeling
Contains Stan code for computational models ('Models' folder), the output logfiles of the fitting procedure ('Output' folder), and R code (partially inside Quarto notebooks) used for fitting, for accessing fitting results, for cross-validation, for accessing model comparison results, for parameter recovery, for accessing parameter recovery results, and for accessing the estimated computational parameters ('Scripts' folder) 
## 05_fMRI
Contains Python code used for BIDS conversion, Bash (for fMRIprep) and Matlab code used for preprocessing, Matlab code used for 1st- and 2nd-level fMRI analyses, and R code used to calculate Bayes factors and plot 2nd-level results

If you have any questions, please contact milena.musial@charite.de.

*****
Milena Musial - 2025.
Material in this repository is not licensed.
*****