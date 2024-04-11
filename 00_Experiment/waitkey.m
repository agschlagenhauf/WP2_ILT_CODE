
%% get RT , first response
% input: keys:  [] any key allowed
%               {} with keystrings, i.e {'space' ,'escape'} check whether 'space or 'escape' is pressed
%        t   : timeWindow to measure rt in seconds 
%          
%  output:  keyname:  'string' of the pressed key,
%                     no response: ''
%             keynr:  if keys is a cell with predefined keys, keynr yields the index
%                     if keys is {'space' ,'escape'}  and 'escape' was pressed keynr is 2
%                     no response: 0
%             keyID:  internal keyboardMapping-ID
%                     no response: []
%                rt: Key-RTtime in seconds since function was called
%                    no response: nan
%  NOTE: funtion terminates instantely if predefined key was pressed                  
%  example: 
%  %wait 3s for spacekey
%     [keyname keynr keyID rt]=waitkey({'space'}, 3)
%  %waits infinitely for keys 1 or 2
%     [keyname keynr keyID rt]=waitkey({ '3#'  '4$' }, inf)
%  %waits 2s for left or right arrow key
%     [keyname keynr keyID rt]=waitkey({ 'left'  'right' }, 2)
%  %waits infinitely for  any key
%     [keyname keynr keyID rt]=waitkey([], inf)
     
     
function   [keyname keynr keyID rt deltasec]=waitkey(keys, t )

% if 0
%   tic; snip_getRT; toc  
%   [keyname keynr keyID rt]=waitkey({},2 )
% end

% KbCheck
% KbCheck
if ischar(keys)
    keys={keys};
end
%------
keyname=''; keynr=0; rt=nan; keyID=[];
deltasec=0;
t0=GetSecs;
isrun=1;

while GetSecs<t0+t
    [isdown td key deltasec]=KbCheck;
    
    if isdown %any key pressed
        
        
        if isempty(keys) %all keys allowed
            keyID=find(key);
            keyname=KbName(keyID);
            keynr=0;
            rt=td-t0;
            isrun=0;
        else    %specific keys allowd
            keyID=find(key);
            
            %ABORT USING ESC
            if strcmp( (KbName(keyID)),'ESCAPE')
                disp('abort');
                sca;
                i=-1; %aborts outer loop
                break
            end
            
          
            for i=1:length(keys)
                if strcmp(lower(KbName(keyID)) , lower(keys{i}))
                    keynr=i;
                    keyname=KbName(keyID);
                    rt=td-t0;
                    isrun=0;
                    
                end
            end
        end
       
       if isrun==0
           break
       end
        
    end
end

  
        
        
        