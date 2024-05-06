fprintf(['............. Trial number ' num2str(nt) '\n'])
Screen('TextSize',wd,40);

% Get images for instructions or main experiment 
Screen('DrawTexture',wd,Card1,[],box(  random_lr(nt),:));
Screen('DrawTexture',wd,Card2, [],box(3-random_lr(nt),:));
DrawFormattedText(wd,'+','center','center',txtcolor);

% Show stimulus on screen at next possile display refresh cycle,
% and record stimulus onset time in 'startrt':
% Screen('glRotate', wd, 90)%, [rx = 0], [ry = 0] ,[rz = 1]);
[T.trial_onset(nt)] = Screen('Flip', wd); 

% Get choices 
valid_choice=0; KeyIsDown=0; 
% while loop to show stimulus until subjects response or until "duration" seconds elapsed.
while (GetSecs - T.trial_onset(nt))<=Z.max_choice_time-monitorFlipInterval 
      [KeyIsDown, endrt(nt), KeyCode]=KbCheck;
      if KeyIsDown; 
         key = KbName(KeyCode);
         if iscell(key); key=key{1};end
            if strcmpi(key(1),keyleft) || strcmp(key(1),keyright)
               break;
            end

      else key = 'nokeypress';
      end
end
% get chosen option 
if      strcmpi(key(1),keyleft) ; a_side(nt) = 1; valid_choice=1;% left was chosen 
elseif  strcmpi(key(1),keyright); a_side(nt) = 2; valid_choice=1;% right was chosen
elseif  strcmpi(key,'ESCAPE'); checkabort; return
else    a_side(nt)=NaN; valid_choice=-1; % too slow
end

% compute response time if response was made
if   KeyIsDown 
     rt(nt) = endrt(nt)-T.trial_onset(nt);
     rt_ohne_nan(nt) = endrt(nt)-T.trial_onset(nt);
else rt(nt)=NaN;
     rt_ohne_nan(nt) = 0;
end


% Display feedback only for valid trials
if valid_choice==1; 
   % A=1 for Card 2; A=2 for Card 1 (A = chosen card)
   if   random_lr(nt)==2; A(nt) = a_side(nt);
   else A(nt) = 3-a_side(nt);
   end

   % compute feedback according to probabilities
   if      S(nt) == A(nt) && p_u(nt)==0                          % informative reward     = correct rewarded response
           C(nt) =  1;
           R(nt) =  1;
   elseif  S(nt) == A(nt) && p_u(nt)==1                          % misleading punishment  = probabilistic error 
           C(nt) =  1;
           R(nt) = -1;
   elseif S(nt) ~= A(nt)  && p_u(nt)==1                          % misleading reward      = probabilistic win
           C(nt) =  0;
           R(nt) =  1;
   elseif S(nt) ~= A(nt)  && p_u(nt)==0                          % informative punishment = incporrect response
           C(nt) =  0;
           R(nt) = -1;
   end

   %........................ Draw boxes and frame around choosen square
   % Display feedback
   Screen('DrawTexture',wd,squareframe, [],boxl(a_side(nt),:));
   Screen('DrawTexture',wd,Card1,[],box(  random_lr(nt),:));
   Screen('DrawTexture',wd,Card2,[],box(3-random_lr(nt),:));
   DrawFormattedText(wd,'+','center','center',txtcolor);
   [T.choice_onset(nt)]=Screen('Flip', wd);

   %% Wait ISI and keep showing cards
   DrawFormattedText(wd,'+','center','center',txtcolor);
   pres_ISI(nt) =  Z.max_choice_time - rt(nt); 
   WaitSecs(pres_ISI(nt)-monitorFlipInterval);
  
   % Display feedback
   Screen('DrawTexture',wd,squareframe, [],boxl(a_side(nt),:));
   Screen('DrawTexture',wd,Card1,[],box(  random_lr(nt),:));
   Screen('DrawTexture',wd,Card2,[],box(3-random_lr(nt),:));

   if     R(nt)==1
          Screen('DrawTexture',wd,win,[],box_center);
   elseif R(nt)==-1
          Screen('DrawTexture',wd,loss,[],box_center);
   end

   % write outcome explicitly, too 
   if     R(nt)==1
          text1 = txt_win; 
          text2 = cent_win; 
          ocol  = col_gr;
   elseif R(nt)==-1
          text1 = txt_loss; 
          text2 = cent_loss; 
          ocol  = col_re; 
   end
   Screen('TextSize',wd,txtsize);
   
   % Comment in if feedback should be shown between cards, comment out for feedback without cards 
   [wt]=Screen(wd,'TextBounds',text1);  ypos1= round(box_center(2)- 1.5*wt(4)); % position above coin (text: won or lost)
   %[wt]=Screen(wd,'TextBounds',text2);  ypos2= round(box_center(4)+ 1.5*wt(4));  % position below coin (text: xy cent)
   DrawFormattedText(wd,text1,'center',ypos1,ocol);     
   %DrawFormattedText(wd,text2,'center',ypos2,ocol);   
   T.onset_fb(nt) = Screen('Flip', wd);
   if ~strcmp(session, 'Training') &  pump==1 
       if R(nt)==1; query(pid,[num2str(0)  'RUN']); end 
   end
   WaitSecs(Z.display_fb-monitorFlipInterval);
   
   %Display Taste and Swallow screens if feedback was win
   if R(nt)==1
       %Display Taste screen
       Screen('TextSize',wd,txt_fix);
       DrawFormattedText(wd,'+','center','center',txtcolor);
       T.onset_taste(nt) = Screen('Flip', wd);  
       WaitSecs(Z.display_taste-monitorFlipInterval);  
       
       %Then display Swallow screen
       Screen('TextSize',wd,txt_fix);
       DrawFormattedText(wd,'SCHLUCKEN!','center','center',txtcolor);
       T.onset_swallow(nt) = Screen('Flip', wd);  
       WaitSecs(Z.display_swallow-monitorFlipInterval);
   end    
   

elseif valid_choice==-1
% Display feedback when response was too slow
       Screen('TextSize',wd,txtsize);
       Screen('DrawTexture',wd,Card1, [],box(  random_lr(nt),:));
       Screen('DrawTexture',wd,Card2,  [],box(3-random_lr(nt),:));
       DrawFormattedText(wd,'+','center','center',txtcolor);
       DrawFormattedText(wd,text_fb_too_slow,'center',ypos_fb,red);
       T.onset_fb(nt) = Screen('Flip', wd); 
       WaitSecs(Z.display_fb-monitorFlipInterval);
       A(nt)   = NaN;
       R(nt)   = NaN;
       C(nt)   = NaN;
end


%% Wait ITI and show fixationcross
Screen('TextSize',wd,txt_fix);
DrawFormattedText(wd,'+','center','center',txtcolor);
if doinstr 
   pres_ITI(nt) = 2.5;
else 
   pres_ITI(nt) = Z.min_display_fix_cross + ITI(nt) - rt_ohne_nan(nt); 
end

%%

T.onset_trialend(nt) = Screen('Flip', wd);
WaitSecs(pres_ITI(nt)-monitorFlipInterval); 
 
checkabort;