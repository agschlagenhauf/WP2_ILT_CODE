fprintf('............. Displaying instructions \n');
i=0; clear tx ypos func;
func{1}=[];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Willkommen zu dieser �bung.\n\n Benutzen Sie bitte die rechte Pfeiltaste, um vorw�rts zu bl�ttern und die linke Pfeiltaste, um zur�ck zu bl�ttern.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Dieses Spiel ist ein einfaches Kartenspiel. Es geht darum, so viele Belohnungen wie m�glich zu erhalten.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
    tx{i}=['Im echten Spiel, das Sie im MRT-Scanner durchf�hren, sind Belohnungen kleine Schlucke Alkohol oder Saft.'];

i=i+1;
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Um Ihnen das Spiel hier zu erkl�ren, zeigen wir Ihnen allerdings nur Bilder von Wasser. Sie erhalten hier keine Schlucke.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Der Ablauf der �bung ist ansonsten identisch zu dem echten Spiel im MRT-Scanner. Fangen wir also mit der Erkl�rung an.'];

    
i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
    tx{i}=['Das Spiel besteht aus zwei Teilen. In einem Teil erhalten Sie kleine Schlucke Alkohol als Belohnung. Im anderen Teil erhalten Sie kleine Schlucke Saft als Belohnung.'];    
    
i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Der Ablauf ist in beiden Teilen gleich: In jedem Durchgang w�hlen Sie zwischen zwei Karten.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['Immer, wenn Sie die zwei Karten sehen, haben Sie 1.5 Sekunden Zeit, eine der beiden auszuw�hlen.'];
    func{i}='Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));getleftrightarrow;';

i=i+1; 
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['Dazu dr�cken Sie mit Ihren Zeigefingern bitte die Taste "' num2str(keyleft) '" f�r die linke Karte und die Taste "'  num2str(keyright) '" f�r die rechte Karte.']; 
    func{i}='Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));getleftrightarrow;';

i=i+1;
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['Nach der Auswahl bekommen Sie eine R�ckmeldung. Entweder gewinnen Sie mit der gew�hlten Karte einen Schluck...'];
    func{i}='Screen(''DrawTexture'',wd,squareframe,[],boxl(1,:)); Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));Screen(''DrawTexture'',wd,win,[],box_center);getleftrightarrow;';
    
i=i+1; 
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['... oder Sie erhalten Nichts.'];
    func{i}='Screen(''DrawTexture'',wd,squareframe,[],boxl(1,:)); Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));Screen(''DrawTexture'',wd,loss,[],box_center);getleftrightarrow;';

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Auch ein bi�chen Gl�ck ist dabei, denn keine Karte f�hrt immer zur Belohnung.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
 	tx{i}=['Sie sollen die Karte ausw�hlen, welche am h�ufigsten zu Belohnung f�hrt.\n Lassen Sie uns das kurz am Beispiel von Wasser �ben.'];
        
instr_display;
