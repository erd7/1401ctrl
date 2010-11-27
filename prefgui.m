%Class builds user options-GUI; object is being destroyed explicitly on close request (prefs data management through global struct)
%Designe eigene Menuitem-Superklasse und konkrete Implementierungssubklassen! (Interface/Completion)
classdef prefgui < handle
   properties
      Parent
      Interface
   end
   methods
      %Constructor: //Initialize user options GUI & load default preferences; integrate in obj-management routine; edit destructor correspondingly
      function obj = prefgui(hmain)
         obj.Parent = hmain;
         Hloc = getappdata(obj.Parent,'uihandles');
         
         %Invoke GUI:
         Hloc.pref = figure('Visible','off','Position',[0,0,400,400],'MenuBar','none','Resize','off','Name','Preferences','CloseRequestFcn',@(src,evt)CloseReq(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %Build local GUI elements: //here new concrete class prefinput!
         PREFINPUT = input.prefinput(hmain);         
         obj.Interface = PREFINPUT;
         
         movegui(Hloc.pref,'center');
         set(Hloc.pref,'Visible','on');
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
         %Hier am besten PREFS update!
         %prefinput tag deletion here! make prefinput subclass of maininput (or both of userinput?) and call from there!
         APPDATloc = getappdata(obj.Parent,'appdata');
                  
         %Get number of prefinput objects:
         if isempty(APPDATloc.CURRENTOBJ.MODAL) == 0
            fn = fieldnames(APPDATloc.CURRENTOBJ.MODAL);
            
            for i=1:length(fn)
               if isempty(strfind(fn{i},cdat.classname(obj.Interface))) == 0
                  delete(obj.Interface);
                  APPDATloc.CURRENTOBJ.MODAL = rmfield(APPDATloc.CURRENTOBJ.MODAL,fn{i});
               end
            end
         end
         
         setappdata(obj.Parent,'appdata',APPDATloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.pref);
         Hloc = rmfield(Hloc,{'pref'});
         setappdata(obj.Parent,'uihandles',Hloc);

         obj.delete(); %Destroy this object
      end
      %Destructor
      function delete(obj)
      end
   end
end