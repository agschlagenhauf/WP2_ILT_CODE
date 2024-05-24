% Subject loop Einzelstatistik 2-step data
% CE 22-06-22 ---------------------------------------------------------------------

% Job saved on 21-Jun-2022 16:49:40 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

clc; 
clear;
warning off;
addpath('C:\spm12')
addpath('C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_CODE\03_fMRI\functs')

% define paths
paMeta_epi = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\01_fmriprep_v23.2.1';
einzelstatspath= 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\02_spm12_1st_level\PH_withC_group_n58';

TR=0.869; % in sec

gui=1 %open GUI
[subject fold2, names] = p_getSubFolder(paMeta_epi, [],gui  ,'sep');

chktabl={};    

%%
for pb = 1:length(names)%subjects to run
    
    subject = regexprep(names{pb},'\' ,''); % name of subject
    subject_id = regexprep(subject, 'sub-', '');

    %PATH OF subjects CONDITIONFILE
    condfilepath = fullfile(einzelstatspath, subject);

    %get CONDTION-MATFILE
    [condfiles, dum] = spm_select('FPList', condfilepath , '_cond.*\mat');
    condfile_run1 = condfiles(1,:);
    condfile_run2 = condfiles(2,:);

    %get EPIs
    epifolder = fullfile(paMeta_epi, subject, 'func');
    epis = spm_select('FPList', epifolder, '^smoothed8mm.*ilt.*.nii');
    epi_run1 = epis(1,:);
    epi_run2 = epis(2,:);
    
    % get RP file
    rpfiles = spm_select('FPList', epifolder, '^RP.*ilt.*.mat');
    rp_run1 = load(rpfiles(1,:));
    n_volumes_of_interest_run1 = length(rp_run1.R);
    rp_run2 = load(rpfiles(2,:));
    n_volumes_of_interest_run2 = length(rp_run2.R);

    % use binary brain mask for explicit masking
    mask_path = fullfile(paMeta_epi, subject, 'anat', [subject '_space-MNI152NLin2009cAsym_desc-brain_mask.nii']);

    %% matlabbatch
    matlabbatch{1}.spm.util.exp_frames.files = {epi_run1};
    matlabbatch{1}.spm.util.exp_frames.frames = [1:n_volumes_of_interest_run1];

    matlabbatch{2}.spm.util.exp_frames.files = {epi_run2};
    matlabbatch{2}.spm.util.exp_frames.frames = [1:n_volumes_of_interest_run2];

    matlabbatch{3}.spm.stats.fmri_spec.dir = {condfilepath};
    matlabbatch{3}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{3}.spm.stats.fmri_spec.timing.RT = 0.869;
    matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t = 60;
    matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t0 = 30;

    matlabbatch{3}.spm.stats.fmri_spec.sess(1).scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{3}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{3}.spm.stats.fmri_spec.sess(1).multi = {condfile_run1};
    matlabbatch{3}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{3}.spm.stats.fmri_spec.sess(1).multi_reg = {rp_run1};
    matlabbatch{3}.spm.stats.fmri_spec.sess(1).hpf = 128;

    matlabbatch{3}.spm.stats.fmri_spec.sess(2).scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{3}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{3}.spm.stats.fmri_spec.sess(2).multi = {condfile_run2};
    matlabbatch{3}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    matlabbatch{3}.spm.stats.fmri_spec.sess(2).multi_reg = {rp_run2};
    matlabbatch{3}.spm.stats.fmri_spec.sess(2).hpf = 128;

    matlabbatch{3}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{3}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; % change to 1 0?
    matlabbatch{3}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{3}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{3}.spm.stats.fmri_spec.mthresh = 0.2;
    matlabbatch{3}.spm.stats.fmri_spec.mask = {mask_path};
    matlabbatch{3}.spm.stats.fmri_spec.cvi = 'AR(1)';

    matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;

    %%
    try
        spm('defaults', 'FMRI');
        spm_jobman('run',matlabbatch);
    catch
        chktabl(end+1,:)={ einzelstatspath   subject  };

    end

    clear matlabbatch

end %subject