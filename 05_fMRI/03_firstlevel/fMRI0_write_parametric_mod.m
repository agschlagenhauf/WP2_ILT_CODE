%%%     SAVE PARAMETRIC MODULATORS FROM STAN AS MAT FILE PER SUBJECT AND
%%%     RUN 
%%%     MM 02-2024

close all; clear all;
addpath('C:\spm12')
addpath('C:\Users\musialm\Downloads\spm12')
addpath('C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_CODE\05_fMRI\functs')

main_path='S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\02_ILT\00_spm12_1st_level\PH_withC_n58_constant_feedback_+_sensoric_correctbaseline_compcor_correctPC_posnegPE_on_trial';

% load parametric modulators
PEs = readtable(fullfile(main_path, 'fmri_PEs_PH_withC_init05_n58.txt'));
pcs = readtable(fullfile(main_path, 'fmri_pcs_PH_withC_init05_n58.txt'));

block_PEs = cellstr(num2str(PEs.ID_block)); % Convert double values to strings
PEs.block = cell2mat(cellfun(@(x) x(8:8), block_PEs, 'UniformOutput', false)); % Extract the last character

block_pcs = cellstr(num2str(pcs.ID_block)); % Convert double values to strings
pcs.block = cell2mat(cellfun(@(x) x(8:8), block_pcs, 'UniformOutput', false)); % Extract the last character

ids=unique(cellstr(num2str(PEs.ID)));

for sub=1:length(ids)
% Make Einzelstats folder and save parametric modulators
   
    subject=['sub-', strtrim(ids{sub})];
     
    fold=fullfile(main_path, subject);
  
     if exist(fold)==0 % check if folder already exists
        mkdir( fold ); %make PBN-folder
     end
  
     subj_PEs = PEs(PEs.ID == str2num(ids{sub}), :);
     subj_PEs_block1 = table2array(subj_PEs(subj_PEs.block == '1', 1));
     subj_PEs_block2 = table2array(subj_PEs(subj_PEs.block == '2', 1));
     
     subj_pcs = pcs(pcs.ID == str2num(ids{sub}), :);
     subj_pcs_block1 = table2array(subj_pcs(subj_pcs.block == '1', 1));
     subj_pcs_block2 = table2array(subj_pcs(subj_pcs.block == '2', 1));
     
     save(fullfile(fold, [subject '_pmods_ilt1.mat']), 'subj_PEs_block1', 'subj_pcs_block1');
     save(fullfile(fold, [subject '_pmods_ilt2.mat']), 'subj_PEs_block2', 'subj_pcs_block2');

     clear subj_PEs subj_PEs_block1 subj_PEs_block2 subj_pcs subj_pcs_block1 subj_pcs_block2
     
end % subject