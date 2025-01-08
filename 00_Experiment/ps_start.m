
% [w rect]=ps_start(0); %debug-mode (transp. screen)
% [w rect]=ps_start(1); %REAL MODE (black screen)

function [w rect]=ps_start(modus)
%PTB use PsychDebugWindowConfiguration
global w
global rect

if exist('modus')~=1
    modus=0;
end

%% see help SyncTrouble
%Screen('CloseAll') ;
%Screen('Preference','VisualDebugLevel', 0);
%Screen('Preference','SkipSyncTests', 1);

if modus==0
    %debugging screen like in setup_rev.m
    Screen('Preference', 'SkipSyncTests', 2);
    [w rect]=Screen('OpenWindow',0,0,[0 0 600 400],[],2,[],[]);
elseif modus==1  %%REAL MODUS
    %clear Screen
    %clear all
    Screen('Preference', 'SkipSyncTests', 1)
    Screen('Preference', 'VisualDebuglevel', 3);
    %[w rect]=Screen('OpenWindow',[0 1 2],[repmat(128,[1 3])]);
    [w rect]=Screen('OpenWindow',0,[0 0 1]);
elseif modus==2
    HideCursor;
    
    %AGAINST ALPHA_BLENDING
    global psych_default_colormode;
    psych_default_colormode = 0;
    
    
    %       [w rect]=Screen('OpenWindow', 2, 0, [], [], [], 8);
    if 0
        screens = Screen('Screens'); % Get the screen numbers. This gives us a number for each of the screens attached to our computer.
        mxscreens = max(screens);
        [w rect]=Screen('OpenWindow',mxscreens , 0, [repmat(128,[1 3])]);
    end
    %      [w rect]=Screen('OpenWindow', 2, 0, [], [], []); %THIS WORKED FOR EYTRACKING
    
     Screen('Preference', 'SkipSyncTests', 1);
%      Screen('Preference', 'VisualDebuglevel', 3);
     
    screens = Screen('Screens'); % Get the screen numbers. This gives us a number for each of the screens attached to our computer.
    mxscreens = max(screens);
    white = WhiteIndex(mxscreens); % Define black and white (white will be 1 and black 0). All values in Psychtoolbox are defined between 0 and 1
    black = BlackIndex(mxscreens);
    grey = white / 2;
    [w rect] = PsychImaging('OpenWindow', mxscreens, grey  ,[]);
    
    
    
    %     PsychDefaultSetup(2);
    %     screens = Screen('Screens'); % Get the screen numbers. This gives us a number for each of the screens attached to our computer.
    %     screenNumber = max(screens);
    %     white = WhiteIndex(screenNumber); % Define black and white (white will be 1 and black 0). All values in Psychtoolbox are defined between 0 and 1
    %     black = BlackIndex(screenNumber);
    %     grey = white / 2;
    %     [w rect] = PsychImaging('OpenWindow', 2, grey  ,[]); % [400 250 1200 750], [1200 30 1920 400]
    %     % [w1, h1]=Screen('WindowSize', window); % [1920, 1080]
    %     sca
end


% Screen('FillRect',w,[255 0 0],[0 0 500 400])
% Screen('Flip', w);
% sca



