Screen('DrawTexture',wd,arrow,[],arrowsquare);
Screen('Flip',wd);
while 1
      [KeyIsDown, time, KeyCode]=KbCheck;
	  if KeyIsDown; 
		 key = KbName(KeyCode);
		 if iscell(key); key=key{1};end
         if waitfory{page}==1 & strcmpi(key,'y');page=page+1;break 
         elseif waitfory{page}==0 & strcmpi(key,instrforward);page=page+1;break;
         %elseif doinstr == 1 & strcmpi(key,instrforward);page=page+1;break;
         elseif strcmpi(key,instrbackward) & page>1;page=page-1; break;
         elseif strcmpi(key(1),keyleft)    & page>1;page=page-1; break; %%% Added so that participants can use response boxes for during instruction inside scanner
         elseif waitfory{page}==0 & strcmpi(key(1),keyright);page=page+1; break;            %%% Added so that participants can use response boxes for during instruction inside scanner
         %elseif doinstr == 1 & strcmpi(key(1),keyright);page=page+1; break;

	     elseif strcmpi(key,'ESCAPE'); 
             aborted=1; 
             Screen('Fillrect',wd,ones(1,3)*80);
			 text='Aborting experiment';
			 col=[200 30 0];
			 Screen('TextSize',wd,60);
			 DrawFormattedText(wd,text,'center','center',col,60);
             Screen('CloseAll')
             fclose('all')
             ShowCursor
			 error('Pressed ESC --- aborting experiment')
         end
      end
end
WaitSecs(0.3);
