
%% val=vas(mode,v,a,ask,keys ,mp, parg)
% mode: [1]VAS, [2]checkbox
% val=vas(s.img{1}, {s.aud{1} s.asf1 }  ,ask,{'3#' '4$' '2@'},mp)
% v   : 3 possibilities: 
%      (1): SINGLE IMAGE --> 2D MATRIX  OR 3D-RGB-MATRIX
%      (2): MULTIIMAGE - ALREADY BUFFERED
%          cell with {buffervec imageposition}
%        -where buffervec contains the bufferNumber (n) of each image  
%        -and imageposition is a [n x 4] matrix with ptb-position (4 values) of each image
%      (3): MULTIIMAGE - NOT-ALREADY BUFFERED
%          cell with 2CELLS: {{IMAGES} {xydw-positions}}, where..
%            images contains all n-images  (stacked in cell! -->allows different IMG-sizes!!!)
%            xydw-positions; of each n-image (stacked in cell!)
%          
% a   : (optional): audio sound,  cell with {stereomatrix (time x 2channel), samplingfreq}  -->  [47657x2 double]    [44100]
%     : nosound: []
% ask : questionsstuff:  cell with {question, poleLeft, poleRight}
% keys: keys: cell with {'left' 'right' 'loggin'} key, e.g. {'3#' '4$' '2@'} or {'left' 'right' 'return'}
% mp  : additional optional parameters : struct with:
%          [isrealmode]  = [0]/[1]
%          [fontsize]  = a number, {default: 20} 
%          [tonevolume] = volume of tone, [0-1]range
% parg : OPTIONAL: addional parameter arguments (struct with filenames and values)
%         parg.lwid  : [start stop]-endpoint of VAS or outer Checkboxes-position of X-dim (normalized units)
%                       default [.3 .7]   --> vas or outer checkboxes positioned within 30% to 70% of x-width 
%         parg.lhig  : [y y]-position of VAS or outer Checkboxes-position of Y-dim (normalized units)
%                       default [.3 .3]   --> vas or outer checkboxes positioned at lower 30%  of y-width                     
%        parg.stop   : [1] stops PTB afterwards;   default [0] 
%        parg.tfixpre :  pre-fixation baseline with fixcross [seconds]; default [0]--> no postfixation period
%        parg.tfixpos : post-fixation baseline with fixcross [seconds]; default [0]--> no postfixation period
%        parg.showfix : [0][1], if [1] shows fixation cross between imgs and in pre/post baseline
%=========================
%        parg.LPT     : 3values = [device, mrk, tonTime], example [2 33 .01] -->  use PMD1024ls send marker-33 for 0.01secs 
%        parg.ET      :eyetracking: [0]no, [1]labor-ET [2] mrt-ET  --> yields 2value: timestamp/time and Getsecs
%                        -->if [1]or[2] these two values added to the output
%
%% OUT
% per. vas-range:  0:1
%% example: visual, audiovisual, audio, none
% val=vas(s.img{1}, [] ,ask,{'3#' '4$' '2@'},mp)
% val=vas(s.img{1}, {s.aud{1} s.asf1 }  ,ask,{'3#' '4$' '2@'},mp)
% val=vas([]      , {s.aud{1} s.asf1 }  ,ask,{'3#' '4$' '2@'},mp)
% val=vas([]      ,[]                   ,ask,{'3#' '4$' '2@'},mp)
% rate=vas(1,['Wie angenehm finden Sie das Getränk?'     {'sehr unangenehm' 'sehr angenehm'}],[{ '1!'  '2@' } '3#'])
%% specific checkbox/VAS position
% sx=vas(dic{i,1}  ,visu, []  ,[dic{i,4} dic{i,5}] ,key,mp,struct('lwid', [.5-.1 .5+.1] ,'lhig',[.8 .8] ));
% 
%% EXAMPLE: already-buffered images
% picID=[2 3];  %imageIDs
% dic(i,:)={2 picID  nan 'Welches Gesicht gefaellt Ihnen besser'   {'v' 'v'} };
% 
% 
% imgpos(1,:)=imgpos2ptb([ .5-.12 .6 .2 .4], s.dicho{picID(1)}  ,rect); %DEF-PIC-POSITION
% imgpos(2,:)=imgpos2ptb([ .5+.12 .6 .2 .4], s.dicho{picID(2)}  ,rect);
% buff(1) = Screen('MakeTexture',w,s.dicho{picID(1)});  % BUFFER-HANDLE
% buff(2) = Screen('MakeTexture',w,s.dicho{picID(2)});
% visu={buff imgpos }; % GRAPHICAL: BUFFERNUMBER AND POSITION
% 
% dic{i,3}=vas(dic{i,1}  ,visu, []  ,[dic{i,4} dic{i,5}] ,key,mp,...
%     struct('lwid', [.5-.1 .5+.1]));




