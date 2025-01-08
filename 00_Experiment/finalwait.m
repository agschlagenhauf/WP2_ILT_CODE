% record triggers during end baseline  

T.begin_end_baseline = GetSecs;
t=0;
KeyIsDown=0;

while (GetSecs - T.begin_end_baseline) < Z.dur_end_baseline    
    [KeyIsDown, secs, KeyCode]=KbCheck;
    if KeyIsDown; 
        key = KbName(KeyCode);
        if strcmpi(key(1),trigger)
            t=t+1;
            T.final_triggers(t) = GetSecs;
            WaitSecs(0.2)
        end
    end
   checkabort; 
end

T.end_end_baseline=GetSecs;

Screen('TextSize',wd,txtsize);
DrawFormattedText(wd,'Diese Sitzung ist vorbei...',yposm,yposm,txtcolor);
Screen('Flip',wd);

