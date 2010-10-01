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
         
         for i=1:60
            obj.LoadObj.Load1401(0,0,i); %//First two params are dummy arguments for src & evt
            %Execute ith sampling & trigger cycle:
            MATCED32('cedSendString','RUNCMD,G;');
         end
            
         %Execute signal update & sampling loop; output is now controlled through a finite sweep number:
         %for i=1:(swpz-1)
         %   %Conversion of input params into DAC-units and split signal array:
         %   dacOuth1 = obj.DacScale * obj.SignalObj.Signal.(fn{2*i+2});
         %   dacOuth2 = obj.DacScale * obj.SignalObj.Signal.(fn{2*i+3});
         %   
         %   MATCED32('cedSendString','MEMDAC,?;');
         %   chk = eval(MATCED32('cedGetString'));
         %   drawnow;
         %   
         %   %Run sampling cycle, hoping, that host machine is not too slow to miss chk-landmarks; //CONSIDER BETTER SAMPLING/RAM CONTROL!
         %   if chk == -128               
         %      while chk == -128
         %         %Waiting...
         %         MATCED32('cedSendString','MEMDAC,?;');
         %         chk = eval(MATCED32('cedGetString'));
         %         drawnow;
         %      end
         %   end
         %                     
         %   if chk == 0 || chk == 1
         %      for i=1:10
         %         MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOuth1((i-1)*(40000+1):i*(40000)));
         %      end
         %         
         %      while chk == 1
         %         %Waiting...
         %         MATCED32('cedSendString','MEMDAC,?;');
         %         chk = eval(MATCED32('cedGetString'));
         %         drawnow;
         %      end
         %   end
         %   
         %   if chk == -128               
         %      MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOuth2((i-1)*(40000+1):i*(40000)));
         %      
         %      while chk == -128
         %         %Waiting...
         %         MATCED32('cedSendString','MEMDAC,?;');
         %         chk = eval(MATCED32('cedGetString'));
         %         drawnow;
         %      end
         %   end
         %end
      end
   end
end