fprintf('............. Displaying instructions \n');
i=0; clear tx ypos func;
func{1}=[];

i=i+1; 
    waitfory{i}=0;
	%ypos{i}=yposm;
    ypos{i}=ypost;

    if runs == 2
        ypos{i}=yposm;
        tx{i}='Nun beginnt der zweite Teil vom Spiel. \n\n\n\n\n\n\n\n\n\n\n\n Sie k�nnen sich wieder selbstst�ndig durch die Instruktion klicken.';
        func{i}='Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));getleftrightarrow;';
    elseif runs == 1
        tx{i}='Willkommen zum Kartenspiel! \n\n\n\n\n\n\n\n\n\n\n\n Klicken Sie sich bitte selbstst�ndig durch die Instruktion.';
        func{i}='Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));getleftrightarrow;';

    i=i+1; 
        waitfory{i}=0;
        ypos{i}=yposm;
        tx{i}=['Zur Erinnerung: Sie sollen durch Ausprobieren herausfinden, welche Karte h�ufiger zur Belohnung f�hrt. \n\n Um eine Karte auszuw�hlen, dr�cken Sie die linke oder rechte Taste. \n\n Ihr Ziel ist es, so viele Schlucke wie m�glich zu erhalten!'];
    end
    
if Drink_Type == 'J'
    i=i+1; 
        waitfory{i}=0;
        ypos{i}=ypost/1.5;
        tx{i}=['Sie erhalten im folgenden Teil des Spiels ' drinkname ' als Belohnung!'];
        func{i}='Screen(''DrawTexture'',wd,win,[],box_center);getleftrightarrow;';
elseif Drink_Type == 'A'
    i=i+1;
        waitfory{i}=0;
        ypos{i}=ypost/1.5;
        tx{i}=['Sie erhalten im folgenden Teil des Spiels ' drinkname ' als Belohnung!'];
        func{i}='Screen(''DrawTexture'',wd,win,[],box_center);getleftrightarrow;';
end

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}='SEHR WICHTIG ist es, dass Sie erst schlucken, sobald Sie auf dem Bildschirm dazu aufgefordert werden. \n\n Bis dahin behalten Sie das Getr�nk bitte ruhig im Mund und konzentrieren Sie sich auf den Geschmack.';

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Bitte behalten Sie die Mundst�cke w�hrend des gesamten Spiels vollst�ndig im Mund und bewegen Sie diese nicht. \n\n Bitte ziehen Sie das Getr�nk NICHT aktiv aus dem Schlauch ein, sondern warten Sie, bis Sie einen Schluck erhalten.'];

i=i+1; 
    waitfory{i}=1;
	ypos{i}=yposm;
	tx{i}=['Sie erhalten gleich den ersten Schluck ' drinkname ' und beantworten bitte zwei Fragen dazu. \n\n Danach startet das Spiel. Viel Spa�!'];

instr_display;
