1401 Programmier- Prizip f�r Analogen Output eines digital generierten Signals:
Output array definieren (host) und, wobei jede Stelle eine Spannung im Spannungsverlauf des zu generierenden Outputs aufnimmt; aufzuf�llen �ber generatorausdruck/ funktion.
--> ebenfalls zu definieren: sample rate.
�bertragung des daten array vom host RAM in den 1401 RAM; dann auslesen und generieren via MEMDAC, parameterkonstellation: CLOCK SETUP

--> pfade der headerfiles im c-code anpassen!

Programmkonzept: mainfile: initialisierungsroutine: GUI und objekterzeugung: konstruktoren erheben startwerte; im verlauf der GUI manipulation dynamische ggs. kommunikation und updates

--> MATLAB: Segmentation violation?