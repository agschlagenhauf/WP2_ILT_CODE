pid=instrfind('type','serial','port','COM3');
    if ~isempty(pid)
        fclose(pid);
        pid=[];
%         try; clear pid;end
    end