# Problembeschreibung

Kunden beschweren sich immer wieder wegen langen Wartezeiten.
Diese beschwerden häufen sich um die Mittagszeit herum, wo in der Applikation am meisten los ist.
In den Logs sehen wir allerdings, dass die Antwortzeit gleich bleibt.

# Schritte zum Reproduzieren

```bash
java -jar configure/slow-quarkus-example-1.0.0-SNAPSHOT-runner.jar &
sleep 2
./load-test.sh
```
# Applikation stoppen
```bash
pkill -lf slow-quarkus-example 
```
