1401 Programmier- Prizip für Analogen Output eines digital generierten Signals:
Output array definieren (host) und, wobei jede Stelle eine Spannung im Spannungsverlauf des zu generierenden Outputs aufnimmt; aufzufüllen über generatorausdruck/ funktion.
--> ebenfalls zu definieren: sample rate.
übertragung des daten array vom host RAM in den 1401 RAM; dann auslesen und generieren via MEMDAC, parameterkonstellation: CLOCK SETUP

--> pfade der headerfiles im c-code anpassen!

Programmkonzept: mainfile: initialisierungsroutine: GUI und objekterzeugung: konstruktoren erheben startwerte; im verlauf der GUI manipulation dynamische ggs. kommunikation und updates

--> MATLAB: Segmentation violation?