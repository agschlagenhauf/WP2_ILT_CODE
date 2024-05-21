% generate condition file
% loads parametric modulators from script fMRI0_gen_parametric_mod.m
% MM 02-2024

close all; clear all
addpath('C:\spm12')
addpath("S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP2_fMRI\Scripts\functs")


%% set and define stuff %%

rawbehav = 'C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_DATA\Behav\raw\FilesReport_ILTdata_2023-05-24_1718\documents';
mainbehav= 'C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_DATA\Behav';
einzelstatspath= 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\05_derivatives_1st_level\n53'; 

% load behavioral data
files=dir2([rawbehav '/*.mat' ]);

not_processed={};

gui=1 %open GUI
[subject fold2 folder]=p_getSubFolder(einzelstatspath, [],gui  ,'sep');



%% loop
for i=1:length(folder)
    
   subcode=regexprep(folder{i}, {'sub-' '\'}, {''});
 
   % load behavioral mat file
   search_string=['^', subcode, '.*\.mat'];
   matfiles = cellstr(spm_select('FPlist', rawbehav, search_string));
   
   for file=1:length(matfiles)
       
        d=load(matfiles{file});

        % find trials with missing behavior 
        missed_trials=find(isnan(d.A)); % find trials with no action (missing trials)

        d.T.choice_onset(missed_trials)=[]; % delete choice onset of missing trials
        d.T.onset_fb(missed_trials)=[]; % delete feedback onset of missing trials
        miss_ons=d.Z.stim1_ons(missed_trials);
        d.Z.stim1_ons(missed_trials)=[];

        if isempty(missed_trials)

          names={'2ndstage_reward', 'reward' , '1stage'};
          onsets={sort([d.Z.rew_ons d.Z.stim2_ons])',d.Z.rew_ons', d.Z.stim1_ons' };
          durations={0 0 0};

        else

          names={'2ndstage', 'reward' , '1stage', 'invalid_trials'};
          onsets={sort([d.Z.rew_ons d.Z.stim2_ons])',d.Z.rew_ons', d.Z.stim1_ons', miss_ons' };
          durations={0 0 0 0};

        end

   end
  
     %% parametric modulators 
   
 
   % load subjects' parametric modulator file
   subjectfolder=fullfile(einzelstatspath, ['sub-', subcode]) ;
   load(fullfile(subjectfolder, ['sub-', subcode, '_pmods.mat']));
   
   
   
    pmod(1).name{1}  = 'TD_error_MF';
    pmod(1).param{1} = delta_pmod;
    pmod(1).poly{1}  = 1;
    
    pmod(1).name{2}  = 'TD_error_diff_MB';
    pmod(1).param{2} = ddeltadw_pmod;
    pmod(1).poly{2}  = 1;
    
    pmod(3).name{1} = 'pa chosen Qeff';
    pmod(3).param{1}=pmodfirst(:,1);
    pmod(3).poly{1} = 1;
    
    pmod(3).name{2} = 'pa chosen ddiffwrtw';
    pmod(3).param{2}=pmodfirst(:,2);
    pmod(3).poly{2} = 1;
  
    
     if 1 %SAVE conditionFILES
           
      
                %FILENAME
                conditionfile=['sub-', subcode '_cond_Daw_7params'];
                
                save(fullfile(subjectfolder, conditionfile),...
                    'names' , 'durations' ,'onsets' ,  'pmod' );
   end % save condition file
    
   clear names onsets durations pmod
   %else % if dataset is not in final fMRI ids, skip subject
   %    not_processed={not_processed; strtok(files(i).name, '_') };
   %end
                
end %subjects

