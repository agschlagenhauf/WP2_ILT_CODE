pid=instrfind('type','serial','port','COM3');
if ~isempty(pid)
    fclose(pid);
    delete(pid);
    try; clear pid;end
end
pid = serial('COM3',...%::: Verbindung herstellen :::%
    'BaudRate', 19200,...
    'Parity', 'none',...
    'DataBits', 8,...
    'StopBits', 1,...
    'Terminator','CR',...
    'Timeout', .1);
fopen(pid);    
query(pid,'*IDN'); %pumps display flashing stops
query(pid,['*DIA 28']) ; %inner diameter
%pause(0.1);% RATE (pumpingVelocity/timex): number & unit ..=velocity
query(pid,['*RAT 110' 'MM']) ;  %..[MM, UH, MH]..[mL/min muL/Hour mL/Hour]
%pause(0.1);
query(pid,['*VOL 0.5'])   ; % VOLUME pumped
%pause(0.1);
query(pid,'*DIR inf'); %pumping direction [ inf | Wdr | rev ]; infuse/withdraw/reverse

%%TEST pumps
%npumps=1;
%timx=linspace(0.1, .4 ,npumps) ;%beepingtime
%tag={};
%for i=1:npumps %3 pumps
%    tag{i}= query(pid,[num2str(i-1) 'BUZ 1' ]);
%    pause(timx(i));
%    query(pid,[num2str(i-1) 'BUZ 0' ]);
%    pause(.1);
%end

%query(pid,[num2str(0)  'RUN'])