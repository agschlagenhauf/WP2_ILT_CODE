%--------------------------------------------------------------------------
%           Experimental Parameters
%           DO NOT MODIFY between subjects within one experiment
%--------------------------------------------------------------------------
global logintext;

%  set drink type and exact drink
if doinstr
    Task_Version='Training';
    Drink_Type='Training';
else
    if sessionsN==2 
        if mod(ord,2) == (runs - 1) 
            Drink_Type='A';
            Exact_Drink=chosen_A;
        else 
            Drink_Type='J';
            Exact_Drink=chosen_J;
        end
    elseif sessionsN==1
        if (ord == 1 && strcmp(session,'Block1')) || (ord == 2 && strcmp(session,'Block2'))
            Drink_Type='J';
            Exact_Drink=chosen_J;
        else 
            Drink_Type='A';
            Exact_Drink=chosen_A;
        end
    end
end

%  set and load a fixed task structure 
if doinstr
    load('Training.mat', 'task_struc', 'state', 'p_u');
else
    if sessionsN==2
        if (vers_ord == 1 && runs == 1) || (vers_ord == 2 && runs == 2)
            Task_Version ='A';
        else 
            Task_Version ='B';
        end
    elseif sessionsN==1 
        if (vers_ord == 1 && strcmp(session,'Block1')) || (vers_ord == 2 && strcmp(session,'Block2'))
            Task_Version ='A';
        else
            Task_Version ='B';
        end
    end 
end

if Task_Version == 'A'
    load('Version_A.mat', 'task_struc', 'state', 'p_u');
elseif Task_Version =='B'
    load('Version_B.mat', 'task_struc', 'state', 'p_u');
end

% randomize which Card state=1 stands for
if rand(1,1)>.5
    new_state = 3-state;
else
    new_state = state;
end

Z.cent_per_point=1;    % 1 sip / correct answer

%number trials instructions and main experiment  
if doinstr==1;   Z.Ntrials       = length(state);  % number of learning trials in training (no null events)
else;            Z.Ntrials       = length(state);  % number of learning trials in scanner (without null events)
end

%probabilistic and system changes settings
Z.task_struc   = task_struc;
Z.state        = new_state;
Z.prob_events  = p_u;

% save information about Version and T1 / T2
Z.Task_Version = Task_Version;
Z.Run      = runs;

% timing

Z.max_choice_time        =  1.5;             % maximal time to respond sec
% Z.display_choice         = 0.5;               % duration to highlight choice with frame without feedback 
Z.display_fb             =  1;               % duration to display feedback 
Z.min_display_fix_cross  =  2;               % + jittered ITI for fMRI; mean 2.5s + 20% null events
Z.dur_end_baseline     = 10;
Z.display_taste = 2.5;                       % duration to display Taste screen 
Z.display_swallow = 3;                       % duration to display Swallow screen

% keys & display settings (multiple screens and mirror-inverted)
KbName('UnifyKeyNames');

if doscanner == 0
    keyleft       = 'f';          % left key 
    keyright      = 'j';          % right key 
    escapebutton  = 'esc';        % escape button to abort experiment
    instrbackward = 'LeftArrow';  % left key for changing instruction page 
    instrforward  = 'RightArrow'; % right key for changing instruction page 
    answ=[{ 'f'  'j' } 'return'];
    answText=[{ 'f'  'j' } 'y'];
    logintext = ['Einloggen mit der ENTER Taste.'];
   
elseif doscanner == 1
   keyleft     = '2';       % left blue key
   keyright    = '3';       % right red key
   login = '4';
   trigger     = '5';       % trigger send from the scanner, equals 5 on numpad
   escapebutton  = 'esc';        % escape button to abort experiment
   instrbackward = '2';  % left blue key for changing instruction page 
   instrforward  = '3'; % right red key for changing instruction page 
   answ=[{ '2@'  '3#'} '4$'];
   answText=[{ 'f'  'j' } 'y'];
   logintext = ['Einloggen mit der Taste rechts außen.'];

    
% elseif doscanner == 1
%    keyleft     = '6';       % left key, responsbox RED   = 4
%    keyright    = '1';       % right key, responsbox BLUE = 1 
%    trigger     = '5';       % trigger send from the scanner, equals 5 on numpad
%    instrbackward = 'LeftArrow';  % left key for changing instruction page 
%    instrforward  = 'RightArrow'; % right key for changing instruction page 
end

% ITIs for scanning
 load('iti_w_null.mat', 'ITI_w_null')
 load('ISI_final', 'ISI_final')
 
 ITI = ITI_w_null(randperm(Z.Ntrials));
 ISI = ISI_final(randperm(Z.Ntrials));
 
clear p_u state task_struc
