

%% checks whether psych-TB is running

function chk=isPTBrunning()

nwin=Screen('Windows');
if isempty(nwin)
   chk = 0;
else
   chk = 1;  
end


pause(.1);