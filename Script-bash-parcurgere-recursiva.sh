#Sa se scrie un script care primeste 2 argumente din linia de comanda:un director sursa si un director destinatie.
#Directorul sursa trebuie parcurs recursiv iar pentru fiecare intrare din director , se vor executa urmatoarele operatii:
#-pentru directoare , se va crea un director echivalent in directorul destinatie, cu aceleasi drepturi ca directorul original.
#Astfel,structura de directoare din directorul destinatie va fi asemanatoare cu cea din sursa
#-pentru fisierele obisnuite , in functie de dimensiunea fisierului , se va crea o copie sau o legatura simbolica astfel:
#	- pt fisierele cu dimensiunea mai mare de 500 octeti , se va crea o copie a fisierului in directorul destinatie
#	si dupa caz , in subfolderul echivalent.Aceste fisiere vor avea aceleasi drepturi ca fisierele originale.
#	-pt fisierele cu dimensiune mai mica de 500 octeti , se vor crea legaturi simbolice catre fisierele originale.
	

if test $# -ne 2 #testam numarul de argumente
then
    echo "numarul de argumente este invalid"
    exit
else
    echo "script loaded"
fi
if [ ! -d $1 -o ! -d $2 ] #testam daca argumentele sunt directoare
then
    echo "parametrii dati nu sunt directoare"
    echo "script stopped"
    exit
fi


allFiles=`find $1` #memoram in variabila allFiles toate fisierele din directorul sursa
nr=0;
for file in $allFiles #parcurgem fiecare fisier recursiv
do
    nr=`expr $nr + 1` 
    if [ "$nr" -ne 1 ] #ignoram prima parcurgere deoarece e chiar directorul sursa
    then
        drepturi=`stat --printf=%a "$file"` #drepturile in format octal
        aux=`echo "$file" | cut -f 2-100 -d '/'` #sterge fis sursa din path
        new_file="$2/$aux" #adaugam la path fisierul destinati
        
        if [ -d "$file" ] # verificam daca fisierul e director
        then
            mkdir $new_file # cream fisierul in path-ul dorit
            chmod "$drepturi" "$new_file" # ii dam si drepturile cerute in enunt
        fi
        
        if [ -f "$file" -a ! -d "$file" ] # verificam daca e regular file
        then
            dimensiune=`stat --printf=%s $file` #dimensiunea calculata in octeti
            
            if [ "$dimensiune" -gt 500 ] #daca dimensiunea e mai mare de 500
            then
                touch $new_file #creeam fisierul
                chmod "$drepturi" "$new_file" # ii dam drepturile cerute in enunt
            fi
            if [ "$dimensiune" -le 500 ] #daca dimensiunea e mai mica sau egala cu 500
            then
                ln -s $new_file $new_file   #creeam symbolic link
            fi
        fi
    fi
    
done
