[foo, foo, key ] = KbCheck;
if strcmpi(KbName(key),'ESCAPE')
	aborted=1; 
	Screen('Fillrect',wd,ones(1,3)*100);
	text='Aborting experiment';
	col=[200 30 0];
	Screen('TextSize',wd,60);
	DrawFormattedText(wd,text,'center','center',col,60);
    Screen('CloseAll')
    fclose('all')
    ShowCursor
	error('Pressed ESC --- aborting experiment')
end
