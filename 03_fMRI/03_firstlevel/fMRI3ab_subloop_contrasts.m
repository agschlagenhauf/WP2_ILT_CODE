%××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××
% create and run contrasts for 7 parameter Daw  model 
% 28-06-2022
%××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××

%% Define paths

clc; clear;warning off;
addpath('C:\spm12')
addpath('C:\spm12\toolbox\AAL3')
addpath ('C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_CODE\03_fMRI\functs')

meta_path = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\02_spm12_1st_level\';

first_level_path = fullfile(meta_path, 'PH_withC_group_n58_prolonged_feedback\');

gui=1; %open GUI

tb={};
N =0 ;%NstatTest-Iterator
           
%% Define contrasts

% We've got the following 29 first-level regressors per session:
% trial
% trial * PE
% trial * CP
% swallow
% missing trial
% 24 motion regressors
%
% Session 1 = alc, session 2 = juice

% Alc condition contrasts
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual_alc'           [1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_alc'              [0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_alc'               [0 0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'swallow_alc'          [0 0 0 1]};

% Jui condition contrasts
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual_jui'           [zeros(1,29), 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_jui'              [zeros(1,29), 0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_jui'               [zeros(1,29), 0 0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'swallow_jui'          [zeros(1,29), 0 0 0 1]};

% Alc & Jui condition contrasts
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual'               [1, zeros(1,28), 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE'                  [0 1, zeros(1,27), 0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP'                   [0 0 1, zeros(1,26), 0 0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'swallow'              [0 0 0 1, zeros(1,25), 0 0 0 1]};

% Comparison alc jui contrasts
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_alc > RPE_jui'    [0 1, zeros(1,27), 0 -1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_alc < RPE_jui'    [0 -1, zeros(1,27), 0 1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_alc > CP_jui'      [0 0 1, zeros(1,26), 0 0 -1]};
N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_alc < CP_jui'      [0 0 -1, zeros(1,26), 0 0 1]};

%% Create SPM structure

matlabbatch={};
matlabbatch{1}.spm.stats.con.consess=[];
for i=1:size(tb,1)
    thiscon=tb(i,:);
    if strcmp(thiscon{2},'Tcon')
        matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.tcon.name =thiscon{4};
        matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.tcon.convec = thiscon{5};
        matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.tcon.sessrep =thiscon{3};
    elseif strcmp(thiscon{2},'Fcon')
        matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.fcon.name = thiscon{4};
        matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.fcon.convec = thiscon{5};
        matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.fcon.sessrep = thiscon{3};
    end
end
contrasts=tb; %SAVE CONTRAST
save(fullfile(first_level_path ,['contrasts']) ,'contrasts');

% delete former contrasts?
matlabbatch{1}.spm.stats.con.delete = 1 ;

%% Loop over subjects

[subject, fold2, pbnfolder] = p_getSubFolder(first_level_path,'',gui  ,'sep');

IDS = strrep(pbnfolder,'\',''); %keep subjectID (only)
 
for pb=1:length(pbnfolder) % loop pbn

    pasub = fullfile(first_level_path, IDS{pb}) ;%SPM.mat-destination
    matlabbatch{1}.spm.stats.con.spmmat = {[pasub '\SPM.mat']};

    % Delete F/t/con-images & delete 'SPM.xcon'-fieldname from existing SPM.mat
    delete(fullfile(pasub, [ 'spmF_*'  ]  ));
    delete(fullfile(pasub, [ 'spmT_*'  ]  ));
    delete(fullfile(pasub, [ 'con_*'   ]  ));
    load(fullfile(pasub,   [ 'SPM.mat' ]  ));%load and delete xCON-field
    SPM.xCon=struct([]);
    save(fullfile(pasub,   [ 'SPM.mat' ]  ),'SPM');
    clear SPM

    % Run SPM job
    spm('defaults', 'FMRI');
    spm_jobman('run',matlabbatch );
    
end
