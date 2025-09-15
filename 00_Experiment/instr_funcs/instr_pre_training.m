fprintf('............. Displaying instructions \n');
i=0; clear tx ypos func;
func{1}=[];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Willkommen zu dieser Übung.\n\n Benutzen Sie bitte die rechte Pfeiltaste, um vorwärts zu blättern und die linke Pfeiltaste, um zurück zu blättern.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Dieses Spiel ist ein einfaches Kartenspiel. Es geht darum, so viele Belohnungen wie möglich zu erhalten.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
    tx{i}=['Im echten Spiel, das Sie im MRT-Scanner durchführen, sind Belohnungen kleine Schlucke Alkohol oder Saft.'];

i=i+1;
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Um Ihnen das Spiel hier zu erklären, zeigen wir Ihnen allerdings nur Bilder von Wasser. Sie erhalten hier keine Schlucke.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Der Ablauf der Übung ist ansonsten identisch zu dem echten Spiel im MRT-Scanner. Fangen wir also mit der Erklärung an.'];

    
i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
    tx{i}=['Das Spiel besteht aus zwei Teilen. In einem Teil erhalten Sie kleine Schlucke Alkohol als Belohnung. Im anderen Teil erhalten Sie kleine Schlucke Saft als Belohnung.'];    
    
i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Der Ablauf ist in beiden Teilen gleich: In jedem Durchgang wählen Sie zwischen zwei Karten.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['Immer, wenn Sie die zwei Karten sehen, haben Sie 1.5 Sekunden Zeit, eine der beiden auszuwählen.'];
    func{i}='Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));getleftrightarrow;';

i=i+1; 
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['Dazu drücken Sie mit Ihren Zeigefingern bitte die Taste "' num2str(keyleft) '" für die linke Karte und die Taste "'  num2str(keyright) '" für die rechte Karte.']; 
    func{i}='Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));getleftrightarrow;';

i=i+1;
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['Nach der Auswahl bekommen Sie eine Rückmeldung. Entweder gewinnen Sie mit der gewählten Karte einen Schluck...'];
    func{i}='Screen(''DrawTexture'',wd,squareframe,[],boxl(1,:)); Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));Screen(''DrawTexture'',wd,win,[],box_center);getleftrightarrow;';
    
i=i+1; 
    waitfory{i}=0;
	ypos{i}=ypostt;
	tx{i}=['... oder Sie erhalten Nichts.'];
    func{i}='Screen(''DrawTexture'',wd,squareframe,[],boxl(1,:)); Screen(''DrawTexture'',wd,Card1, [],box(1,:)); Screen(''DrawTexture'',wd,Card2, [],box(2,:));Screen(''DrawTexture'',wd,loss,[],box_center);getleftrightarrow;';

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
	tx{i}=['Auch ein bißchen Glück ist dabei, denn keine Karte führt immer zur Belohnung.'];

i=i+1; 
    waitfory{i}=0;
	ypos{i}=yposm;
 	tx{i}=['Sie sollen die Karte auswählen, welche am häufigsten zu Belohnung führt.\n Lassen Sie uns das kurz am Beispiel von Wasser üben.'];
        
instr_display;
