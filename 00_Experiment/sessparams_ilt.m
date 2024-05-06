%----------------------------------------------------------------------------
% load session parameters
%----------------------------------------------------------------------------


fprintf('............ Setting basic parameters according to \n')
fprintf('............            SESSPARAMS.M\n'); fprintf('............ \n')

debug       = 0;

%----------------------------------------------------------------------------
%        To save or not to save
%        This should ALWAYS be set to 1 when doing experiments obviously
%----------------------------------------------------------------------------
dosave = 1;      % save output? 
                     
%----------------------------------------------------------------------------
%        DO NOT CHANGE
%----------------------------------------------------------------------------

if strcmp(session,'Training')
    doinstr = 1;
else 
    doinstr = 0;
end 

% code juice / alc order into simple 1/2 variable
if strcmp(Reihenfolge,'S-A'); ord=1; else ord=2; end

% determine version order A-B / B-A according to even / uneven subject
% number

if mod(str2num(subjn),2)==0
    vers_ord=1; % A-B
else
    vers_ord=2; % B-A
end  


% set total session number 
if doinstr==1 
    sessionsN=1;
else 
    % if mod(idivide(str2num(subjn)-1,int16(4)),2) == 0; Task_Version='A'; else Task_Version='B'; end
    % if mod(str2num(subjn),2) == 0; Task_Version='A'; else Task_Version='B'; end
    if strcmp(session,'Task')
        sessionsN=2;
    else 
        sessionsN=1;
    end 
end  

%----------------------------------------------------------------------------
%        DISPLAY SETTINGS
%
%----------------------------------------------------------------------------
% display settings (multiple screens and mirror-inverted display)

if doscanner == 0
       screenNumber  = 0;
       MirrorDisplay = 0; 
elseif doscanner == 1
    if whichscanner == 1
        screenNumber  = 0; % 0: enlarged screen
                           % 1: laptop / PC display only
                           % 2: MRI monitor only
        MirrorDisplay = 1; % horizontal mirroring 
        upsideDown = 0;    % vertical mirroring 
    elseif whichscanner == 2
        screenNumber  = 0; % 0: enlarged screen
                           % 1: laptop / PC display only
                           % 2: MRI monitor only
        MirrorDisplay = 0; % horizontal mirroring
        upsideDown = 0;    % vertical mirroring
    end
end
                  
%----------------------------------------------------------------------------
%        EXPERIMENT VERSION 
%	     PLEASE check this is correct! 
%----------------------------------------------------------------------------
expversion = 'InstrLearn_B01WP2_04/2022';
