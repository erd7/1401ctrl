%On event calls method for 1401 stimulation routine (data transfer & execution)
classdef togglecallback < handle
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      SignalObj
      Prefs
      Parent
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = togglecallback(fig,srcobj,srcobj2)
         obj.Parent = fig;
         obj.ListeningTo = srcobj;
         obj.SignalObj = srcobj2;
         
         addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)StimCtrl(obj,src,evt));
         %(Listening to ToggleOff is not necessary at all as stop condition (see below) is checked before every iteration correctly)
      end
      %Stimulation control and sampling routine:
      function StimCtrl(obj,src,evt)
         %Initialize necessary cmds; INSTRUCTIONS ARE APPLIED BY SENDING STRINGS TO 1401; COMMANDS SEE LANGUAGE SUPPORT
         obj.Prefs = getappdata(obj.Parent,'preferences');
         MATCED32('cedSendString','CLEAR');
         MATCED32('cedLdX',obj.Prefs.langpath,'MEMDAC','ADCMEM');
         
         chk = -1; %some initial value ~= 0,1,2,-128
         sz = int2str(2*obj.SignalObj.DataLength); %sz: number of BYTES to be sampled from; CHECK MEMDAC PARAMS UP FROM HERE! why *2? --> PRÜFE MIT OSZI! see INTERACT: Buffersize 0-80k!
         
         while chk ~= 0
            MATCED32('cedSendString','MEMDAC,?;');
            chk = eval(MATCED32('cedGetString')); %does not work without eval! CLARIFY!
            %pause(0.1);  %this is an alternative to drawnow; CLARIFY!
            drawnow; %flushes the event queue
            
            if chk == 0 %transfer whole data package initially to stimulation
               dacOut = obj.DacScale * obj.SignalObj.Signal; %Conversion of input params into DAC-units:
               MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOut); %Load the data to 1401 buffer (check max. RAM load); to generate complex signals change digits of dacOut- Array! for realtime manipulation invent more dynamic memory management paradigm
            end
         end
         
         %Execute the first sampling cycle:
         %OUTPUT: just use DAC0; immediate signal, no trigger! use HT for trigger, check exsample code; disable interrupt for output loop?
         %Define RAM sector for output!
         MATCED32('cedSendString',['MEMDAC,I,2,0,' sz ',0,1,H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
         
         %Execute signal update & sampling loop (hoping updating is fast enough to be done before currently played address reaches first digit of update data package):
         while obj.ListeningTo.ToggleState == 1
            %Conversion of input params into DAC-units and split signal array:
            dacOuth1 = obj.DacScale * obj.SignalObj.Signal(1:(length(obj.SignalObj.Signal)/2));
            dacOuth2 = obj.DacScale * obj.SignalObj.Signal((length(obj.SignalObj.Signal)/2+1):(length(obj.SignalObj.Signal)));
            
            MATCED32('cedSendString','MEMDAC,?;');
            chk = eval(MATCED32('cedGetString'));
            drawnow;
            
            if chk==0 || chk==1
               MATCED32('cedTo1401',(obj.SignalObj.DataLength/2),0,dacOuth1);
               MATCED32('cedSendString',['MEMDAC,I,2,0,' sz ',0,1,H,10,10;']);
            elseif chk==2 %Developing machine seems to be too slow to catch 1401 within status 2; try on faster hosts!
               MATCED32('cedTo1401',(obj.SignalObj.DataLength/2),2*obj.SignalObj.DataLength,dacOuth2); %verif. start address!
            end
         end
      end
      %Separate stim routine is currently obsolete:      
%      function r = stim(obj,src,evt)
%      
%      end
   end
end