%-----------------------------------------------------------------------
% script unzippes and smoothes fmri prep functional output images
% MM 04-2024
% Job saved on 07-Jun-2022 22:29:36 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clc; clear;warning off;
addpath('C:\spm12')
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')

% =====================================================================
mainpath_preproc            = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\01_fmriprep_v23.2.1\';


gui=1 %open GUI
[subject fold2 names]=p_getSubFolder(mainpath_preproc, [],gui  ,'sep');

chktabl={};

for pb = 1:length(names)%subjects to run

    subject=strrep(names{pb},'\','');%name of subject

    subjectpath = fullfile(mainpath_preproc, subject, 'func');
    aid_file = [subject, '_task-aid_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];
    ilt1_file = [subject, '_task-ilt_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];
    ilt2_file = [subject, '_task-ilt_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];


    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = {
                                                                           fullfile(subjectpath, aid_file)
                                                                           fullfile(subjectpath, ilt1_file)
                                                                           fullfile(subjectpath, ilt2_file)
                                                                           };
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {''};
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;
    matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('Gunzip Files: Gunzipped Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
    matlabbatch{2}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{2}.spm.spatial.smooth.dtype = 0;
    matlabbatch{2}.spm.spatial.smooth.im = 0;
    matlabbatch{2}.spm.spatial.smooth.prefix = 'smoothed8mm_';

    %spm_jobman('run', jobs, '', matlabbatch);
    try
        spm('defaults', 'FMRI');
        spm_jobman('run',matlabbatch);
    catch
        chktabl(end+1,:)={subject};
    end

    clear matlabbatch
    
end %subject
