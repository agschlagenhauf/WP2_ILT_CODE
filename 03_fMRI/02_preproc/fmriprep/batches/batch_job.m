%-----------------------------------------------------------------------
% Job saved on 05-Apr-2024 19:43:35 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = {
                                                                       'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\fmriprep_v23.2.1\sub-11475\func\sub-11475_task-aid_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
                                                                       'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\fmriprep_v23.2.1\sub-11475\func\sub-11475_task-ilt_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
                                                                       'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\fmriprep_v23.2.1\sub-11475\func\sub-11475_task-ilt_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
                                                                       };
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\fmriprep_v23.2.1\sub-11475\func'};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;
matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('Gunzip Files: Gunzipped Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
matlabbatch{2}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 'smoothed6mm_';
