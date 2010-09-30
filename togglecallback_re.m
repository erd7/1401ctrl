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
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)StimExec(obj,src,evt));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)StimKill(obj,src,evt)); %//Implement: Kill all sequences immediately
      end
      %Stimulation control and sampling routine:
      function StimExec(obj,src,evt)
         obj.Prefs = getappdata(obj.Parent,'preferences');

         swpz = obj.InputObj.UserInput.Entry1/2;
         fn = fieldnames(obj.SignalObj.Signal);
         chk = -1; %some initial value ~= 0,1,2,-128
         sz = int2str(4*obj.SignalObj.DataLength); %sz: number of BYTES to be sampled from; CHECK MEMDAC PARAMS UP FROM HERE! why *2? --> PRÜFE MIT OSZI! see INTERACT: Buffersize 0-80k!

         %power1401shutdown;power1401startup; %WHY IS THIS NECESSARY?
                        
         %Execute the first sampling cycle:
         MATCED32('cedSendString',['MEMDAC,I,2,0,' sz ',0,',swpz,',H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
         %Execute trigger sq:
         MATCED32('cedSendString','DIGTIM,C,10,100;'); %//implement clock rate to depend on frqsubdiv; or vice versa (everything dependent on dig sample rate!
         
         %Execute signal update & sampling loop; output is now controlled through a finite sweep number:
         for i=1:(swpz-1)
            %Conversion of input params into DAC-units and split signal array:
            dacOuth1 = obj.DacScale * obj.SignalObj.Signal.(fn{2*i+2});
            dacOuth2 = obj.DacScale * obj.SignalObj.Signal.(fn{2*i+3});
            
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
            end
                              
            if chk == 0 || chk == 1
               MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOuth1);
                  
               while chk == 1
                  %Waiting...
                  MATCED32('cedSendString','MEMDAC,?;');
                  chk = eval(MATCED32('cedGetString'));
                  drawnow;
               end
            end
            
            if chk == -128               
               MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOuth2);
               
               while chk == -128
                  %Waiting...
                  MATCED32('cedSendString','MEMDAC,?;');
                  chk = eval(MATCED32('cedGetString'));
                  drawnow;
               end
            end
         end
      end
   end
end