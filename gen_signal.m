%Signal data array generation class
classdef gen_signal < handle
   properties
      Parent
      ListeningTo
      Signal
      TrigSq
      DataLength
   end
   events
      NewCalcAlert
   end
   methods
      %Constructor:
      function obj = gen_signal(h,src1,dat)
         %nach Fertigstellung der Radiobuttongroup hier feststellen des selektierten Radiobuttons; zunächst Standardwert für SignalSelection
         %Radiogroup sendet event --> Update der Signalarrays!
         obj.Parent = h.main;
         obj.ListeningTo = src1;
         obj.DataLength = dat;
         
         %Noch sauber zwischen Radiobuttons unterscheiden!
         addlistener(obj.ListeningTo,'NewInputAlert',@(src,evt)GenSignal(obj,obj.ListeningTo.UserInput));
         %Nur für das Event registrieren, wenn Reihenfolge VOR output update gesichert ist! eigenes event? oder immer aus updateroutine callen?
         %--> eigenes event scheint am sichersten, um Generator direkt vom dynamischen User Input abhängig zu machen
         %--> funktioniert noch nicht; KLÄRE!
         %addlistener(obj.ListeningTo2,'NewInputAlert',@(src,evt)GenSin(obj,src,evt,src2.Entry1,src2.Entry2,src2.Entry3));
 
         obj.GenSignal(src1.UserInput);
      end
      function GenSignal(obj,src1)
         switch obj.ListeningTo.InputState
            case 1
               obj.GenSin(src1.Entry2,src1.Entry3,src1.Entry1);
            case 2
               obj.GenConst(src1.Entry1);
            case 3
               obj.GenNoiseSq(src1.Entry1,src1.Entry2,src1.Entry3);
               obj.GenTrigSq(src1.Entry1,0); %//ISI's still dummy arg; make depend!
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
      function GenNoiseSq(obj,dur,steps,subdiv)
         z = ([1:dur*obj.DataLength/10]*0)+1; %Still assume, that sample rate is 1kHz //Split, if signal is too long! --> one minute sequence!
   
         for i=1:steps
            strlvl = ['lvl',num2str(i)];
            NSIG.(strlvl) = (awgn(z,20*log10(8*1/i),'measured')-1); %Linear increase of average RN amp; prove! Scaling factor 8 is empirical for best utilization of voltage range.
            
            for j=1:subdiv
               strsublvl = ['lvl',num2str(i),'_',num2str(j)];
               NSIG.(strsublvl) = NSIG.(strlvl)(1+obj.DataLength*(j-1):obj.DataLength*(j));
            end
   
            NSIG = rmfield(NSIG,strlvl);
         end
         
         obj.Signal = orderfields(NSIG,randperm(steps*subdiv));
      end
      function GenTrigSq(obj,dur,isi) %//Implementiere ISI-Eingabe; //In SIGNALOBJ. implementieren! --> bisher kein update zur laufzeit möglich!
         %INTERVALLMAXIMUM DARF NICHT == HÄLFTE D. STIMSUBINTERVALS BETRAGEN!
         frqsubdiv = 1000;
         time = [1:dur*frqsubdiv*10]*0; %//second factor is frq subdiv, third is measured in seconds (10 seconds for each step now);
         t1 = 3*frqsubdiv;

         for i=1:(dur)
            time(t1) = 1;
   
            t2 = t1+3*frqsubdiv+randi(3*frqsubdiv);
      
            while (i*10*frqsubdiv - t2) > 5*frqsubdiv
               t2 = t1+3*frqsubdiv+randi(3*frqsubdiv);
            end
   
            t3 = t2+3*frqsubdiv+randi(3*frqsubdiv);
   
            while t3 < (i*10*frqsubdiv)
               t3 = t2+3*frqsubdiv+randi(3*frqsubdiv);
            end
   
            time(t2) = 1;
            t1 = t3;
         end
         obj.TrigSq = find(time);
         clear time;
         
         notify(obj,'NewCalcAlert');
      end
      %Destructor:
      function delete(obj)
      end
   end
end