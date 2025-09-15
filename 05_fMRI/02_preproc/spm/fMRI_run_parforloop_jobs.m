%%%%% RUNNING PREDEFINED PREPROCESSING SPM JOBS %%%%%
%%%%% MILENA MUSIAL 21/07/2023 %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath ('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')
addpath('C:\spm12')
clear all
% =====================================================================
preprocpath = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\04_derivatives_spm';

% =====================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select Subjects from GUI
gui=1; %open GUI
[subject fold2, names]=p_getSubFolder(preprocpath, [], gui  ,'sep');

% built full names and paths of jobs for selected subjects 
for pb = 1:length(names)                        %subjects to run
    subject = regexprep(names{pb},'\' ,'');     %name of subject
    subject_id=regexprep(subject, 'sub-', '');
    job_names{pb} = fullfile(preprocpath, subject, ['job_preproc_' subject '.mat']);
end

spm('defaults', 'FMRI');

for pb = 1:length(names)
    sprintf('started:%s/n', job_names{pb})
    try
        spm_jobman('run',job_names{pb});
    end
end 