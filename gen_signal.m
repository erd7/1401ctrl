%Signal data array generation class
classdef gen_signal < handle
   properties
      ListeningTo
      %ListeningTo2
      Signal
      DataLength = 40000;
   end
   events
      NewCalcAlert
   end
   methods
      %Constructor:
      function obj = gen_signal(src1)
         %nach Fertigstellung der Radiobuttongroup hier feststellen des selektierten Radiobuttons; zunächst Standardwert für SignalSelection
         %Radiogroup sendet event --> Update der Signalarrays!
         obj.ListeningTo = src1;
         
         %Noch sauber zwischen Radiobuttons unterscheiden!
         addlistener(obj.ListeningTo,'NewInputAlert',@(src,evt)GenSignal(obj,obj.ListeningTo.UserInput));
         %Nur für das Event registrieren, wenn Reihenfolge VOR output update gesichert ist! eigenes event? oder immer aus updateroutine callen?
         %--> eigenes event scheint am sichersten, um Generator direkt vom dynamischen User Input abhängig zu machen
         %--> funktioniert noch nicht; KLÄRE!
         %addlistener(obj.ListeningTo2,'NewInputAlert',@(src,evt)GenSin(obj,src,evt,src2.Entry1,src2.Entry2,src2.Entry3));
 
         obj.GenSignal(src1.UserInput);
      end
      function GenSignal(obj,src1)
         if obj.ListeningTo.InputState == 1
            obj.GenSin(src1.Entry1,src1.Entry2,src1.Entry3);
         elseif obj.ListeningTo.InputState == 2
            obj.GenConst(src1.Entry1);
         end
         notify(obj,'NewCalcAlert');
      end
      function GenSin(obj,m,n,o)
         datarray = 0:(obj.DataLength-1); %1datapackage/s by default! u.U. bis zu 1s nachlauf, bis datenpaket fertig gesampled! (oder mehr? wann ist der frühstmögliche eintritt des abbruchsignals?)

         obj.Signal = m*sin(2*pi/40000*n*datarray)+o; %nota: zeitliche auflösung sinkt reziprok zur frequenz!
      end
      function GenConst(obj,m)
         datarray = 0:(obj.DataLength-1);
         
         obj.Signal = m*(datarray*0+1);
      end
   end
end