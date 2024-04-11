if doscanner==0;     fprintf('............. Outside scanner \n');
                     fprintf('............. s zum Starten drücken \n');
       Screen('TextSize',wd,txtsize);
       DrawFormattedText(wd,'Gleich geht es los...',yposm,yposm,txtcolor);
       Screen('Flip',wd);       
       
       % wait for input before starting 
       while 1
             [KeyIsDown, secs, KeyCode]=KbCheck;
             if KeyIsDown; 
                key = KbName(KeyCode);
                if strcmpi(key(1),start)
                   T.time_begin = GetSecs;
                   break; 
                end
                checkabort;
             end
       end  
              
elseif doscanner==1; fprintf('............. Inside scanner \n');
                     fprintf('............. Waiting for trigger \n');
       Screen('TextSize',wd,txtsize);
       DrawFormattedText(wd,'Gleich geht es los...',yposm,yposm,txtcolor);
       Screen('Flip',wd);       
       
       % wait for trigger before starting 
       while 1
             [KeyIsDown, secs, KeyCode]=KbCheck;
             if KeyIsDown; 
                key = KbName(KeyCode);
                if strcmpi(key(1),trigger)
                   T.time_begin = GetSecs;
                   break; 
                end
                checkabort;
             end
       end
end
Screen('TextSize',wd,txt_fix);
DrawFormattedText(wd,'+',yposm,yposm,txtcolor);
T.baseline_start = Screen('Flip',wd);
WaitSecs(5-monitorFlipInterval); % 5 sec baseline befor experiment starts
Screen('TextSize',wd,txtsize);
