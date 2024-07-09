if length(func)<i;func{i}=[];end
Pages=i;
page=1;

while 1

	DrawFormattedText(wd,tx{page},'center', ypos{page},txtcolor,40,[],[]); % Wrapat changed to 40 from 45
    waitfory{page};
	if ~isempty(func{page});
		eval(func{page}); % must contain 'getleftrightarrow' command 
    else
		getleftrightarrow;
	end
	if page>Pages; break;end
    checkabort;
end


