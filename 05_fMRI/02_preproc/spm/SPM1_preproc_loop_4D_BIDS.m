%%% CREATING SPM PREPROCESSING JOBS FOR BIDS FORMATTED DATA %%%%%%
%%% MILENA MUSIAL 21/07/2023 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear;warning off;

addpath('C:\spm12')
%spm fmri;

main_path            = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\04_derivatives_spm';
list_sub_data_paths = spm_select(inf, 'dir', 'choose subjects for preprocessing','',  main_path);

chktabl={};  

  for sub = 1:size(list_sub_data_paths,1)%subjects to run
     
    tic % take time
    s                   = strread(list_sub_data_paths(sub,:), '%s','delimiter', '\\');
    subjects{sub}       = s{end}; % subject name
    sub_path            = {list_sub_data_paths(sub,:)};
    sub_func_path       = cellstr(fullfile(list_sub_data_paths(sub,:), 'func'));
    
    sub_anat_file          = cellstr(spm_select('FPlist', fullfile(list_sub_data_paths(sub,:),...
                                    'anat'), '^sub.*\.nii$'));    
    file_name_phase        = cellstr(spm_select('FPlist', fullfile(list_sub_data_paths(sub,:),...
                                    'fmap'), '^sub.*\phasediff.nii$'));
    file_name_magnitude    = cellstr(spm_select('FPlist', fullfile(list_sub_data_paths(sub,:), ...
                                    'fmap'), '^sub.*magnitude1.nii$'));
    cd(sub_func_path{1});    

