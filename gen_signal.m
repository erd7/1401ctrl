%Signal data array generation class
classdef gen_signal < handle
   properties
      Parent
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
      function obj = gen_signal(h,src1)
         %nach Fertigstellung der Radiobuttongroup hier feststellen des selektierten Radiobuttons; zunächst Standardwert für SignalSelection
         %Radiogroup sendet event --> Update der Signalarrays!
         obj.Parent = h.main;
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
            obj.GenSin(src1.Entry2,src1.Entry3,src1.Entry1);
         elseif obj.ListeningTo.InputState == 2
            obj.GenConst(src1.Entry1);
         elseif obj.ListeningTo.InputState == 3
            %objGenNoiseSq
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
      function GenNoiseSq(obj,steps)
         z = ([1:2400000]*0)+1; %Still assume, that sample rate is 40kHz //Split, if signal is too long! --> one minute sequence!
                  
         for i=1:steps
            strlvl = ['lvl',num2str(i)];
            NSIG.(strlvl) = awgn(z,(40-10*(i-1)),'measured')-1;
         end
         
         obj.Signal = orderfields(NSIG,randperm(steps));
      end
      %Destructor:
      function delete(obj)
      end
   end
end