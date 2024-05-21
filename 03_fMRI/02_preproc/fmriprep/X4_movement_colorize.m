% extract maximal movement over session from 6 movement params
% 11-02-2022

clear; clc
addpath('C:\spm12')
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_path = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\fmriprep_v23.2.1';
output_file = fullfile(data_path, ['Movement_4mm_4Grad_AIDILTONLY' date '.xls']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

list_sub_data_paths = spm_select(inf, 'dir',...
    'Select subject folder','',  data_path); 

% ===================== rp params ==============================

tabX={};
header={'Code' 'Run' 'trans_x_diff' 'trans_y_diff' 'trans_z_diff' 'rot_x_diff' 'rot_y_diff' 'rot_z_diff'};
tabX(end+1,:)=header;

%Subject und dazugehöriger Pfad mit rp-file

for sub           = 1:length(list_sub_data_paths(:,1)) 
    s             = strread(list_sub_data_paths(sub,:), '%s','delimiter', '\\'); % path to subject
    subjects{sub} = s{end}(1:end); % subject
    
    % Data-path
    sub_rp_path       = fullfile(list_sub_data_paths(sub,:), '\func'); 
    sub_rp_file = cellstr(spm_select('List', sub_rp_path, '^RP_.*\.mat'));
    
    %rp-file Pfad und Datei für jeweiligen run
    
    for run = 1:length(sub_rp_file)
        
        datamat=[]; % clear datamat
        
        %Subject und run in Command Window schreiben
        fprintf('working on %s run %d\n', subjects{sub}, run)
     
        sub_rp_file_path = fullfile(sub_rp_path, sub_rp_file{run}); 
        run_name = strread(sub_rp_file{run}, '%s','delimiter', '\\');
        run_name = strread(run_name{1}, '%s','delimiter', '_');
        if strcmp(run_name{end}, 'task-aid.mat')
            run_name = cellstr(run_name{end});
        else
            run_name = cellstr(strcat(run_name{end-1}, '_', run_name{end}));
        end
        
        %rp_file einlesen
        matrix  = load(sub_rp_file_path);              
        %Für 3x Translation und 3x Rotation einzelne Vektoren bilden
        trans_x     = matrix.R(:,1); %in mm
        trans_y     = matrix.R(:,5); 
        trans_z     = matrix.R(:,9); 
        rot_x = rad2deg(matrix.R(:,13)); % convert radian to degree
        rot_y   = rad2deg(matrix.R(:,17));
        rot_z  = rad2deg(matrix.R(:,21));
        %Berechne Differenz zwischen Maximun und Minimum der jeweiligen Bewegung
        trans_x_diff = max(trans_x) - min(trans_x);
        trans_y_diff = max(trans_y) - min(trans_y);
        trans_z_diff = max(trans_z) - min(trans_z);
        rot_x_diff = max(rot_x) - min(rot_x);
        rot_y_diff   = max(rot_y) - min(rot_y);
        rot_z_diff  = max(rot_z) - min(rot_z);
 
        dataline=[trans_x_diff, trans_y_diff, trans_z_diff, rot_x_diff, rot_y_diff, rot_z_diff];
        datamat=[datamat dataline];
       
        tabX(end+1,:)=[subjects(sub) run_name{1} num2cell(datamat)];
        
    end %run
    
end

% ======= SAVE .xls-file =========

header1= ['MOVEMENT_AID_ILT' cell(1,size(tabX,2)-1)];
header2=tabX(1,:);
data=tabX(2:end,3:end) ;
datax=[zeros(size(data(:,1),1),1) zeros(size(data(:,1),1),1) cell2mat(data)];% size datamat + zero column for codes

pwrite2excel_2(output_file,{1 'AID_ILT_'},header1 ,header2,[tabX(2:end,1) tabX(2:end,2) data]);
 
% Display in command window:
file=strread(output_file, '%s', 'delimiter', '\\');
cprintf([0 0.75 0.75], '\n RP Übersicht %s nach %s geschrieben\n', file{3,:}, data_path)
% ---------------------------------------------------------

%% FIND OUTLIER IN XYZ and PYR 

% set threshold for outlier:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% movement x-, y-, z-axis (in mm)
thresh_xyz=4;
% movement pitch, roll, yaw (in °)
thresh_pyr=4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Outlier
outlx=datax.*0;%
idx=find(~cellfun('isempty',  regexpi(header2,{'trans_x_diff|trans_y_diff|trans_z_diff'})));  %;xyz
outlx(:,idx)=datax(:,idx)>=thresh_xyz ;
idx=find(~cellfun('isempty',  regexpi(header2,{'rot_x_diff|rot_y_diff|rot_z_diff'})));%;pyr
outlx(:,idx)=datax(:,idx)>=thresh_pyr ;

xls_colorize(output_file, 1, outlx, 2, 18, 2 )






