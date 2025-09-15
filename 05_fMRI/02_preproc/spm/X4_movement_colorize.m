% extract maximal movement over session from 6 movement params
% 11-02-2022

clear; clc
addpath('C:\spm12')
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_path   = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\04_derivatives_spm';
outpath= data_path;
output_file = fullfile(outpath, ['Movement_4mm_4Grad_' date '.xls']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

list_sub_data_paths = spm_select(inf, 'dir',...
    'Select subject folder','',  data_path); 

% ===================== rp params ==============================

tabX={};
header={'Code' 'Run' 'x_diff' 'y_diff' 'z_diff' 'pitch_diff' ...
    'yaw_diff' 'roll_diff_pav_t1' 'euklidic_distance' };

tabX(end+1,:)=header;

%Subject und dazugehöriger Pfad mit rp-file

for sub           = 1:length(list_sub_data_paths(:,1)) 
    s             = strread(list_sub_data_paths(sub,:), '%s','delimiter', '\\'); % path to subject
    subjects{sub} = s{end}(1:end); % subject
    
    % Data-path
    sub_rp_path       = fullfile(list_sub_data_paths(sub,:), '\func'); 
    sub_rp_file = cellstr(spm_select('List', sub_rp_path, '^rp_asub.*\.txt'));
    
    %rp-file Pfad und Datei für jeweiligen run
    
    for run = 1:length(sub_rp_file)
        
        datamat=[]; % clear datamat
        
        %Subject und run in Command Window schreiben
        fprintf('working on %s run %d\n', subjects{sub}, run)
     
        sub_rp_file_path = fullfile(sub_rp_path, sub_rp_file{run}); 
        run_name = strread(sub_rp_file{run}, '%s','delimiter', '\\');
        run_name = strread(run_name{1}, '%s','delimiter', '_');
        if strcmp(run_name{end-1}, 'task-aid')
            run_name = cellstr(run_name{end-1});
        else
            run_name = cellstr(strcat(run_name{end-2}, '_', run_name{end-1}));
        end
        
        %rp_file einlesen
        matrix  = textread(sub_rp_file_path);              
        %Für 3x Translation und 3x Rotation einzelne Vektoren bilden
        x     = matrix(:,1); %in mm
        y     = matrix(:,2); 
        z     = matrix(:,3); 
        pitch = (matrix(:,4)*360)/6.28; %rad in GRAD umgerechnet
        yaw   = (matrix(:,5)*360)/6.28; 
        roll  = (matrix(:,6)*360)/6.28; 
        %Berechne Differenz zwischen Maximun und Minimum der jeweiligen Bewegung
        x_diff = max(x)-min(x);
        y_diff = max(y)-min(y);
        z_diff = max(z)-min(z);
        pitch_diff = max(pitch) - min(pitch);
        yaw_diff   = max(yaw)   - min(yaw);
        roll_diff  = max(roll)  - min(roll);
        
        ed=0;
        for i = 2:length(x)
           ed = ed + sqrt(((x(i)-x(i-1))^2 + (y(i)-y(i-1))^2) + (z(i)-z(i-1))^2);
        end %i
 

       dataline=[x_diff, y_diff, z_diff, pitch_diff, yaw_diff, roll_diff, ed];
       datamat=[datamat dataline];
       
       tabX(end+1,:)=[subjects(sub) run_name{1} num2cell(datamat)];
        
    end %run
    
end

% ======= SAVE .xls-file =========

header1= ['MOVEMENT_AID_ILT' cell(1,size(tabX,2)-1)];
header2=tabX(1,:);
data=tabX(2:end,3:end) ;
datax=[zeros(size(data(:,1),1),1) zeros(size(data(:,1),1),1) cell2mat(data)];% size datamat + zero column for codes

pwrite2excel_2(output_file,{1 'AID_ILT'},header1 ,header2,[tabX(2:end,1) tabX(2:end,2) data]);
 
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
idx=find(~cellfun('isempty',  regexpi(header2,{'x_|y_|z_'})));  %;xyz
outlx(:,idx)=datax(:,idx)>=thresh_xyz ;
idx=find(~cellfun('isempty',  regexpi(header2,{'pitch_|yaw_|roll_'})));%;pyr
outlx(:,idx)=datax(:,idx)>=thresh_pyr ;

xls_colorize(output_file, 1, outlx, 2, 18, 2 )






