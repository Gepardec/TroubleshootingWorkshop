_Problembeschreibung_

Wir haben ein einfaches Webservice, das eine kleine Berechnung durchführt.
Solange nur wenige Benutzer aktiv sind funktioniert es so halbwegs.
Sobald aber mehrere Benutzer im System sind wird es unterträglich langsam. Bitte um Hilfe!

_Schritte zum Reproduzieren_

./deploy.sh  
./run.sh

Das Skript run.sh startet alle 500ms einen Aufruf im Hintergrund und gibt die Aufrufdauer aus.

time 0:01.01
time 0:01.50
time 0:01.49
time 0:03.00
time 0:01.48
time 0:02.99
time 0:04.49
time 0:06.00
time 0:01.46
time 0:02.97
...
time 0:27.43
time 0:28.93
time 0:30.44
time 0:31.94
time 0:33.44
time 0:34.95
time 0:36.45
time 0:37.96
time 0:39.46
time 0:40.97
time 0:42.47
time 0:43.97