%-----------------------------------------------------------------------
% Job saved on 22-Mar-2024 17:40:15 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'anat';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {sub_anat_file};
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.dir = sub_func_path;
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '.*task-ilt_run-1_bold.nii$';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_fplist.dir = sub_func_path;
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '.*task-aid_bold.nii$';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.dir = sub_func_path;
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '.*task-ilt_run-2_bold.nii$';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{5}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (.*task-ilt_run-1_bold.nii$)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{5}.spm.util.exp_frames.frames = 1;
matlabbatch{6}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (.*task-ilt_run-2_bold.nii$)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{6}.spm.util.exp_frames.frames = 1;
matlabbatch{7}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (.*task-aid_bold.nii$)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{7}.spm.util.exp_frames.frames = 1;
matlabbatch{8}.spm.temporal.st.scans{1}(1) = cfg_dep('File Selector (Batch Mode): Selected Files (.*task-ilt_run-1_bold.nii$)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{8}.spm.temporal.st.scans{2}(1) = cfg_dep('File Selector (Batch Mode): Selected Files (.*task-ilt_run-2_bold.nii$)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{8}.spm.temporal.st.scans{3}(1) = cfg_dep('File Selector (Batch Mode): Selected Files (.*task-aid_bold.nii$)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{8}.spm.temporal.st.nslices = 60;
matlabbatch{8}.spm.temporal.st.tr = 0.869;
matlabbatch{8}.spm.temporal.st.ta = 0.854516666666667;
matlabbatch{8}.spm.temporal.st.so = [0 0.595 0.34 0.085 0.68 0.425 0.17 0.7625 0.51 0.255 0 0.595 0.34 0.085 0.68 0.425 0.17 0.7625 0.51 0.255 0 0.595 0.34 0.085 0.68 0.425 0.17 0.7625 0.51 0.255 0 0.595 0.34 0.085 0.68 0.425 0.17 0.7625 0.51 0.255 0 0.595 0.34 0.085 0.68 0.425 0.17 0.7625 0.51 0.255 0 0.595 0.34 0.085 0.68 0.425 0.17 0.7625 0.51 0.255];
matlabbatch{8}.spm.temporal.st.refslice = 0;
matlabbatch{8}.spm.temporal.st.prefix = 'a';
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = file_name_phase;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = file_name_magnitude;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = [5.19 7.65];
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = -1;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 60.0301;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = {'E:\MATLAB2023a\toolbox\spm12\toolbox\FieldMap\T1.nii'};
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.session(1).epi(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.session(2).epi(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.session(3).epi(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
matlabbatch{9}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
matlabbatch{10}.spm.spatial.realignunwarp.data(1).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{10}.spm.spatial.realignunwarp.data(1).pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 1)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{1}));
matlabbatch{10}.spm.spatial.realignunwarp.data(2).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files'));
matlabbatch{10}.spm.spatial.realignunwarp.data(2).pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 2)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{2}));
matlabbatch{10}.spm.spatial.realignunwarp.data(3).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 3)', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{3}, '.','files'));
matlabbatch{10}.spm.spatial.realignunwarp.data(3).pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 3)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{3}));
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.rtm = 0;
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.einterp = 2;
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
matlabbatch{10}.spm.spatial.realignunwarp.eoptions.weight = '';
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{10}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
matlabbatch{10}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{10}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{10}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{10}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{10}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
matlabbatch{11}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Named File Selector: anat(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{11}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{11}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{11}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{11}.spm.spatial.preproc.tissue(1).tpm = {'C:\spm12\tpm\TPM.nii,1'};
matlabbatch{11}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{11}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{11}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{11}.spm.spatial.preproc.tissue(2).tpm = {'C:\spm12\tpm\TPM.nii,2'};
matlabbatch{11}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{11}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{11}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{11}.spm.spatial.preproc.tissue(3).tpm = {'C:\spm12\tpm\TPM.nii,3'};
matlabbatch{11}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{11}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{11}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{11}.spm.spatial.preproc.tissue(4).tpm = {'C:\spm12\tpm\TPM.nii,4'};
matlabbatch{11}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{11}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{11}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{11}.spm.spatial.preproc.tissue(5).tpm = {'C:\spm12\tpm\TPM.nii,5'};
matlabbatch{11}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{11}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{11}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{11}.spm.spatial.preproc.tissue(6).tpm = {'C:\spm12\tpm\TPM.nii,6'};
matlabbatch{11}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{11}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{11}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{11}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{11}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{11}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{11}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{11}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{11}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{11}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{11}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{11}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{12}.cfg_basicio.file_dir.cfg_fileparts.files(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{13}.spm.util.imcalc.input(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{13}.spm.util.imcalc.input(2) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{13}.spm.util.imcalc.input(3) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
matlabbatch{13}.spm.util.imcalc.input(4) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
matlabbatch{13}.spm.util.imcalc.output = 'brain';
matlabbatch{13}.spm.util.imcalc.outdir(1) = cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
matlabbatch{13}.spm.util.imcalc.expression = '(i2+i3+i4).*i1';
matlabbatch{13}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{13}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{13}.spm.util.imcalc.options.mask = 0;
matlabbatch{13}.spm.util.imcalc.options.interp = 1;
matlabbatch{13}.spm.util.imcalc.options.dtype = 4;
matlabbatch{14}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
matlabbatch{14}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Image Calculator: ImCalc Computed Image: brain', substruct('.','val', '{}',{13}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{14}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{15}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{15}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
matlabbatch{15}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 2)', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','uwrfiles'));
matlabbatch{15}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 3)', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{3}, '.','uwrfiles'));
matlabbatch{15}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                           78 76 85];
matlabbatch{15}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{15}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{15}.spm.spatial.normalise.write.woptions.prefix = 'w';
matlabbatch{16}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{15}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{16}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{16}.spm.spatial.smooth.dtype = 0;
matlabbatch{16}.spm.spatial.smooth.im = 0;
matlabbatch{16}.spm.spatial.smooth.prefix = 's6';
matlabbatch{17}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{17}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{17}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                           78 76 85];
matlabbatch{17}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{17}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{17}.spm.spatial.normalise.write.woptions.prefix = 'w';
matlabbatch{18}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{17}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{18}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{18}.spm.spatial.smooth.dtype = 0;
matlabbatch{18}.spm.spatial.smooth.im = 0;
matlabbatch{18}.spm.spatial.smooth.prefix = 's6';
matlabbatch{19}.spm.util.imcalc.input(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{18}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{19}.spm.util.imcalc.output = 'binary_brainmask';
matlabbatch{19}.spm.util.imcalc.outdir(1) = cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
matlabbatch{19}.spm.util.imcalc.expression = 'i1>10';
matlabbatch{19}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{19}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{19}.spm.util.imcalc.options.mask = 0;
matlabbatch{19}.spm.util.imcalc.options.interp = 1;
matlabbatch{19}.spm.util.imcalc.options.dtype = 4;


    try
        filename = fullfile(sub_path, ['job_preproc_' subjects{sub} '.mat']);
        save(char(filename), 'matlabbatch');
    catch
        chktabl(end+1,:)={ sub_path   subjects{sub}  };
    end
    
    clear matlabbatch
    
    toc % take time

end %subject