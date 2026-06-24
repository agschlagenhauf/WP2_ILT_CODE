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

first_level_path = fullfile(meta_path, 'PH_withC_n58_constant_feedback_+_sensoric_correctbaseline_compcor_correctPC\');

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
    % trial * PE (feedback onset - feedback offset)
    % trial * CP (entire regressor)
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
    pattern_RPE_alc = 'Sn\(1\) trialxprediction_error\^1\*bf\(1\)$';
    pattern_CP_alc = 'Sn\(1\) trialxchoice_prob\^1\*bf\(1\)$'; 
    pattern_sensoric_alc = 'Sn\(1\) sensoric\*bf\(1\)$';
    pattern_visual_jui = 'Sn\(2\) trial\*bf\(1\)$';
    pattern_RPE_jui = 'Sn\(2\) trialxprediction_error\^1\*bf\(1\)$';
    pattern_CP_jui = 'Sn\(2\) trialxchoice_prob\^1\*bf\(1\)$'; 
    pattern_sensoric_jui = 'Sn\(2\) sensoric\*bf\(1\)$';
    
    % create contrast vectors
    cvec_visual_alc = double(~cellfun('isempty', regexp(names, pattern_visual_alc, 'once')))';
    cvec_RPE_alc = double(~cellfun('isempty', regexp(names, pattern_RPE_alc, 'once')))';
    cvec_CP_alc = double(~cellfun('isempty', regexp(names, pattern_CP_alc, 'once')))';
    cvec_sensoric_alc = double(~cellfun('isempty', regexp(names, pattern_sensoric_alc, 'once')))';
    cvec_visual_jui = double(~cellfun('isempty', regexp(names, pattern_visual_jui, 'once')))';
    cvec_RPE_jui = double(~cellfun('isempty', regexp(names, pattern_RPE_jui, 'once')))';
    cvec_CP_jui = double(~cellfun('isempty', regexp(names, pattern_CP_jui, 'once')))';
    cvec_sensoric_jui = double(~cellfun('isempty', regexp(names, pattern_sensoric_jui, 'once')))';

    % Alc condition contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual_alc'           cvec_visual_alc};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_alc'              cvec_RPE_alc};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_alc'               cvec_CP_alc};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'sensoric_alc'         cvec_sensoric_alc};

    % Jui condition contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual_jui'           cvec_visual_jui};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_jui'              cvec_RPE_jui};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_jui'               cvec_CP_jui};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'sensoric_jui'         cvec_sensoric_jui};

    % Alc & Jui condition contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visual'               (cvec_visual_alc+cvec_visual_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE'                  (cvec_RPE_alc+cvec_RPE_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP'                   (cvec_CP_alc+cvec_CP_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'sensoric'             (cvec_sensoric_alc+cvec_sensoric_jui)};

    % Comparison alc jui contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_alc > RPE_jui'    (cvec_RPE_alc+(cvec_RPE_jui*-1))};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'RPE_alc < RPE_jui'    ((cvec_RPE_alc*-1)+cvec_RPE_jui)};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_alc > CP_jui'      (cvec_CP_alc+(cvec_CP_jui*-1))};
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP_alc < CP_jui'      ((cvec_CP_alc*-1)+cvec_CP_jui)};
    
    % Extra post-hoc contrasts
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'CP neg'               (cvec_CP_alc+cvec_CP_jui*-1)};

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

           




