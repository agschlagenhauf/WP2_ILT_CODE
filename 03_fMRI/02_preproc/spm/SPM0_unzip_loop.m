%%% UNZIPPING BIDS FILES %%%%%%
%%% MILENA MUSIAL 07/2023 %%%%%

clc; clear;warning off;
addpath('C:\spm12')
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\03_bids')
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')
mainpath_preproc = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\04_derivatives_spm';

gui=1; %open GUI
[subject, fold2, names]=p_getSubFolder(mainpath_preproc, [],gui  ,'sep');

for pb = 1:length(names)% subject loop
    subject=strrep(names{pb},'\',''); % name of subject
    subj_fold_name = char(subject);

    path_anat         =fullfile(mainpath_preproc, subject, 'anat\');
    path_func         =fullfile(mainpath_preproc, subject, 'func\');
    path_fmap         =fullfile(mainpath_preproc, subject, 'fmap\');
    paths = {path_anat, path_func, path_fmap};
    
    for pt = 1:length(paths) % subpath loop (anat/func/fmap)
        path = strrep(paths{pt},'', '');
        
        if path == path_anat
            exts = {'T1w.nii.gz'};
            path_fold_name = char('anat');
        elseif path == path_func
            exts = {'task-aid_bold.nii.gz', 'task-ilt_run-1_bold.nii.gz', 'task-ilt_run-2_bold.nii.gz'};
            task_names = {'task-faces', 'task-restingstate', 'task-reversal', 'task-self'};
            path_fold_name = char('func');
        elseif path == path_fmap
            exts = {'magnitude1.nii.gz', 'magnitude2.nii.gz', 'phasediff.nii.gz'};
            path_fold_name = char('fmap');
        end
        
        for ext = 1:length(exts) % file (extension) loop 
            extension=strrep(exts{ext},'\','');
            %[nomatter,nii_name]=fileparts(extension);
            %[notmatter,base_name]=fileparts(nii_name);
            
            zipped = fullfile(path, [subject, '_', extension]);

            %Unzip all zipped files in all folders
            matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = {zipped};
            matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {path};
            matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;

            % run job
            try
                spm_jobman('run',matlabbatch);
            end

        end % file extension loop

    end % subpath loop

end % subject loop