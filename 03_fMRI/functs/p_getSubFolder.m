
function [subfolder subfolder2 names]=p_getSubFolder(paIN,subfold,gui ,fsep)

% function subfolder=p_getSubFolder(paIN,subfold)
% paIN='e:\test_kimsca'
% subfold={'\epi\' '\mpr\'}'
% gui: show gui4selection, [empty,0]no, [1] yes
% optional:  'fsep' for ending fileseparator/backslash
% [ dum, dum , names]=p_getSubFolder(pa1,[],0)  ;%auto: set names only (no subfolder)
% [ dum, dum , names]=p_getSubFolder(pa1,[],1)  ;%GUI : set names only (no subfolder)

if ~exist('gui')
    gui=0;
end

if gui==1
    dirs = spm_select(inf, 'dir', 'chose subjects','',  paIN);
else
    [subfold2,dirs]=spm_select('FPList',paIN,'*.*');
end
% dirs=sort(dirs);
dirs=cellstr(dirs);

if isempty(subfold)
     dirs=regexprep(dirs,'\\$','');
    if strcmp(paIN(end),filesep)==0
        paIN=[paIN filesep];
    end
    names=strrep(dirs,paIN ,'' );
    
    if exist('fsep')
        % names=regexprep(names,'\\$','');
        names=cellfun(@(names) {[names filesep ]} ,names);
    end

    [subfolder subfolder2]=deal([]);    
else
    subfold2  =sort(repmat(dirs,[length(subfold) 1]));
    dirs2   =repmat(subfold(:),[length(dirs) 1]);
    subfold2=cellfun(@(subfold2) {[subfold2 filesep]}, subfold2);

    subfolder=cellfun(@(a,b) [a,b],[ subfold2  ],dirs2,'uni',false) ;
    subfolder=strrep(subfolder,'\\','\');

    % subfolder=cellfun(@(subfold2) {[paIN subfold2]} ,subfold2)


    for i=1:length(subfold)
        subfolder2(:,i)=subfolder(~cellfun('isempty', regexpi(subfolder,subfold{i}) ));
        if exist('fsep')
            dm=subfolder2(:,i);
            subfolder2(:,i)=cellfun(@(dm) {[dm filesep]} ,dm);
        end
    end


    names=regexprep(...
        regexprep( subfolder2(:,1),regexprep(paIN,'\\','\\\'),'' ),...
        regexprep(subfold{1},'\\','\\\'),'' ) ;

    if exist('fsep')
        subfolder=cellfun(@(subfolder) {[subfolder filesep]} ,subfolder);
        names=regexprep(names,'\\\','\\') ;
    else
        names=regexprep(names,'\\','') ;
    end

    % ''
end


  
  
  
  
  
 