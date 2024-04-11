%----------------------------------------------------------------------------
%       Information about Setting
%----------------------------------------------------------------------------
%doscanner = 0; % 0: outside scanner
               % 1: inside the scanner 
               
%%ONLY relevant if doscanner == 1%%               
MRI = 1;       % 0: outside scanner
               % 1: BCAN MRT1
               % 2: BCAN MRT2
               
pump = 1;      % 1: pump is connected 
               % 0: pump is not connected 
              
%----------------------------------------------------------------------------
%        Patient Information 
%-------------------------------------------------------------------------
%type = 'HC';         % 'HC' for controls 
                     % 'AUD' for AUD patients
                     
%subjn = '99999';       % Subject Number.; Pilot start with 041

%----------------------------------------------------------------------------
%        Task Information 
%-------------------------------------------------------------------------
%session = 'Task';   
                    % Traning = Training with instructions & water outcome
                    % Task = full task with 2 blocks (alcohol /
                    % juice)
                    
                    %%% ONLY USE IF EXP ABORTED DURING "ND BLOCK AND %%%%%
                    %%% RESTARTED                                    %%%%%
                    % Block1 = block 1 only (drink type depending on
                    % 'Reihenfolge')
                    % Block2 = = block 1 only (drink type depending on
                    % 'Reihenfolge')

%Reihenfolge = 'S-A'; %S-A: zuerst Saft dann Alkohol
                     %A-S: zuerst Alkohol dann Saft
                    
%chosen_A  =  'L'; %%ALCOHOL%%
                     % 'W' for white wine
                     % 'R' for red wine
                     % 'L' for limoncello
                     % 'C' for campari
                     % 'F' for fruit liquor
                     
%chosen_J = 'O';   %%JUICES%%
                     % 'A' for apple juice
                     % 'O' for orange juice
                     % 'M' for multi juice
                     % 'N' for ananas juice
                     % 'T' for grape juice

