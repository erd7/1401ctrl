%On event calls method for 1401 stimulation routine (data transfer & execution)
classdef togglecallback_re < handle
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      SignalObj
      InputObj
      LoadObj
      Prefs
      Parent
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = togglecallback_re(h,srcobj,srcobj2,srcobj3,srcobj4)
         obj.Parent = h.main;
         obj.ListeningTo = srcobj;
         obj.SignalObj = srcobj2;
         obj.InputObj = srcobj3;
         obj.LoadObj = srcobj4;
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)StimExec(obj,src,evt));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)StimKill(obj,src,evt)); %//Implement: Kill all sequences immediately
      end
      %Stimulation control and sampling routine:
      function StimExec(obj,src,evt)
         obj.Prefs = getappdata(obj.Parent,'preferences');

         %swpz = obj.InputObj.UserInput.Entry1/2;
         %fn = fieldnames(obj.SignalObj.Signal);
         %chk = -1; %some initial value ~= 0,1,2,-128
         %sz = int2str(2*obj.SignalObj.DataLength/10); %sz: number of BYTES to be sampled from; CHECK MEMDAC PARAMS UP FROM HERE! Array range has to be duplicated due to memory management with 2byte data! NOTE: ONLY SAMPLING FROM 2BYTE DATA IS POSSIBLE!
         
         %for i=1:60
            %obj.LoadObj.Load1401(0,0,i); %//First two params are dummy arguments for src & evt
            %Execute ith sampling & trigger cycle:
            MATCED32('cedSendString','RUNCMD,G;');  
      end
   end
end