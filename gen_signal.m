%Signal data array generation class
classdef gen_signal < handle
   properties
      ListeningTo1
      ListeningTo2
      Signal
      SignalSelection = 1; %Stelle in der mainfkt prüfen, sodass default direkt übers listening möglich wird!
      DataLength = 40000;
   end
   methods
      %Constructor:
      function obj = gen_signal(src1,src2)
         %nach Fertigstellung der Radiobuttongroup hier feststellen des selektierten Radiobuttons; zunächst Standardwert für SignalSelection
         %Radiogroup sendet event --> Update der Signalarrays!
         obj.ListeningTo1 = src1;
         obj.ListeningTo2 = src2;
         
         %Noch sauber zwischen Radiobuttons unterscheiden!
         addlistener(obj.ListeningTo1,'SelRadio1',@(src,evt)GenSin(obj,src,evt,src2.Entry1,src2.Entry2,src2.Entry3));
         addlistener(obj.ListeningTo1,'SelRadio2',@(src,evt)GenSin(obj,src,evt,src2.Entry1,src2.Entry2,src2.Entry3));
         addlistener(obj.ListeningTo2,'NewInputAlert',@(src,evt)GenSin(obj,src,evt,src2.Entry1,src2.Entry2,src2.Entry3));
         
         switch obj.SignalSelection
            case 1
               obj.GenSin(src2.Entry1,src2.Entry2,src2.Entry3);
         end
      end
      function GenSin(obj,m,n,o)
         %may use:
         %daclength = 40*durn; %40kHz; see clock setup in generating section! --> SAMPLE RATE! (VERIF.)         
         datarray = 0:(obj.DataLength-1); %1datapackage/s by default! u.U. bis zu 1s nachlauf, bis datenpaket fertig gesampled! (oder mehr? wann ist der frühstmögliche eintritt des abbruchsignals?)

         obj.Signal = m*sin(2*pi/40000*n*datarray)+o; %nota: zeitliche auflösung sinkt reziprok zur frequenz!
      end
   end
end