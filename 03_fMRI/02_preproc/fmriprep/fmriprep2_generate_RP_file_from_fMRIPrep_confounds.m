% generate_RP_file_from_fMRIPrep_confounds
% reads realignment variables from the confound file
%  created by fMRIPrep, e.g. '...desc-confounds_timeseries.tsv'.
% The variables are saved in a mat file, which contains the variables 'names' and 'R'. 
% This mat file can then be imported with the multiple regressors option during first level
% stats in SPM.
% FS 14.06.22

clear all; clc;
addpath('C:\spm12')
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')

mainpath='S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\01_fmriprep_v23.2.1'; 
behav_data='S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\sourcedata\behav\REDCap\AID_ILT\FilesReport_ILTandAIDdata_2024-04-08_1700\documents';

gui=1 %open GUI
[subject fold2 subnames]=p_getSubFolder(mainpath, [],gui  ,'sep');

tasknames = {'task-aid', 'task-ilt_run-1', 'task-ilt_run-2'};

TR=0.869; % in sec

%% subject loop
for pb = 1:length(subnames)
    
   subject=strrep(subnames{pb},'\','');%name of subject
   
   % load vd data to get individual paradigm length (in oder to cut redundant vols in rp file)
   id=strrep(subject, 'sub-', '');

   try
       behav_aid = dir2([behav_data ['\' id '_termin_1_fmrt_arm_1_b01_wp2_aid03.mat']]);
       behav_ilt3 = dir2([behav_data ['\' id '_termin_1_fmrt_arm_1_b01_wp2_ilt03.mat']]);
       behav_ilt4 = dir2([behav_data ['\' id '_termin_1_fmrt_arm_1_b01_wp2_ilt04.mat']]);

       D_aid=load(fullfile(behav_data, behav_aid.name));
       D_ilt3=load(fullfile(behav_data, behav_ilt3.name));
       D_ilt4=load(fullfile(behav_data, behav_ilt4.name));

       % write ILT block number into data structure
       if D_ilt3.ord == 1 % ord 1 = S-A, ord 2 = A-S
           if D_ilt3.Drink_Type == 'J'
               D_ilt3.block = 1;
           elseif D_ilt3.Drink_Type == 'A'
               D_ilt3.block = 2;
           end
       elseif D_ilt3.ord == 2
           if D_ilt3.Drink_Type == 'J'
               D_ilt3.block = 2;
           elseif D_ilt3.Drink_Type == 'A'
               D_ilt3.block = 1;
           end
       end

       if D_ilt4.ord == 1 % ord 1 = S-A, ord 2 = A-S
           if D_ilt4.Drink_Type == 'J'
               D_ilt4.block = 1;
           elseif D_ilt4.Drink_Type == 'A'
               D_ilt4.block = 2;
           end
       elseif D_ilt4.ord == 2
           if D_ilt4.Drink_Type == 'J'
               D_ilt4.block = 2;
           elseif D_ilt4.Drink_Type == 'A'
               D_ilt4.block = 1;
           end
       end

       % rename files
       if D_ilt3.block == 1 && D_ilt4.block == 2
           D_ilt1 = D_ilt3;
           D_ilt2 = D_ilt4;
       elseif D_ilt3.block == 2 && D_ilt4.block == 1
           D_ilt1 = D_ilt4;
           D_ilt2 = D_ilt3;
       end

       clear D_ilt3 D_ilt4
   
   end
   %% task loop
   for taskname = 1:length(tasknames)
       
       try
           
           task = tasknames{taskname};

           % read in fmriprep confounds file per task
           confounds_file=fullfile(mainpath, subject, 'func',  [subject, '_', task, '_desc-confounds_timeseries.tsv']);
           fprintf('reading %s \n', confounds_file)   

           % create output file name
           outputname = ['RP_', subject, '_', task, '.mat'];

           % load behavioral file per task
           if strcmp(task,'task-aid')
               D = D_aid;
           elseif strcmp(task,'task-ilt1')
               D = D_ilt1;
           elseif strcmp(task,'task-ilt2')
               D = D_ilt2;
           end

           % get number of vols of interest based on begin time, end time, TR
           volumes_of_interest=round((D.T.end_end_baseline-D.T.baseline_start)/TR);  

           % names of the variables to be read from the tsv file 
           var_names={'trans_x', 'trans_x_derivative1', 'trans_x_derivative1_power2', 'trans_x_power2', ...
                      'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', ...
                      'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', ...
                      'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2',  ...
                      'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', ...
                      'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2' };

    %        var_names1 =    {'trans_x', 'trans_x_derivative1', 'trans_x_derivative1_power2', 'trans_x_power2', ...
    %                         'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', ...
    %                         'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', ...
    %                         'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2',  ...
    %                         'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', ...
    %                         'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2' };

           % get number of variables in the fMRIPrep confounds tsv file
           % because the number of columns is different between subjects
           all_lines       = readlines(confounds_file);    % read in whole tsv file
           variable_names  = strread(all_lines(1), '%s\t');% readout strings from the first line
           n_variables     = length(variable_names);       % number of variables in TSV file from fMRIPrep

    %        % include motion outliers into var names?
    %        outlier=regexp(variable_names, 'motion_outlier.*.');
    %        outlier_idx=find(~cellfun(@isempty,outlier));
    %        var_names2=variable_names(outlier_idx)';
    %        var_names=[var_names1 var_names2];

           % generate formatSpec to import data 
           formatSpec = [];
           for n = 1 : n_variables
               formatSpec = strcat(formatSpec, '%s'); % each entry in the tsv file will be read in as a string 
           end

           % read in all variables from tsv file (...desc-confounds_timeseries.tsv) into
           % the varaible 'data' as cell
           fid     = fopen(confounds_file);
           data    = textscan(fid, formatSpec, 'Delimiter', '\t', 'Headerlines',1); 
           fclose(fid);

           % case where volumes of interest exceed available volumes
           if length(data{1}) < volumes_of_interest
               volumes_of_interest=length(data{1});
               fprintf('subject with short sequence %s \n', id)      
           end

           R = NaN(volumes_of_interest, length(var_names)); % create R with the appropriate size

           for i = 1 : length(var_names)
               index(i) = find(strcmp(variable_names, var_names{i})); % get current variable from all variables in confound file
               var =   data{index(i)}(1:volumes_of_interest); % cut variable to length of columnes of interest
               R(:,i)= cellfun(@str2double,var); % write cut variable into R
           end

    %        % check if motion spike regressors still exist (after cutting the data)
    %        motion_vars=regexp(var_names, 'motion_outlier.*.');
    %        motion_ids=find(~cellfun(@isempty,motion_vars));

    %         if ~isempty(motion_ids)
    % 
    %            exclude= sum(R(:,motion_ids))==0;
    % 
    %             R(:,motion_ids(exclude))=[];
    %             var_names(motion_ids(exclude))=[];
    % 
    %         end

            % replace NANs for first volume derivate regressors with zero
            idx=isnan(R);
            R(idx)=0;

            save(fullfile(mainpath, subject, 'func', outputname), 'R', 'var_names');
            
       end % try
       
   end % task

end % subject
