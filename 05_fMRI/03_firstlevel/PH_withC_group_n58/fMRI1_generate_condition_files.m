% generate condition file
% loads parametric modulators from script fMRI0_gen_parametric_mod.m
% MM 02-2024close all;


clear;
clc;
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_ILT_CODE\03_fMRI\functs')


% define parameters
reg = 1;
TR = 0.869;
MR = 40; % Should be consistent with value in 1st level batch 
bin = TR/MR;

% define output path
stats_path = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\derivatives\02_spm12_1st_level\PH_withC_n58'; % folder for single stats of this specific model, add names of pmods

% define behavioral data files
behav_path   = 'C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_DATA\Behav\raw\FilesReport_ILTdata_2023-05-24_1718\documents'; % raw behavioral data path

% get ids from n58 parametric modulator txt file
PEs = readtable(fullfile(stats_path, 'fmri_PEs_PH_withC_init05_n58.txt'));
ids = unique(cellstr(num2str(PEs.ID)));
clear PEs;

%% subject loop

for n = 1:length(ids)

    sub_stats_path = fullfile([stats_path(1:end) '\sub-' ids{n}]); % subject folder within first-level stats folder
    
    %% load behavioral data per subject
    behav_ilt3 = dir2([behav_path ['\' ids{n} '_termin_1_fmrt_arm_1_b01_wp2_ilt03.mat']]);
    behav_ilt4 = dir2([behav_path ['\' ids{n} '_termin_1_fmrt_arm_1_b01_wp2_ilt04.mat']]);
    
    D_ilt3=load(fullfile(behav_path, behav_ilt3.name));
    D_ilt4=load(fullfile(behav_path, behav_ilt4.name));
    
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

    % rename behavioral data structures
    if D_ilt3.block == 1 && D_ilt4.block == 2 
       D_ilt1 = D_ilt3;
       D_ilt2 = D_ilt4;
    elseif D_ilt3.block == 2 && D_ilt4.block == 1
       D_ilt1 = D_ilt4;
       D_ilt2 = D_ilt3;
    end

    clear D_ilt3 D_ilt4
    
    %% load parametric modulator trajectories for both blocks per subject
    load(fullfile(sub_stats_path, ['sub-', ids{n}, '_pmods_ilt1.mat']));
    load(fullfile(sub_stats_path, ['sub-', ids{n}, '_pmods_ilt2.mat']));

    for block = 1:2
        
        % select behavioral data and pmods for respective block
        if block == 1
            D_sub = D_ilt1;
            PEs_sub = subj_PEs_block1;
            PCs_sub = subj_pcs_block1;
        elseif block == 2
            D_sub = D_ilt2;
            PEs_sub = subj_PEs_block2;
            PCs_sub = subj_pcs_block2;
        end
                
        % define regressors for fMRI analysis
        PEs{n,block} = PEs_sub-nanmean(PEs_sub);
        PCs{n,block} = PCs_sub-nanmean(PCs_sub);

        PEs{n,block} = PEs{n,block}(isnan(PEs{n,block})==0); % exclude NaNs from pmods
        PCs{n,block} = PEs{n,block}(isnan(PEs{n,block})==0);

%         % Reorder PE and PC so that NaN elements are at the position
%         % where no action was made (currently at the end of the vector)
%         nan_ind = find(isnan(D_sub.A)); % get index of NaN in action vector
% 
%         for ind = 1:length(nan_ind)
% 
%             PE_non_nan_start = PEs{n}(1:nan_ind(ind)-1);
%             PE_non_nan_end = PEs{n}(nan_ind(ind):end);
%             PEs{n}=[non_nan_start; NaN; non_nan_end];
% 
%             PC_non_nan_start = PCs{n}(1:nan_ind(ind)-1);
%             PC_non_nan_end = PCs{n}(nan_ind(ind):end);
%             PCs{n}=[non_nan_start; NaN; non_nan_end];
% 
%         end
        regs          = [PEs{n,block} PCs{n,block}];

        %% get onsets & set bins
        names           = {'trial', 'missings'};
        durations       = {0 0};
        
        onsets_cue      = D_sub.T.trial_onset'-D_sub.T.baseline_start;
        onsets_feedback = D_sub.T.onset_fb'-D_sub.T.baseline_start;
        onsets_taste = D_sub.T.onset_taste'-D_sub.T.baseline_start;
        onsets_swallow = D_sub.T.onset_swallow'-D_sub.T.baseline_start;
        onsets_trialend= D_sub.T.onset_trialend'-D_sub.T.baseline_start;
        onsets_missings = onsets_feedback(isnan(D_sub.A));

        % exclude onsets of missing trials
        onsets_cue      = onsets_cue(~isnan(D_sub.A));
        onsets_feedback = onsets_feedback(~isnan(D_sub.A));
        onsets_taste = onsets_taste(~isnan(D_sub.A));
        onsets_swallow = onsets_swallow(~isnan(D_sub.A));
        onsets_trialend = onsets_trialend(~isnan(D_sub.A));

        R=D_sub.R(~isnan(D_sub.A)); % reward
        
        % trial and feedback length
        for trial = 1:50
            if onsets_taste(trial,1) < 0 % if NO taste & swallow in this trial
                trial_length(trial,1) = onsets_trialend(trial,1)-onsets_cue(trial,1); % trial length
                feedback_length(trial,1) = onsets_trialend(trial,1)-onsets_feedback(trial,1);  % feedback length
            else % if taste & swallow in this trial
                trial_length(trial,1) = onsets_swallow(trial,1)-onsets_cue(trial,1); % trial length
                feedback_length(trial,1) = onsets_swallow(trial,1)-onsets_feedback(trial,1);  % feedback length
            end
        end
        
        % exclude taste and swallow onsets in trials with no reward
        onsets_taste = onsets_taste(onsets_taste>=0);
        onsets_swallow = onsets_swallow(onsets_swallow>=0);

        % get number of bins per trial
        trial_events_c = ceil(trial_length/bin); % nbins per trial with one incomplete bin
        trial_events_f = floor(trial_length/bin); % only full bins
        trial_diff_c = abs(trial_length-trial_events_c*bin); % diff btw ceil*bin and trial length
        trial_diff_f = abs(trial_length-trial_events_f*bin); % diff btw floor*bin and trial length

        if trial_diff_c < trial_diff_f % check which is closer to actual trial length and choose this as events variable
            trial_events = trial_events_c;
        else
            trial_events = trial_events_f;
        end
        
        % get number of bins per feedback phase
        feedback_events_c = ceil(feedback_length/bin); % nbins per trial with one incomplete bin
        feedback_events_f = floor(feedback_length/bin); % only full bins
        feedback_diff_c = abs(feedback_length-feedback_events_c*bin); % diff btw ceil*bin and trial length
        feedback_diff_f = abs(feedback_length-feedback_events_f*bin); % diff btw floor*bin and trial length

        if feedback_diff_c < feedback_diff_f % check which is closer to actual trial length and choose this as events variable
            feedback_events = feedback_events_c;
        else
            feedback_events = feedback_events_f;
        end

        cue_events = trial_events-feedback_events; % get number of bins per cue phase
        
        ind = [0; cumsum(trial_events(1:end))]; % past bins at the beginning of each trial

        for i=1:length(onsets_cue);
            % define onsets (with bin distance) that will be modulated for
            % each trial
            
            % onsets matrix in lines from number of past bins at trial start + 1
            % to number of past bins at next trial start, first column
            % == numbers starting from cue onset of trial, going in bin
            % steps, until (cue onset of trial + number of bins in that
            % trial - 1) * bin
            ons(ind(i)+1:ind(i+1),1)=[onsets_cue(i):bin:(onsets_cue(i)+(trial_events(i)-1)*bin)]'; 
            
            % onsets matrix in lines from number of past bins at trial start + 1
            % to number of past bins at next trial start, second column
            % == ones for every cue bin and 2s for every feedback bin
            ons(ind(i)+1:ind(i+1),2)=[ones(cue_events(i),1); ones(feedback_events(i),1)+1];
            
            % parametric modulator matrix in lines from number of past bins 
            % at trial start + 1 to number of past bins at next trial
            % start, column 1
            % == zero vector of length cue_events concatenated with PEs
            % vector of length feedback_events (containing PE value of
            % trial)
            PE_modulator(ind(i)+1:ind(i+1),1)=[zeros(cue_events(i),1); repmat(regs(i,1), feedback_events(i), 1)]; % epsilon 2 und 3
            
            % parametric modulator matrix in lines from number of past bins 
            % at trial start + 1 to number of past bins at next trial
            % start, column 1
            % == PCs vector of length cue_events (containing old PC value
            % before update) concatenated with PCs vector of length 
            % feedback_events (containing updated PC value)
            if     i< length(onsets_cue)
                PC_modulator(ind(i)+1:ind(i+1),1) = [repmat(regs(i,2), cue_events(i), 1); repmat(regs(i+1,2), feedback_events(i), 1)];% only sigma2 and mu3
            elseif i==length(onsets_cue) % letzter Trial
                PC_modulator(ind(i)+1:ind(i+1),1) = [repmat(regs(i,2), cue_events(i), 1); repmat(regs(i,2), feedback_events(i), 1)];% only sigma2 and mu3
            end
        end


        onsets{1}       = ons(:,1);
        onsets{2}       = onsets_missings;
        if isempty(onsets{2})
            onsets{2} = NaN; 
            onsets_missings = NaN;
        end
        
        %% define condition file content
        orth = {0};
        
        pmod(1).name{1} = 'prediction_error';
        pmod(1).param{1}= [PE_modulator(:,1)];
        pmod(1).poly{1} = 1;

        pmod(1).name{2} = 'choice_prob';
        pmod(1).param{2}= [PC_modulator(:,1)];
        pmod(1).poly{2} = 1;

        % save multiple condition files
        if ~exist(sub_stats_path,'dir'); mkdir(sub_stats_path); end

        save([sub_stats_path '/conditions_' ids{n} '.mat'],'onsets','durations', 'names', 'pmod','orth', 'regs');
        clear regs pmod onsets names durations onsets_cue onsets_feedback onsets_taste onsets_swallow onsets_trialend onsets_missings orth ons PE_modulator PC_modulator trial_length feedback_length cue_length
        
    end % block
    
end % subject
