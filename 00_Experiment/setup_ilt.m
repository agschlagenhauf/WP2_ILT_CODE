Screen('Preference','SkipSyncTests', 1)
fprintf('............ Setting up the screen   \n');

% colours (in RBG)
purple		= [102 0 102];
new_col     = [255 153 51];
bgcol 		= [80 0];	% this is just in grayscale (each value separately)
white 		= [200 200 200];
hard_white  = [255 255 255];
red 		= [255 20 20]; 
blue 		= [120 0 255]; 
green 		= [0 135 00]; 

txtcolor 	= white;
blw         = .2;       % width of stimulus as fraction of **xfrac**
blh         = .2;       % height of stimulus as fraction of **xfrac**
max_txtsize = 40;       % text size is determined relative to screen resolution but maximum if defined here; 40  
txt_fix     = 40;       % text size fixation cross 

% get version of Psychtoolbox and matlab to be saved as workspace variables
Version_Psychtoolbox = PsychtoolboxVersion;
Version_matlab = version;

% open a screen
global wd
global rect
AssertOpenGL;
Screen('Preference','Verbosity',0);
if debug; 
	Screen('Preference','SkipSyncTests',2); % ONLY do this for quick debugging;
	[wd rect]=Screen('OpenWindow',screenNumber,bgcol(2),[0 0 600 400],[],2,[],[]); % Make small PTB screen on my large screen
else
%     imagingmode=kPsychNeedFastBackingStore;	% flip takes ages without this
	[wd rect]=Screen('OpenWindow',screenNumber,bgcol(2),[],[],2,[],[],[]);	     % Get Screen. This is always size of the display. 
    %wd=PsychImaging('OpenWindow',screenNumber,bgcol(2),[],[],2,[],[],kPsychNeed32BPCFloat);	     % Get Screen. This is always size of the display. 
end 
KbName('UnifyKeyNames');                    % need this for KbName to behave

% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
KbCheck;
WaitSecs(0.01);
GetSecs;

% Set priority for script execution to realtime priority:
priorityLevel = MaxPriority(wd, ['GetSecs'],['WaitSecs'],['KbCheck'],['KbWait']);
Priority(priorityLevel);

%---------------------------------------------------------------------------
%                    SCREEN LAYOUT
%---------------------------------------------------------------------------
[wdw, wdh]=Screen('WindowSize', wd);	% Get screen size 
txtsize     = round(wdh/12);            % relative text size: adjust text size to screen size
if txtsize>max_txtsize; txtsize=max_txtsize; end; % enforce maximal text size here
Screen('TextSize',wd,txtsize);			% Set size of text

if MirrorDisplay % from DrawMirroredTextDemo.m
        % Make a backup copy of the current transformation matrix for later
        % use/restoration of default state:
        % Screen('glPushMatrix', wd); % not needed 

        % Translate origin into the geometric center of text:
         Screen('glTranslate', wd, wdw/2, wdh/2, 0);
        
        % Apply a scaling transform which flips the diretion of x-Axis,
        % thereby mirroring the drawn text horizontally:
       
        if upsideDown
            Screen('glScale', wd, 1, -1, 1);
        else
            Screen('glScale', wd, -1, 1, 1);
        end
        
        % We need to undo the translations...
         Screen('glTranslate', wd, -wdw/2, -wdh/2, 0);
end

%................... Presentation coordinates 
xfrac=.5; 				% fraction of x width to use
yfrac=.5; 				% fraction of y height to use changed from 0.5
xl0=xfrac*wdw; 			% width to use in pixels
yl0=yfrac*wdh; 			% height to use in pixels
x0=(1-xfrac)/2*wdw; 	% zero point along width 3
y0=(1-yfrac)/2*wdh;		% zero point along height

%.................... The squares........................ 
boxc = x0+round([xl0*1/6  xl0*5/6]);                    % x centres left and right third of fracdisplay
box0 = round([-blw*xl0 -blh*xl0 blw*xl0 blh*xl0]/2);

% boxes for feedback -- ADAPT SIZES

       blw_f = 0.22;
       blh_f = 0.3;

boxf = round([-blw_f*xl0 -blh_f*xl0 blw_f*xl0 blh_f*xl0]/2);

% each box
for k=1:2
	box (k,:) =     box0 + [boxc(k) wdh/2.1 boxc(k) wdh/1.8];	% main boxes 
	boxl(k,:) = 1.2*box0 + [boxc(k) wdh/2.1 boxc(k) wdh/1.8];	% slightly larger box 
end
box_center    = 1.2*boxf + [wdw/2 wdh/2 wdw/2 wdh/2];

squareframe= Screen('MakeTexture',wd,repmat(reshape(green,[1 1 3]),[5 5 1]));

if doinstr
	eval(['tmp=imread(''imgs' filesep 'Instructions' filesep 'Card_1.jpg'');'])
	Card1=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'Instructions' filesep 'Card_2.jpg'');'])
	Card2=Screen('MakeTexture',wd,tmp);
