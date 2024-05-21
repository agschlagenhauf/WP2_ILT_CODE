% ==== Start ====



   filt = ['^rp_*','.*\.txt$'];
   b = spm_select([Inf],'any','Select realignment parameters',[],pwd,filt);
 %  scaleme = [-3 3];
   mydata = pwd;

   for i = 1:size(b,1)

     [p nm e v] = spm_fileparts(b(i,:));

     printfig = figure;
     set(printfig, 'Name', ['Motion parameters: subject ' num2str(i) ], 'Visible', 'on');
     loadmot = load(deblank(b(i,:)));
     subplot(2,1,1);
     plot(loadmot(:,1:3));
     grid on;

     
     min1=min(min(loadmot(:,1:3))); 
     max1=max(max(loadmot(:,1:3)));

     
     if min1 > -3
         min1 = -3
     end

     if max1 < 3
        max1=3
     end

  scaleme1=[min1 max1];

     ylim(scaleme1);  % enable to always scale between fixed values as 
% set above
     title(['Motion parameters: shifts (top, in mm) and rotations (bottom, in dg)'], 'interpreter', 'none');
     subplot(2,1,2);
     plot(loadmot(:,4:6)*180/pi);
     grid on;

     %ylim(scaleme);   % enable to always scale between fixed values as 
    min2=min(min(loadmot(:,4:6))); 
     max2=max(max(loadmot(:,4:6)));

     
     if min2 > -3
         min2 = -3
     end

     if max2 < 3
        max2=3
     end

    scaleme2=[min2 max2];
     ylim(scaleme2);  % enable to always scale between fixed values as 
% set above
% title(['Data from ' p], 'interpreter', 'none');
     mydate = date;
     pbcode=regexprep(nm, {'rp_asub-', '_task-2step_bold'}, {'',''});
     motname = [p filesep 'motion_sub_' pbcode '_' mydate '.png'];
     % print(printfig, '-dpng', '-noui', '-r100', motname);  % enable to 
% print to file
saveas(gcf,motname);
     % close(printfig);   % enable to close graphic window
   end

% ==== End ====
