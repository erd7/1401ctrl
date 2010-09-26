%On event calls method for 1401 stimulation routine (data transfer & execution)
classdef togglecallback_re < handle
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      SignalObj
      InputObj
      Prefs
      Parent
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = togglecallback_re(h,srcobj,srcobj2,srcobj3)
         obj.Parent = h.main;
         obj.ListeningTo = srcobj;
         obj.SignalObj = srcobj2;
         obj.InputObj = srcobj3;
         
         addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)StimCtrl(obj,src,evt));
         %(Listening to ToggleOff is not necessary at all as stop condition (see below) is checked before every iteration correctly)
         
         %Following code is to be implemented at a more appropriate point:
         MATCED32('cedSendString','CLEAR');
         MATCED32('cedLdX',obj.Prefs.langpath,'MEMDAC','DIGTIM'); %In Optionen von user entry abhängig machen?
      end
      %Stimulation control and sampling routine:
      function StimCtrl(obj,src,evt)
         %Initialize necessary cmds; INSTRUCTIONS ARE APPLIED BY SENDING STRINGS TO 1401; COMMANDS SEE LANGUAGE SUPPORT
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         i = 0;
         fn = fieldnames(obj.SignalObj.Signal);
         chk = -1; %some initial value ~= 0,1,2,-128
         sz = int2str(4*obj.SignalObj.DataLength); %sz: number of BYTES to be sampled from; CHECK MEMDAC PARAMS UP FROM HERE! why *2? --> PRÜFE MIT OSZI! see INTERACT: Buffersize 0-80k!
         
         %Check if 1401 is ready and initiate data transfer:
         while chk ~= 0
            MATCED32('cedSendString','MEMDAC,?;');
            chk = eval(MATCED32('cedGetString')); %does not work without eval! CLARIFY!
            %pause(0.1);  %this is an alternative to drawnow; CLARIFY!
            drawnow; %flushes the event queue
            
            if chk == 0 %transfer whole data package initially to stimulation (double data package for noise mode)
               dacOut = obj.DacScale * [obj.SignalObj.Signal.(fn{1}),obj.SignalObj.Signal.(fn{2})]; %Conversion of input params into DAC-units:
               MATCED32('cedTo1401',2*obj.SignalObj.DataLength,0,dacOut); %Load the data to 1401 buffer (check max. RAM load); to generate complex signals change digits of dacOut- Array! for realtime manipulation invent more dynamic memory management paradigm
            end
         end
         
         %Execute the first sampling cycle:
         %TODO: Define RAM sector for output!
         MATCED32('cedSendString',['MEMDAC,I,2,0,' sz ',0,1,H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
         
         %Execute signal update & sampling loop (hoping updating is fast enough to be done before currently played address reaches first digit of update data package):
         while obj.ListeningTo.ToggleState == 1 && i < (obj.InputObj.UserInput.Entry2*obj.InputObj.UserInput.Entry3 - 2)
            %Conversion of input params into DAC-units and split signal array:
            dacOuth1 = obj.DacScale * obj.SignalObj.Signal(fn{2*i+3});
            dacOuth2 = obj.DacScale * obj.SignalObj.Signal(fn{2*i+4});
            
            MATCED32('cedSendString','MEMDAC,?;');
            chk = eval(MATCED32('cedGetString'));
            drawnow;
            
            %Run sampling cycle, hoping, that host machine is not too slow to miss chk-landmarks; //CONSIDER BETTER SAMPLING/RAM CONTROL!
            if chk == -128               
               while chk == -128
                  %Waiting...
                  MATCED32('cedSendString','MEMDAC,?;');
                  chk = eval(MATCED32('cedGetString'));
                  drawnow;
               end
                              
               if chk == 0 || chk == 1
                  MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOuth1);
                  
                  while chk == 1
                     %Waiting...
                     MATCED32('cedSendString','MEMDAC,?;');
                     chk = eval(MATCED32('cedGetString'));
                     drawnow;
                  end
                  
                  MATCED32('cedSendString',['MEMDAC,I,2,0,' sz ',0,1,H,10,10;']);
                  MATCED32('cedTo1401',obj.SignalObj.DataLength,2*obj.SignalObj.DataLength,dacOuth2);
               end
            end
            
            i = i+1;
         end
      end
   end
end