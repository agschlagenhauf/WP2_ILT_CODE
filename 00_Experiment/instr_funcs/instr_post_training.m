i=0; clear tx ypos func;
func{1}=[];

i=i+1; 
	ypos{i}=ypost;
    
    tx{i}=['Die Übung ist jetzt zu Ende. Die bessere Karte war:'];
 
    if S(1) == 1 
        func{i}='Screen(''DrawTexture'',wd,Card2, [],boxl(1,:)); getleftrightarrow;';
        
    elseif S(1)== 2
        func{i}='Screen(''DrawTexture'',wd,Card1, [],boxl(1,:)); getleftrightarrow;';
    end

i=i+1; 
	ypos{i}=yposm;
    tx{i}='Wie Sie vielleicht bemerkt haben, wird die bessere Karte häufiger, aber nicht immer belohnt.'; 
    
i=i+1; 
	ypos{i}=yposm;
	tx{i}='Wenn Sie diese Aufgabe später im MRT-Scanner durchführen, werden andere Karten verwendet als in dieser Übung.';    
    
i=i+1; 
	ypos{i}=yposm;
    tx{i}='Welche Karte die bessere ist, können Sie nur durch Ausprobieren herausfinden!';
    
i=i+1; 
	ypos{i}=yposm;
	tx{i}='Außerdem werden Sie im Scanner kleine Schlucke Alkohol oder Saft als Belohnung erhalten. \n Ihr Ziel ist es, so viele Schlucke wie möglich zu erhalten! ';    

i=i+1; 
	ypos{i}=yposm;
	tx{i}='SEHR WICHTIG ist es, dass Sie erst schlucken, wenn Sie auf dem Bildschirm dazu aufgefordert werden. \n\n Bis dahin behalten Sie das Getränk bitte ruhig im Mund und konzentrieren Sie sich auf den Geschmack.';

i=i+1; 
	ypos{i}=yposm;
	tx{i}='Wir möchten jetzt sicher stellen, dass Sie alles verstanden haben. Bitte erklären Sie, was Ihre Aufgabe in diesem Gewinnspiel ist.';

instr_display;
checkabort;