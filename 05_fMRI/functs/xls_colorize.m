

function xls_colorize(filename,sheet,outlx,headlines,color,color2)
% function xls_colorize marks cells within an .xls-file
% 
% example
% xls_colorize(fullfile(pwd,'mist3.xls'),1, outlx,2,3)
% 
% filename..filename
% outlx...logical matrix; 1 means colorize
% headlines...number of headerlines
% color...interior object color see e.g. http://msdn.microsoft.com/en-us/library/cc296089%28v=office.12%29.aspx 
% color2 (optional)... font color; default: black


 [a(:,1) a(:,2)]=find(outlx==1);
 
%default color2= schwarz

if ~exist('color2')    
    color2=1;
end

% get(wb.Activesheet)
beg=strfind(char(1:100),'A')-1;
col=[beg+1:beg+26]';
col2=cellstr(char(col));
for i=1:10
    col2=[col2;  cellstr( char([ repmat(col(i),[size(col,1) 1])  col ]) ) ];
end

Excel = actxserver('excel.application');
WB = Excel.Workbooks.Open(filename,0,false);

for i=1:size(a,1)
    dx =[col2{a(i,2)} num2str(a(i,1)+headlines)  ];
%     dx2=[col2{a(i,2)} num2str(a(i,1)+5)  ];
%     dy=[dx ':' dx2]

    WB.Worksheets.Item(sheet).Range(dx).Interior.ColorIndex=color;
    WB.Worksheets.Item(sheet).Range(dx).Font.ColorIndex=color2;

end


% Save Workbook
WB.Save();
% Close Workbook
WB.Close();
% Quit Excel
Excel.Quit();
