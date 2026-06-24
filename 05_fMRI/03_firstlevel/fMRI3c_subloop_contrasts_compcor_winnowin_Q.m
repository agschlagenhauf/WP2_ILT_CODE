%××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××
% create and run contrasts for 7 parameter Daw  model 
% 28-06-2022
%××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××

%% Define paths

clc; clear;warning off;
addpath('C:\spm12')
addpath('C:\Users\musialm\Downloads\spm12')
addpath ('C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_CODE\05_fMRI\functs')

meta_path = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\02_ILT\00_spm12_1st_level\';

first_level_path = fullfile(meta_path, 'PH_withC_n58_constant_feedback_+_sensoric_correctbaseline_compcor_correctPC_winnowin_Q\');

gui=1; %open GUI

%% Loop over subjects

[subject, fold2, pbnfolder] = p_getSubFolder(first_level_path,'',gui  ,'sep');

IDS = strrep(pbnfolder,'\',''); %keep subjectID (only)
 
for pb=1:length(pbnfolder) % loop pbn
    %% Reset variables
    
    tb={};
    contrasts={};
    N=0;
    clear SPM
    
    %% Define paths
    
    pasub = fullfile(first_level_path, IDS{pb}) ; %SPM.mat path
    load(fullfile(pasub,   [ 'SPM.mat' ]  )); %load SPM.mat
   
    %% Delete F/t/con-images & delete 'SPM.xcon'-fieldname from existing SPM.mat
    
    delete(fullfile(pasub, [ 'spmF_*'  ]  ));
    delete(fullfile(pasub, [ 'spmT_*'  ]  ));
    delete(fullfile(pasub, [ 'con_*'   ]  ));
    SPM.xCon=struct([]);
    save(fullfile(pasub,   [ 'SPM.mat' ]  ),'SPM');
    
    %% Define contrasts

    % We've got the following 29 first-level regressors per session:
    % trial (cue onset - feedback offset)
    % trial * win loss (feedback onset - feedback offset)
    % trial * Q (entire regressor)
    % sensoric (feedback onset - swallow offset) 
    % missing trial (cue onset - feedback offset)
    % 24 motion regressors
    % first 5 CompCor components for CSF and white matter
    % all cosine regressors (differing number per block)
    %
    % Session 1 = alc, session 2 = juice
    
    names = SPM.xX.name(:); % column names (cellstr)
    ncol  = numel(names);
    base_vector = zeros (1,ncol);
    
    % define search patterns
    pattern_visual_alc = 'Sn\(1\) trial\*bf\(1\)$';
    pattern_Q_alc = 'Sn\(1\) trialxq_value\^1\*bf\(1\)$';
    pattern_win_nowin_alc = 'Sn\(1\) trialxwin_nowin\^1\*bf\(1\)$'; 
    pattern_sensoric_alc = 'Sn\(1\) sensoric\*bf\(1\)$';

    pattern_visual_jui = 'Sn\(2\) trial\*bf\(1\)$';
    pattern_Q_jui = 'Sn\(2\) trialxq_value\^1\*bf\(1\)$';
    pattern_win_nowin_jui = 'Sn\(2\) trialxwin_nowin\^1\*bf\(1\)$'; 
    pattern_sensoric_jui = 'Sn\(2\) sensoric\*bf\(1\)$';
    
    % create contrast vectors
    cvec_visual_alc = double(~cellfun('isempty', regexp(names, pattern_visual_alc, 'once')))';
    cvec_Q_alc = double(~cellfun('isempty', regexp(names, pattern_Q_alc, 'once')))';
    cvec_win_nowin_alc = double(~cellfun('isempty', regexp(names, pattern_win_nowin_alc, 'once')))';
    cvec_sensoric_alc = double(~cellfun('isempty', regexp(names, pattern_sensoric_alc, 'once')))';

    cvec_visual_jui = double(~cellfun('isempty', regexp(names, pattern_visual_jui, 'once')))';
    cvec_Q_jui = double(~cellfun('isempty', regexp(names, pattern_Q_jui, 'once')))';
    cvec_win_nowin_jui = double(~cellfun('isempty', regexp(names, pattern_win_nowin_jui, 'once')))';
    cvec_sensoric_jui = double(~cellfun('isempty', regexp(names, pattern_sensoric_jui, 'once')))';

    % Alc condition contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual_alc'           cvec_visual_alc};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'Q_alc'                cvec_Q_alc};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'win_nowin_alc'        cvec_win_nowin_alc};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'sensoric_alc'         cvec_sensoric_alc};

    % Jui condition contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual_jui'           cvec_visual_jui};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'Q_jui'                cvec_Q_jui};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'win_nowin_jui'        cvec_win_nowin_jui};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'sensoric_jui'         cvec_sensoric_jui};

    % Alc & Jui condition contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual'               (cvec_visual_alc+cvec_visual_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'Q'                    (cvec_Q_alc+cvec_Q_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'win_nowin'            (cvec_win_nowin_alc+cvec_win_nowin_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'sensoric'             (cvec_sensoric_alc+cvec_sensoric_jui)};

    % Comparison alc jui contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'Q_alc > Q_jui'                      (cvec_Q_alc+(cvec_Q_jui*-1))};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'Q_alc < Q_jui'                      ((cvec_Q_alc*-1)+cvec_Q_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'win_nowin_alc > win_nowin_jui'      (cvec_win_nowin_alc+(cvec_win_nowin_jui*-1))};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'win_nowin_alc < win_nowin_jui'      ((cvec_win_nowin_alc*-1)+cvec_win_nowin_jui)};
    

    %% Create SPM structure

    matlabbatch={};
    matlabbatch{1}.spm.stats.con.spmmat = {[pasub '\SPM.mat']}; %tell batch which SPM.mat to modify
    matlabbatch{1}.spm.stats.con.delete = 1; % delete former contrasts?
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
    save(fullfile(pasub ,['contrasts']) ,'contrasts');
    
    %% Run SPM job
    
    spm('defaults', 'FMRI');
    spm_jobman('run',matlabbatch );
    
end

           




