i=0; clear tx ypos func;
func{1}=[];

i=i+1; 
	ypos{i}=ypost;
    
    tx{i}=['Die �bung ist jetzt zu Ende. Die bessere Karte war:'];
 
    if S(1) == 1 
        func{i}='Screen(''DrawTexture'',wd,Card2, [],boxl(1,:)); getleftrightarrow;';
        
    elseif S(1)== 2
        func{i}='Screen(''DrawTexture'',wd,Card1, [],boxl(1,:)); getleftrightarrow;';
    end

i=i+1; 
	ypos{i}=yposm;
    tx{i}='Wie Sie vielleicht bemerkt haben, wird die bessere Karte h�ufiger, aber nicht immer belohnt.'; 
    
i=i+1; 
	ypos{i}=yposm;
	tx{i}='Wenn Sie diese Aufgabe sp�ter im MRT-Scanner durchf�hren, werden andere Karten verwendet als in dieser �bung.';    
    
i=i+1; 
	ypos{i}=yposm;
    tx{i}='Welche Karte die bessere ist, k�nnen Sie nur durch Ausprobieren herausfinden!';
    
i=i+1; 
	ypos{i}=yposm;
	tx{i}='Au�erdem werden Sie im Scanner kleine Schlucke Alkohol oder Saft als Belohnung erhalten. \n Ihr Ziel ist es, so viele Schlucke wie m�glich zu erhalten! ';    

i=i+1; 
	ypos{i}=yposm;
	tx{i}='SEHR WICHTIG ist es, dass Sie erst schlucken, wenn Sie auf dem Bildschirm dazu aufgefordert werden. \n\n Bis dahin behalten Sie das Getr�nk bitte ruhig im Mund und konzentrieren Sie sich auf den Geschmack.';

i=i+1; 
	ypos{i}=yposm;
	tx{i}='Wir m�chten jetzt sicher stellen, dass Sie alles verstanden haben. Bitte erkl�ren Sie, was Ihre Aufgabe in diesem Gewinnspiel ist.';

instr_display;
checkabort;