%On event calls method for 1401 stimulation routine (data transfer & execution)
classdef crun1401 < handle
   properties (SetAccess = public, GetAccess = public)
      ToggleState = 0;
      ListeningTo
      SignalObj
      InputObj
      LoadObj
      Prefs
      Parent
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   events
      ToggleOn
      ToggleOff
   end
   methods
      %Constructor:
      function obj = crun1401(hmain,inidat,src1,src2,src3)
         obj.Parent = hmain;
         obj.ListeningTo = obj;
         obj.SignalObj = src1;
         obj.InputObj = src2;
         obj.LoadObj = src3;
         Hloc = getappdata(obj.Parent,'uihandles');
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc.toggle = uicontrol('Style','togglebutton','String',inidat{2},'Position',inidat{1},'Enable','off','Callback',@(src,evt)ToggleCheck(obj,src,evt));
         setappdata(hmain,'uihandles',Hloc);
         
         if inidat{3} == 1
            set(Hloc.toggle,'Enable','on');
         end
         
         %Listen for own event; event chosen because of global status option on occasion; IMPLEMENT IN CALLBACK BUT MAINTAIN EVENTS?
         addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)StimExec(obj,src,evt));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)StimKill(obj,src,evt)); %//Implement: Kill all sequences immediately
      end
      %Internal callback & event notifier:
      function ToggleCheck(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         if (get(Hloc.toggle,'Value') ~= obj.ToggleState) && (get(Hloc.toggle,'Value') == get(Hloc.toggle,'Max'))
            obj.ToggleState = 1;
            notify(obj,'ToggleOn');
         elseif (get(Hloc.toggle,'Value') ~= obj.ToggleState) && (get(Hloc.toggle,'Value') == get(Hloc.toggle,'Min'))
            obj.ToggleState = 0;
            notify(obj,'ToggleOff')
         end
      end
      %Stimulation control and sampling routine:
      function StimExec(obj,src,evt)
         obj.Prefs = getappdata(obj.Parent,'preferences');
         Hloc = getappdata(obj.Parent,'uihandles');

         MATCED32('cedSendString','RUNCMD,G;');
         
         %set(Hloc.toggle,'Enable','off'); %//ONLY AFTER OR IF TGGLE IS RELEASED!
                     
         %IMPORTANT! IMPLEMENT WITH MONITOR ROUTINE IN GUIOUT CLASS!
         %while obj.ToggleState == 1
         %   addr = str2double(MATCED32('cedGetString'));
         %   display(addr);
         %end
         clear Hloc;
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.toggle);
         Hloc = rmfield(Hloc,'toggle');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end