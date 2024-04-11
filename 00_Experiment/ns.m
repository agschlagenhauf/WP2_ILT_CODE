

%% normalized screen: yields matlab-normalized position
% function v2=ns(v, rect, arg)
% INPUT
% v=x/y/xywh vector in matlab standard normspace
% rect: screen rectangle : something like [0 0 1280 1024]
% arg: optional 'x' or 'y' to parse only 'x' or 'y' in normSpace
% %% OUTPUT: PTB-space
%
%% EXAMPLES
%% get x-position(s)
%  x=ns([.5    ],rect,'x')
%  x=ns([.5 .9 ],rect,'x')
%% get y-position(s)
%  y=ns([.5    ],rect,'y')
%  y=ns([.5 .9 ],rect,'y')
%% get xy-position
%  xy=ns([.5  .5],rect)  %center pos
%  xy=ns([.1 .9 ],rect)  %upper left pos
%
%% get xywh-position -->IMAGES
%  xy=ns([.5  .5 .2 .2 ],rect)  %center pos -->from there 0.2 right and high
%  xy=ns([.1 .9  .9 .1 ],rect)  %upper left pos--Yfrom there fill screen with img



function v2=ns(v, rect, arg)


if 0
    
    
end

% if 0
%     [w rect]=ps_start(0)
%     faceData = imread('stim1.jpg');
%     faceTexture = Screen('MakeTexture',w,faceData);
% end

if exist('arg')~=1
    arg='';
end

if strcmp(arg,'x') %x
    v2= round(v*rect(3));
elseif  strcmp(arg,'y')%y
    v2=rect(4)-v*rect(4);
else  %xywh
    
    if length(v)==2
        v2=[round(v(1)*rect(3))   rect(4)-v(2)*rect(4) ];
    else
        
        v2=[v(1)*rect(3) ...
            rect(4)-(v(2)+v(4))*rect(4) ...
            v(1)*rect(3)+v(3)*rect(3)  ...
            rect(4)-(v(2)+v(4))*rect(4)+(v(4)*rect(4))   ];
        
        if isnan(v(4))  %proportional scale height
            v2=[v(1)*rect(3) ...
                rect(4)-(v(2)+v(4))*rect(4) ...
                v(1)*rect(3)+v(3)*rect(3)  ...
                rect(4)-(v(2)+v(4))*rect(4)+(v(4)*rect(4))   ];
            
            
            v2(2)=rect(4).*v(2);
            %             v2(4)=((v2(3)-v2(1))*(arg(2)./arg(1)))+v2(2);
            %             v2=round(v2);
            
            v2(2) =rect(4)-rect(4)*v(2);
            v2(4) = v2(2)+v2(3)-v2(1);
            
            if strcmp(arg,'center') %x
                v2=[rect(3)*v(1)-(rect(3)*v(3)/2)     nan rect(3)*v(1)+(rect(3)*v(3)/2)  nan   ];
                df=   v2(3)-v2(1);
                v(4)=df/rect(4);
                %     v2([2 4])  =[ rect(4)-(rect(4)*v(2)+(rect(4)*v(4)/2))    rect(4)-(rect(4)*v(2)-(rect(4)*v(4)/2))   ]
                %      v2([2 4]) = v2([2 4]) + df;
                v2([2 4])=rect(4)-[(rect(4)*v(2))+(df/2) (rect(4)*v(2))-(df/2) ] ; %+50
                
            end
            
            
        end
        
        
    end
end






