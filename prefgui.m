%Class builds user options-GUI; object is being destroyed explicitly on close request (prefs data management through global struct)
classdef prefgui < handle
   properties
      Parent
      Prefs
   end
   methods
      %Constructor: //Initialize user options GUI & load default preferences; integrate in obj-management routine; edit destructor correspondingly
      function obj = prefgui(h)
         obj.Parent = h.main;
         Hloc = getappdata(obj.Parent,'uihandles');
         
         %Invoke GUI:
         Hloc.pref = figure('Visible','off','Position',[0,0,400,400],'MenuBar','none','Resize','off','Name','Preferences','CloseRequestFcn',@(src,evt)CloseReq(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %Build local GUI elements: //here new concrete class prefinput!
         PREFINPUT = input.prefinput(Hloc); %auch manuell zerstören?
         
         movegui(Hloc.pref,'center');
         set(Hloc.pref,'Visible','on');
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
         %Hier am besten PREFS update!
         Hloc = getappdata(obj.Parent,'uihandles');
         fig = Hloc.pref;
         Hloc = rmfield(Hloc,{'pref','lblp1'});
         setappdata(obj.Parent,'uihandles',Hloc);
         
         delete(fig); %Destroy graphic handle object: figure; all uicontrol objects are deleted automatically
         obj.delete(); %Destroy this object
      end
      %Destructor
      function delete(obj)
      end
   end
end