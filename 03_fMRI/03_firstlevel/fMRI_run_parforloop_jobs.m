% script to run first level SPM jobs with parfor
addpath ('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP1_fMRI\Scripts\functs')
clear all
% =====================================================================
einzelstatspath = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP1_fMRI\einzelstats_Daw_7params_separate_onsets_02thresh';

% =====================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select Subjects from GUI
gui=1; %open GUI
[subject fold2, names]=p_getSubFolder(einzelstatspath, [], gui  ,'sep');

% built full names and paths of jobs for selected subjects 
for pb = 1:length(names)                        %subjects to run
    subject = regexprep(names{pb},'\' ,'');     %name of subject
    subject_id=regexprep(subject, 'sub-', '');
    job_names{pb} = fullfile(einzelstatspath, subject, ['job_1st_level_' subject '.mat']);
end

spm('defaults', 'FMRI');
% defaults.stats.maxmem      = 2^36; % changed from 2^30
% defaults.stats.resmem      = false; % changed from false - temorary files are not stored on disk but kept in memory

parfor pb = 1:length(names)
    try
    sprintf('started:%s/n', job_names{pb})    
    spm_jobman('run',job_names{pb});
    catch
    end
end 