function [val]=vas(mode,ask,keys ,parg)

%KbName('UnifyKeyNames');
% KbName('KeyNamesWindows');


%———————————————————————————————————————————————
%%   additional paras
%———————————————————————————————————————————————
if exist('parg')==0
    par.dummy=0;
else
    par=parg;
end

if ~isfield(par,'stop'   ); par.stop=0    ; end  %  default do not stop PTB


%———————————————————————————————————————————————
%%   starts PTB
%———————————————————————————————————————————————

%=========================================================================
%% CONFIG -PTB-DISPLAY
global wd;
global rect;
global logintext;
taskfin='';

%if debug==1 %debugging mode
%    [w rect]=ps_start(0);
%else %experimental mode
%    [w rect]=ps_start(1);
%end   

HideCursor;
taskfin='sca;ShowCursor; ';                %evaluate sca (ends PTB) at the end••••

fs=30;

if isfield(par,'fs1')%fontsize via params
    fs=par.fs1;
end

if isfield(par,'fs2')%fontsize via params
    fs2=par.fs2;
else
    fs2=fs; 
end

%••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

%———————————————————————————————————————————————
%%   meta-parameter
%———————————————————————————————————————————————

if isfield(par,'lwid')==1; lwid=par.lwid;  else;         lwid= [.3 .7];  end
if isfield(par,'lhig')==1; lhig=par.lhig;  else;         lhig= [.5 .5];  end


%••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
%%                            VAS
%••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

if mode==1   
    %% start here
    isini = 1;
    nc    = 0;
    isrun=1;
     tt0=GetSecs;
     rt=nan;
     dsecvec=[0 0 0];
    while isrun==1
        nc=nc+1;
        

        % linedefiniton
%         lwid= [.3 .7];
%         lhig= [.3 .3 ];
        
        % main horiz. line
        v1=ns([lwid(1) lhig(1)  ]        ,rect) ;
        v2=ns([lwid(2) lhig(2) ]        ,rect);
        
        %pole-lines left
        stp=.01; %ticksize
        pa1=ns([lwid(1) lhig(1)-stp ]        ,rect) ; %left pole-line
        pa2=ns([lwid(1) lhig(1)+stp ]        ,rect);
        
        pb1=ns([lwid(2) lhig(1)-stp ]        ,rect) ; %right pole-line
        pb2=ns([lwid(2) lhig(1)+stp ]        ,rect);
        
        % Screen('DrawLine',w,[0 255 255], 500, 200, 700 ,600, 5);
        %Screen('DrawLine',wd,[255 255 255], v1(1), v1(2), v2(1), v2(2), 6);
        %Screen('DrawLine',wd,[255 255 255], pa1(1), pa1(2), pa2(1), pa2(2), 6);
        %Screen('DrawLine',wd,[255 255 255], pb1(1), pb1(2), pb2(1), pb2(2), 6);
        
        %% QUESTION & LOGIN
        Screen('TextSize',wd,fs);
        %  DrawFormattedText(w,ask{1},'center',  ns([lhig(1)+.05] ,rect,'y'),[255 255 255],[],[],[],1);
        %sbox=ns([0  lhig(1)+.025  1 .05 ]   ,rect);
        %sbox= [mean([v1(1) v2(1)])  v2(2)-2*fs  mean([v1(1) v2(1)])  v2(2)-2*fs];
        %DrawFormattedText(w, ask{1}, 'center', 'center', [255 255 255], [], [], [], [], [], sbox);
        DrawFormattedText(wd, ask{1}, 'center', v1(2)-4*fs , [255 255 255]);
        %DrawFormattedText(wd, logintext, 'center', v1(2)+5*fs , [255 255 255]);
        Screen('TextSize',wd,fs2);
   
        %% LEFT POLE
        %sboxl=ns([0  lhig(1)-.01  lwid(1)-.01 .025 ]   ,rect);
        %sboxl= [pa2(1)-fs2 pa2(2)  pa2(1)-fs2  pa1(2)];
        %         DrawFormattedText(w, ask{2}, 'right', 'center', [255 255 255], [], [], [], [], [], sboxl);
        %xadjust=(length(ask{2})*fs2)/2
        %         DrawFormattedText(w, ask{2}, pa1(1), pa1(2)+fs2 , [255 255 255]);
        
        [xx yy zz]=DrawFormattedText(wd, ask{2}, 3000,0 , [255 255 255]);
