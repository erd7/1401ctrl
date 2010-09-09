%On event calls method for 1401 stimulation routine (data transfer & execution)
classdef togglecallback < handle
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      SignalObj
   end
   methods
      %Constructor:
      function obj = togglecallback(srcobj,srcobj2)
         obj.ListeningTo = srcobj;
         obj.SignalObj = srcobj2;
         
         addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)StimCtrl(obj,src,evt));
         addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)StimCtrl(obj,src,evt)); %Register as a ToggleOff listener to ensure stop condition
      end
      %Stimulation control:
      function StimCtrl(obj,src,evt)
         while obj.ListeningTo.ToggleState == 1
            obj.stim(src,evt);
         end
      end
      function r = stim(obj,src,evt)
         %power1401 stim routine         
         chk = -1;
         datalength = 40000; %In Generatorroutine einkapseln!
         dacScale = 32768/5; %Voltage scaling by DAC-units; CHECK "voltage resolution": note 16bit for -5V to +5V (--> 2^16/10 = 6553,6 as step width of 1V)
         
         
         MATCED32('cedSendString','MEMDAC,?;');
         chk = eval(MATCED32('cedGetString')); %does not work without eval! CLARIFY!
         %pause(0.1);  %this is an alternative to drawnow; CLARIFY!
         drawnow; %flushes the event queue

         if chk==1 || chk==0
            %Conversion of input params into DAC-units:
            dacOut = dacScale * obj.SignalObj.Signal; %output signal setup (see gen_signal()); --> dacOut will be array of size = z with all operations defined done to it --> digits (fct values) of the sinus-curve!
            %--> every successive voltage value is send to power1401! check: max. ram load!
            %--> to generate complex signals change digits of dacOut- Array manually! for realtime invent more dynamic memory management paradigm
   
            MATCED32('cedTo1401',datalength,0,dacOut);
            sz = int2str(2*datalength); %sz: number of BYTES to be sampled from; CHECK MEMDAC PARAMS UP FROM HERE! why *2? --> PRÜFE MIT OSZI!
            
            %OUTPUT: just use DAC0; immediate signal, no trigger! use HT for trigger, check exsample code; disable interrupt for output loop?
            %Define RAM sector for output!
            MATCED32('cedSendString',['MEMDAC,I,2,0,' sz ',0,1,H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
         else
            r = chk;
         end

         %read immediately!
         %MATCED32('cedSendString',['ADCMEM,I,2,1800,' sz ',0,1,H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up" 
      end
   end
end