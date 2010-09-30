%Class loads the user specified program design to 1401 on GUI request
classdef load1401
   properties
      Parent
      SignalObj
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = load1401(h,src1)
         obj.Parent = h.main;
         Hloc = getappdata(obj.Parent,'uihandles');
         PREFSloc = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         Hloc.push1 = uicontrol('Style','Pushbutton','String','LOAD 1401','Position',[200,75,100,25],'Callback',@(src,evt)Load1401(obj,src,evt));
         
         setappdata(obj.Parent,'uihandles',Hloc);
      end
      function Load1401(obj,src,evt)
         power1401startup(); %//Make depend on former calls;
         MATCED32('cedLdX','C:\1401Lang\','RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
         MATCED32('cedSendString','CLEAR');
         
         %Load initial data package of DAC sq:
         %TODO: Define RAM sector for output!
         fn = fieldnames(obj.SignalObj.Signal);
         dacOut = obj.DacScale * [obj.SignalObj.Signal.(fn{1}),obj.SignalObj.Signal.(fn{2})];
         pause(0.2);
         MATCED32('cedTo1401',2*obj.SignalObj.DataLength,0,dacOut); %//2*obj.SignalObj.DataLength
         MATCED32('cedTo1401',2*obj.SignalObj.DataLength,0,dacOut);
         
         %Load trigger sq to 1401:
         runs = length(obj.SignalObj.TrigSq);
         trigint = obj.SignalObj.TrigSq(1);    
                  
         MATCED32('cedSendString',['DIGTIM,SI,',num2str(2^22),',',num2str(2*16*runs),';']);
         MATCED32('cedSendString',['DIGTIM,A,1,1,',num2str(trigint),';']);
         MATCED32('cedSendString','DIGTIM,A,1,0,2;');
         
         for i=1:(runs-1)
            trigint = obj.SignalObj.TrigSq(i+1)-obj.SignalObj.TrigSq(i)-2;
            MATCED32('cedSendString',['DIGTIM,A,1,1,',num2str(trigint),';']);
            MATCED32('cedSendString','DIGTIM,A,1,0,2;');
         end
         MATCED32('cedSendString','DIGTIM,OD;');
      end
   end
end