%         xadjust=(zz(3)-zz(1))/2;
%         DrawFormattedText(w, ask{2}, v1(1)-xadjust, v1(2)+1.5*fs2 , [255 255 255]);
        %% multiplied by '0' for eytrackingRoom
        %DrawFormattedText(wd, ask{2}, v1(1)-fs2*3, v1(2)+fs*1.5  , [255 255 255]);
        %DrawFormattedText(wd, ask{2}, v1(1)-(zz(3)-zz(1))-fs2, v1(2)+fs/3  , [255 255 255]);
       %  t0=Screen('Flip',w);  %SHOW
        
        %% RIGHT POLE
        %sboxr=ns([lwid(2)+.01 lhig(1)-.01  lwid(1)-.01 .025 ]   ,rect);
%         sboxr= [pb2(1)+fs2 pb2(2)  pb2(1)+fs2  pb1(2)];
%         DrawFormattedText(w, ask{3}, 'justifytomax', 'center', [255 255 255], [], [], [], [], [], sboxr);
%         
        [xx yy zz]=DrawFormattedText(wd, ask{3}, 3000,0 , [255 255 255]);
%         xadjust=(zz(3)-zz(1))/2;
%         DrawFormattedText(w, ask{2}, v1(1)-xadjust, v1(2)+1.5*fs2 , [255 255 255]);
        
        %DrawFormattedText(wd, ask{3}, v2(1)-fs2*2.5, v1(2)+fs*1.5    , [255 255 255]);
%         DrawFormattedText(w, ask{3}, v2(1)+fs2*2, v2(2)-fs/1  , [255 0 0]);
%         DrawFormattedText(w, ask{3}, v2(1)+fs2*3, v2(2)-fs/2  , [200 0 0]);
%         DrawFormattedText(w, ask{3}, v2(1)+fs2*4, v2(2)-fs/3  , [155 0 0]);
%         DrawFormattedText(w, ask{3}, v2(1)+fs2*5, v2(2)-fs/4  , [100 0 0]);
%         if 1 %TEST
%   t0=Screen('Flip',w);  %SHOW
%         end
        
%         if 0
%          sboxr=ns([.3 .1 .4 .4 ]   ,rect);
%        [nx ny bbox]= DrawFormattedText(w, ask{3}, 'justifytomax', 'center', [255 255 255], [], [], [], [], [], sboxr);
%         t0=Screen('Flip',w);  %SHOW
%         end
        %••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
        % coursor-dot
        if isini==1
            c0   =ns([ mean(lwid)  mean(lhig) ]        ,rect);
            dotsi  =30;
            
            
            dotstep=3;
            dotsteporig=dotstep;
        end
        
        %% keyboard stuff
        if isini==0
            
%             if kbCheck==1
%                 dotstep=40;
%             else
%                 dotstep=dotsteporig;
%             end
            
%             rt=nan; 
%            while isnan(rt) 
            [keyname keynr keyID rt dsec]=waitkey( keys  , .02); %RT-aquisition
%            end
%             waitSecs(.2);
%     disp(sprintf( '%2.6f' , (dsec) ));
    dsecvec=[ dsecvec(2:end) dsec];
%     disp(sprintf( '%2.6f ' , (dsecvec) ));
        
    if sum(dsecvec>0.04)==3
        dotstep=10;
    else
         dotstep=dotsteporig;
    end
%        
%             if dsec>0.13
%                dotstep=40;  
% %                  disp('fast');
%             else
%                 dotstep=5; 
% %                dotstep=dotsteporig;  
% %                   disp('Low');
%             end
            
            if keynr==1
                c0(1)=c0(1)-dotstep;
            elseif keynr == 2
                c0(1)=c0(1)+dotstep;
            elseif keynr == 3
                %% login-situation
                if (GetSecs-tt0) > 1.0  %block login for initial time
                    isrun=0;
                end
                
            end
        end
        
        %% bordering
        if c0(1)<v1(1) ;          c0(1)=v1(1)  ; end
        if c0(1)>v2(1) ;          c0(1)=v2(1)  ; end
        
        %Screen('FillOval',wd,[0 0 255], [c0-dotsi/2 c0+dotsi/2]);
        t0=Screen('Flip',wd);  %SHOW
        
        %% reade for KB-record
        if isini==1
            isini=0;
            %pause(0.5);
        end
        
    end
    
    val=(c0(1)-v1(1))/(v2(1)-v1(1)); 
end
%••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

%••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
%%                         flip default screen
%••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
%% ok end here
    
    

%if ptbmode==1 %debugging mode
%    par.stop==0;
%else %experimental mode
%    par.stop==1;
%end 

%ShowCursor;
%sca

%———————————————————————————————————————————————
%%   clear buffer
%—————————————————————————————————————————————
% ——

%try
 %   for i=1:length(buff)
  %      try;  Screen('Close', buff(i)); end
   % end
%end







