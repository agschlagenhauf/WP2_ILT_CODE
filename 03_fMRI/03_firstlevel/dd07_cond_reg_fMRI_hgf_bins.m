close all;
clear;
clc;
addpath('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs')


%% set paths

params = 0;
reg = 1;
ind_bins = 1;
fix_bins = 0;
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

k=1;

for n = 1:length(ids)

    sub_stats_path = fullfile([stats_path(1:end) '\sub-' ids{n}]); % subject folder within first-level stats folder
    
    %%% load behavioral data per subject
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
       D_ilt2 = D_ilt4;
    elseif D_ilt3.block == 2 && D_ilt4.block == 1
       D_ilt1 = D_ilt4;
       D_ilt2 = D_ilt3;
    end

    clear D_ilt3 D_ilt4
    
    %%% load parametric modulator trajectories for both blocks per subject
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
        if reg
       
            PEs{n} = PEs_sub-nanmean(PEs_sub);
            PCs{n} = PCs_sub-nanmean(PCs_sub);
            
            % Reorder PE and PC so that NaN elements are at the position
            % where no action was made (currently at the end of the vector)
            PEs{n} = PEs{n}(isnan(PEs{n})==0); % exclude NaNs from pmods
            PCs{n} = PEs{n}(isnan(PEs{n})==0);
            
            nan_ind = find(isnan(D_sub.A)); % get index of NaN in action vector
            
            for ind = 1:length(nan_ind)
                
                PE_non_nan_start = PEs{n}(1:nan_ind(ind)-1);
                PE_non_nan_end = PEs{n}(nan_ind(ind):end);
                PEs{n}=[non_nan_start; NaN; non_nan_end];
                
                PC_non_nan_start = PCs{n}(1:nan_ind(ind)-1);
                PC_non_nan_end = PCs{n}(nan_ind(ind):end);
                PCs{n}=[non_nan_start; NaN; non_nan_end];
                
            end
            
            regs          = [PEs{n} PCs{n}];
            regs_withNaN  = regs;

            %%% get onsets
            names           = {'trial', 'missings'}; %%%%%%%%%%check!!
            durations       = {0 0};
            onsets_cue      = D_sub.T.trial_onset'-D_sub.T.baseline_start;
            onsets_feedback = D_sub.T.onset_fb'-D_sub.T.baseline_start;
            onsets_taste = D_sub.T.onset_taste'-D_sub.T.baseline_start;
            onsets_swallow = D_sub.T.onset_swallow'-D_sub.T.baseline_start;
            offsets_swallow= D_sub.T.onset_trialend'-D_sub.T.baseline_start;
            onsets_missings = onsets_feedback(isnan(D_sub.A));
            
            % exclude onsets of missing trials
            onsets_cue      = onsets_cue(~isnan(D_sub.A));
            onsets_feedback = onsets_feedback(~isnan(D_sub.A));
            onsets_taste = onsets_taste(~isnan(D_sub.A));
            onsets_swallow = onsets_swallow(~isnan(D_sub.A));
            offsets_swallow = offsets_swallow(~isnan(D_sub.A));

            R=D_sub.R(~isnan(A));
            trial = offsets_swallow-onsets_cue; % Dauer von cue onset bis swallow offset + ITI = triallength
            feedback = offsets_swallow-onsets_feedback;

            if ind_bins
                
                % get number of bins per trial
                events_c = ceil(trial/bin); %nbins per trial with one incomplete bin
                events_f = floor(trial/bin); %only full bins
                diff_c = abs(trial-events_c*bin); %diff zwischen ceil*bin und trial length
                diff_f = abs(trial-events_f*bin); %diffe zwischen floor*bin und trial length
                if diff_c < diff_f %check which is closer to actual trial length and choose this as events variable
                    events = events_c;
                else
                    events = events_f;
                end
                
                nPE = 9; % n bins during feedback
                nPR = events-nPE; % n bins during entire trial length
                ind = [0; cumsum(events(1:end))]; % verstrichene bins zu beginn jedes trials
                
                for i=1:length(onsets_cue);
                    ons(ind(i)+1:ind(i+1),1)=[onsets_cue(i):bin:(onsets_cue(i)+(events(i)-1)*bin)]'; % Milena: Von cue onset in bin-Schritten bis Anzahl bins im trial -1 * bin duration?
                    ons(ind(i)+1:ind(i+1),2)=[ones(nPR(i),1); ones(nPE,1)+1];
                    PEs(ind(i)+1:ind(i+1),1:2)=[zeros(nPR(i),2); repmat(regs(i,[3:4]), nPE,1)]; % epsilon 2 und 3

                   % this is not necessary 
                    if     i< length(onsets_cue)
                        %%% PRs(ind(i)+1:ind(i+1))=[repmat(regs(i,3:5), nPR(i),1); repmat(regs(i+1,3:5), nPE,1)];
                        % PRs(ind(i)+1:ind(i+1),[1:2])=[repmat(regs(i,[1:2]), nPR(i),1); repmat(regs(i,[1:2]), nPE,1)];
                        POs(ind(i)+1:ind(i+1),1:2) = [repmat(regs(i,[1:2]), nPR(i),1); repmat(regs(i+1,[1:2]), nPE,1);];% only sigma2 and mu3
                    elseif i==length(onsets_cue) % letzter Trial
                        %%% PRs(ind(i)+1:ind(i+1))=[repmat(regs(i,3:5), nPR(i),1); repmat(regs(i,3:5), nPE,1)];
                        % PRs(ind(i)+1:ind(i+1),[1:2])=[repmat(regs(i,[1:2]), nPR(i),1); repmat(regs(i,[1:2]), nPE,1)];
                        POs(ind(i)+1:ind(i+1),1:2) = [repmat(regs(i,[1:2]), nPR(i),1); repmat(regs(i,[1:2]), nPE,1);];
                    end
                end


                if ind_bins==1
                    onsets{1}       = ons(:,1);
                    onsets{2}       = onsets_missings;
                    if isempty(onsets{2}); onsets{2} = NaN; end
                end

                if isempty(onsets_missings);  onsets_missings = NaN;
                end
                orth = {0};
                %figure()
                %plot(POs(:,2))

                if ind_bins

                    pmod(1).name{1} = 'sigma2hat';
                    pmod(1).param{1}= [POs(:,1)];
                    pmod(1).poly{1} = 1;

                    pmod(1).name{2} = 'mu3hat';
                    pmod(1).param{2}= [POs(:,2)];
                    pmod(1).poly{2} = 1;

                    pmod(1).name{3} = 'epsi2';
                    pmod(1).param{3}= [PEs(:,1)];
                    pmod(1).poly{3} = 1;

                    pmod(1).name{4} = 'epsi3';
                    pmod(1).param{4}= [PEs(:,2)];
                    pmod(1).poly{4} = 1;
                    %onsets = {onsets_cue, onsets_missings};
                    orth{1}=0; % orth{2}=0;

                end

                % save multiple condition files
               % if ~exist(sub_stats_path,'dir'); mkdir(sub_stats_path); end
                % code = subjects(sub(1:end))

                %save([sub_stats_path '/conditions_' code '.mat'],'onsets','durations', 'names', 'pmod','orth', 'regs', 'regs_withNaN');
                clear regs pmod onsets names durations A R T S onsets_cue onsets_feedback onsets_missings orth ons PEs PRs POs

            end
    end
end
% for i = 1:82
%     withNan(5, i) = sum(isnan(cell2mat(epsi2(i))));
%     withNan(6, i) = sum(isnan(cell2mat(epsi3(i))));
% end
% Nsj=length(D);	 	% number of subjects