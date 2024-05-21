

%%% CREATING BINARY BRAIN MASK BASED ON SMOOTHED ANATOMICAL IMAGE %%%%%%
%%% MILENA MUSIAL 01.03.2024 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    %sub_anat_path       = cellstr(fullfile(list_sub_data_paths(sub,:), 'anat'));
    
    sub_anat_file          = cellstr(spm_select('FPlist', fullfile(list_sub_data_paths(sub,:),...
                                    'anat'), '^s6wbrain.nii$'));    
    %cd(sub_anat_file);    

%%%% BATCH %%%%
    
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'anat';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {sub_anat_file};
matlabbatch{2}.cfg_basicio.file_dir.cfg_fileparts.files(1) = cfg_dep('Named File Selector: anat(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{3}.spm.util.imcalc.input(1) = cfg_dep('Named File Selector: anat(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{3}.spm.util.imcalc.output = 'binary_brainmask';
matlabbatch{3}.spm.util.imcalc.outdir(1) = cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
matlabbatch{3}.spm.util.imcalc.expression = 'i1>10';
matlabbatch{3}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{3}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{3}.spm.util.imcalc.options.mask = 0;
matlabbatch{3}.spm.util.imcalc.options.interp = 1;
matlabbatch{3}.spm.util.imcalc.options.dtype = 4;

try
        filename = fullfile(sub_path, ['job_binary_brainmask_' subjects{sub} '.mat']);
        save(char(filename), 'matlabbatch');
    catch
        chktabl(end+1,:)={ sub_path   subjects{sub}  };
    end
    
    clear matlabbatch
    
    toc % take time

end %subject
