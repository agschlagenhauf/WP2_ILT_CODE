%%%     SAVE PARAMETRIC MODULATORS FROM STAN AS MAT FILE PER SUBJECT AND
%%%     RUN 
%%%     MM 02-2024

close all; clear all;
addpath('C:\spm12')
addpath('C:\Users\musialm\Downloads\spm12')
addpath('C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_CODE\05_fMRI\functs')

main_path='S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\02_ILT\00_spm12_1st_level\PH_withC_n58_constant_feedback_+_sensoric_correctbaseline_compcor_correctPC_winloss_Q';

% load parametric modulators
Qs = readtable(fullfile(main_path, 'fmri_Qs_PH_withC_init05_n58.txt'));

block_Qs = cellstr(num2str(Qs.ID_block)); % Convert double values to strings
Qs.block = cell2mat(cellfun(@(x) x(8:8), block_Qs, 'UniformOutput', false)); % Extract the last character

ids=unique(cellstr(num2str(Qs.ID)));

for sub=1:length(ids)
% Make Einzelstats folder and save parametric modulators
   
    subject=['sub-', strtrim(ids{sub})];
     
    fold=fullfile(main_path, subject);
  
     if exist(fold)==0 % check if folder already exists
        mkdir( fold ); %make PBN-folder
     end
  
     subj_Qs = Qs(Qs.ID == str2num(ids{sub}), :);
     subj_Qs_block1 = table2array(subj_Qs(subj_Qs.block == '1', 1));
     subj_Qs_block2 = table2array(subj_Qs(subj_Qs.block == '2', 1));
     
     save(fullfile(fold, [subject '_pmods_ilt1.mat']), 'subj_Qs_block1');
     save(fullfile(fold, [subject '_pmods_ilt2.mat']), 'subj_Qs_block2');

     clear subj_Qs subj_Qs_block1 subj_Qs_block2
     
end % subject