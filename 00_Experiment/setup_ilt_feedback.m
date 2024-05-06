%....................The squares

if doinstr
	eval(['tmp=imread(''imgs' filesep 'Instructions' filesep 'Card_1.jpg'');'])
	Card1=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'Instructions' filesep 'Card_2.jpg'');'])
	Card2=Screen('MakeTexture',wd,tmp);
else
    if  Task_Version == 'A';
        eval(['tmp=imread(''imgs' filesep 'Paar1' filesep 'Card_1.jpg'');'])
        Card1=Screen('MakeTexture',wd,tmp);
	    eval(['tmp=imread(''imgs' filesep 'Paar1' filesep 'Card_2.jpg'');'])
	    Card2=Screen('MakeTexture',wd,tmp);
    elseif Task_Version == 'B';
        eval(['tmp=imread(''imgs' filesep 'Paar2' filesep 'Card_1.jpg'');'])
        Card1=Screen('MakeTexture',wd,tmp);
	    eval(['tmp=imread(''imgs' filesep 'Paar2' filesep 'Card_2.jpg'');'])
	    Card2=Screen('MakeTexture',wd,tmp);
    end
end

%.................... The feedback depending on Exact_Drink

 % 'W' for white wine
 % 'R' for red wine
 % 'L' for limoncello
 % 'C' for campari
 % 'F' for fruit liquor

 % 'A' for apple juice
 % 'O' for orange juice
 % 'M' for multi juice
 % 'N' for ananas juice
 % 'T' for grape juice
 
 % 'E' for water

if Exact_Drink == 'W'
    eval(['tmp=imread(''imgs' filesep 'wine_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'wine.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Weißwein';
    
elseif Exact_Drink == 'L'
    eval(['tmp=imread(''imgs' filesep 'limoncello_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'limoncello.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Limoncello';
    
elseif Exact_Drink == 'C'
    eval(['tmp=imread(''imgs' filesep 'campari_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'campari.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Campari-Orange';

elseif Exact_Drink == 'R'
    eval(['tmp=imread(''imgs' filesep 'rotwein_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'rotwein.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Rotwein';

elseif Exact_Drink == 'F'
    eval(['tmp=imread(''imgs' filesep 'likoer_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'likoer.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Fruchtlikör';
    
elseif Exact_Drink == 'A'
    eval(['tmp=imread(''imgs' filesep 'apple_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'apple.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Apfelsaft';

elseif Exact_Drink == 'O'
    eval(['tmp=imread(''imgs' filesep 'orange_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'orange.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Orangensaft';

elseif Exact_Drink == 'N'
    eval(['tmp=imread(''imgs' filesep 'ananas_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'ananas.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Ananassaft';

elseif Exact_Drink == 'T'
    eval(['tmp=imread(''imgs' filesep 'traube_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'traube.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Traubensaft';
    
elseif Exact_Drink == 'M'
    eval(['tmp=imread(''imgs' filesep 'multi_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'multi.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Multivitaminsaft';
    
elseif Exact_Drink == 'E'
    eval(['tmp=imread(''imgs' filesep 'water_x.tif'');'])
    loss=Screen('MakeTexture',wd,tmp);
    eval(['tmp=imread(''imgs' filesep 'water.tif'');'])
    win=Screen('MakeTexture',wd,tmp);
    text_fb_too_slow = 'Zu langsam!';
    drinkname = 'Wasser';    
    
end

% position to display feedback too slow
xpos_fb = x0+xl0* .2; ypos_fb = y0+yl0* .1; 
    
% write outcome explicitly, too 
col_gr    = green;
col_re    = red;

if Drink_Type == 'A'
    txt_win   = 'Gewonnen!';
    cent_win  = ['Alkohol'];
    txt_loss  = 'Verloren!';
    cent_loss = ['Kein Alkohol'];

elseif Drink_Type == 'J'
    txt_win   = 'Gewonnen!';
    cent_win  = ['Saft'];
    txt_loss  = 'Verloren!';
    cent_loss = ['Kein Saft'];
    
elseif Drink_Type == 'Training'
    txt_win   = 'Gewonnen!';
    cent_win  = ['Wasser'];
    txt_loss  = 'Verloren!';
    cent_loss = ['Kein Wasser'];
    
end
 