%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Main shell script 'reversal volatility' %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; 
clear all;  
close all;

% make sure we use different random numbers each time we restart matlab
rng('shuffle')

modifyme_ilt;	% set the subject-specific experimental parameters (most of this is now in 
% the Gui ILT_GUI.mlapp
load('guiparams.mat');
sessparams_ilt; % set the session-specific experimental parameters

if ~strcmp(session, 'Training') & pump==1; CALLpump; end       % set up the pump

for runs=1:sessionsN

    expparams_ilt;  % set parameters that are not specific to subjects 
    preps_ilt;      % preparations: set up stimulus sequences, left/right etc.

    cd (fullfile(cd,'data_ilt'))
    varname = strcat(namestring_long, '.mat');
    assert(exist(varname) ~= 2,'File already exists! Please make sure to have the correct file name in modifyme.m') 
    cd ..


    try 	% this is important: if there's an error, psychtoolbox will crash graciously
		% and move on to the 'catch' block at the end, where all screens etc are
		% closed. 

	    if ~debug; HideCursor; end;

        if runs==1 
            setup_ilt
        else
            setup_ilt_feedback
        end	% set up the psychtoolbox screen and layout parameters 
				% this includes things like positioning of stimuli and loading the
				% stimuli into psychtoolbox; use of split screen; mirror-invert display etc. 
    
        % Do instruction 
        if doinstr == 1
            instr_pre_training;
            
        elseif doinstr == 0
            instr_pre_ILT;

    
            rating.taste1=vas(1,[['Wie angenehm finden Sie den Schluck ' drinkname '?']     {'sehr unangenehm' 'sehr angenehm'}],answ);
            rating.crave1=vas(1,[['Wie stark ist in diesem Moment Ihr Verlangen nach ' drinkname '?']     {'gar nicht stark' 'sehr stark'}],answ);
            
            Screen('TextSize',wd,txtsize);

        end
        
    % main experimental loop - no difference between training & test

        if doscanner == 1; initialwait; end
        T.exp_start=GetSecs;
        
        for nt = 1:Z.Ntrials
    	    ilt_trial
        end
    
        T.exp_end = GetSecs;
	    
%     if doscanner==1; WaitSecs(10-monitorFlipInterval); T.baseline_end = GetSecs; end % 10 sec baseline at the end
        if doscanner == 1; finalwait; end 

        if doinstr == 0
            
           %instr_post_ILT;
           vasText(1,[['Sie bekommen gleich wieder einen Schluck ' drinkname '.']     {'' ''}],answText);
           rating.taste2=vas(1,[['Wie angenehm finden Sie den Schluck ' drinkname '?']     {'sehr unangenehm' 'sehr angenehm'}],answ);
           rating.crave2=vas(1,[['Wie stark ist in diesem Moment Ihr Verlangen nach ' drinkname '?']     {'gar nicht stark' 'sehr stark'}],answ);
           
           Screen('TextSize',wd,txtsize);

        elseif doinstr == 1
            
            instr_post_training; 
        
        end
        
        if ~doinstr; WaitSecs(2-monitorFlipInterval); end
    
    %---------------------------------------------------------------------------
	   
    fprintf('saving worksapce and outcome variables in two separate files\n');

	if dosave; eval(['save data_ilt' filesep namestring_long '_WS.mat']);end
    
    savepath = ['data_ilt' filesep namestring_long];
    if doinstr == 1
        if dosave; eval('save(savepath, ''A'',''C'',''R'',''rt'',''S'',''T'')');end
    elseif doinstr == 0
        if dosave; eval('save(savepath, ''A'',''C'',''R'',''rt'',''S'',''T'',''rating'')');end
    end

    catch % execute this if there's an error, or if we've pressed the escape key
        Screen('CloseAll'); % close psychtoolbox, return screen control to OSX
        ShowCursor;
        if     aborted==0;	 % if there was an error
		        fprintf(' ******************************\n')
		        fprintf(' **** Something went WRONG ****\n')
		        fprintf(' ******************************\n')
		        if dosave; eval(['save data_incomplete' filesep namestring_long '.crashed.mat;']);end
        elseif aborted==1; % if we've abored by pressing the escape key
		        fprintf('                               \n')
		        fprintf(' ******************************\n')
		        fprintf(' **** Experiment aborted ******\n')
		        fprintf(' ******************************\n')
		        if dosave; eval(['save data_incomplete' filesep namestring_long  '.aborted.mat;']);end
        end
        if dosave;  eval(['save data_incomplete' filesep namestring_long '-' date '.mat;']); fclose('all');end
            rethrow(lasterror)
    end
end
if ~strcmp(session, 'Training') & pump==1; ENDpump; end
Screen('CloseAll');
fprintf('.........done\n')