else
    if  Task_Version == 'A';
        eval(['tmp=imread(''imgs' filesep 'Paar1' filesep 'Card_1.jpg'');'])
        Card1=Screen('MakeTexture',wd,tmp);
	    eval(['tmp=imread(''imgs' filesep 'Paar1' filesep 'Card_2.jpg'');'])
	    Card2=Screen('MakeTexture',wd,tmp);
    elseif Task_Version == 'B';
        eval(['tmp=imread(''imgs' filesep 'Paar2' filesep 'Card_1.jpg'');'])
        Card1=Screen('MakeTexture',wd,tmp);
	    eval(['tmp=imread(''imgs' filesep 'Paar2' filesep 'Card_2.jpg'');'])
	    Card2=Screen('MakeTexture',wd,tmp);
    end
end

%.................... The feedback depending on Exact_Drink

 % 'W' for white wine
 % 'R' for red wine
 % 'L' for limoncello
 % 'C' for campari
 % 'F' for fruit liquor

 % 'A' for apple juice
 % 'O' for orange juice
 % 'M' for multi juice
 % 'N' for ananas juice
 % 'T' for grape juice
 
 % 'E' for water

if Drink_Type == 'A' 
    if Exact_Drink == 'W'
        eval(['tmp=imread(''imgs' filesep 'wine_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'wine.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Weißwein';

    elseif Exact_Drink == 'L'
        eval(['tmp=imread(''imgs' filesep 'limoncello_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'limoncello.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Limoncello';

    elseif Exact_Drink == 'C'
        eval(['tmp=imread(''imgs' filesep 'campari_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'campari.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Campari-Orange';

    elseif Exact_Drink == 'R'
        eval(['tmp=imread(''imgs' filesep 'rotwein_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'rotwein.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Rotwein';

    elseif Exact_Drink == 'F'
        eval(['tmp=imread(''imgs' filesep 'likoer_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'likoer.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Fruchtlikör';
    end
    
elseif Drink_Type == 'J'
    if Exact_Drink == 'A'
        eval(['tmp=imread(''imgs' filesep 'apple_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'apple.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Apfelsaft';

    elseif Exact_Drink == 'O'
        eval(['tmp=imread(''imgs' filesep 'orange_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'orange.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Orangensaft';

    elseif Exact_Drink == 'N'
        eval(['tmp=imread(''imgs' filesep 'ananas_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'ananas.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Ananassaft';

    elseif Exact_Drink == 'T'
        eval(['tmp=imread(''imgs' filesep 'traube_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'traube.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Traubensaft';

    elseif Exact_Drink == 'M'
        eval(['tmp=imread(''imgs' filesep 'multi_x.tif'');'])
        loss=Screen('MakeTexture',wd,tmp);
        eval(['tmp=imread(''imgs' filesep 'multi.tif'');'])
        win=Screen('MakeTexture',wd,tmp);
        text_fb_too_slow = 'Zu langsam!';
        drinkname = 'Multivitaminsaft';
    end
    
elseif Drink_Type == 'Training'
    eval(['tmp=imread(''imgs' filesep 'water_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'water.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Wasser';    
    
end

% position to display feedback too slow
xpos_fb = x0+xl0* .2; ypos_fb = y0+yl0* .1; 
    
% write outcome explicitly, too 
col_gr    = green;
col_re    = red;

if Drink_Type == 'A'
    txt_win   = 'Gewonnen!';
    cent_win  = ['Alkohol'];
    txt_loss  = 'Verloren!';
    cent_loss = ['Kein Alkohol'];

elseif Drink_Type == 'J'
    txt_win   = 'Gewonnen!';
    cent_win  = ['Saft'];
    txt_loss  = 'Verloren!';
    cent_loss = ['Kein Saft'];
    
elseif Drink_Type == 'Training'
    txt_win   = 'Gewonnen!';
    cent_win  = ['Wasser'];
    txt_loss  = 'Verloren!';
    cent_loss = ['Kein Wasser'];
    
end


%....................... The fixation cross
% Create a fixation cross by preparing a little Matlab matrix with the image 
% of a fixation cross
 eval(['tmp=imread(''imgs' filesep 'fix_cross.bmp'');'])
 fix_cross = Screen('MakeTexture',wd,tmp);

% arrows 
eval(['tmp=imread(''imgs' filesep 'arrows.tif'');'])

arrow=Screen('MakeTexture',wd,tmp);
arrowsquare(1,:)=[wdw*.02 wdh*.92 wdw*.16 wdh*.98];

% instructions positions
addpath('instr_funcs');
yposm = 'center'; 
yposb = .8*wdh; 
ypost = .3*wdh; 
ypost2 = -.3*wdh; 
ypostt=.05*wdh;

% monitor frame rate
[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', wd);
 