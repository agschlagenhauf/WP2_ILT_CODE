fprintf('............. Displaying rating instruction \n');
i=0; clear tx ypos func;
func{1}=[];

i=i+1;
    waitfory{i}=1;
    ypos{i}=yposm;
    if runs == 1;
        tx{i}= ['Der erste Teil der Aufgabe ist abgeschlossen. Vielen Dank! \n\n Sie erhalten gleich wieder einen Schluck ' drinkname ' und beantworten bitte zwei Fragen.'];

    elseif runs == 2;
        tx{i}= ['Der zweite Teil der Aufgabe ist abgeschlossen. Vielen Dank! \n\n Sie erhalten gleich wieder einen Schluck ' drinkname ' und beantworten bitte zwei Fragen.'];
    end
    
display_payment; 

