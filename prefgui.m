%Class builds user options-GUI; object is being destroyed explicitly on close request (prefs data management through global struct)
%Designe eigene Menuitem-Superklasse und konkrete Implementierungssubklassen! (Interface/Completion)
classdef prefgui < handle
   properties
      Parent
      Prefs
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
         PREFINPUT = input.prefinput(hmain); %auch manuell zerstören?
         
         movegui(Hloc.pref,'center');
         set(Hloc.pref,'Visible','on');
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
         %Hier am besten PREFS update!
         %prefinput tag deletion here! make prefinput subclass of maininput (or both of userinput?) and call from there!
         Hloc = getappdata(obj.Parent,'uihandles');
         fig = Hloc.pref;
         
         fn = fieldnames(Hloc);
         
         %Remove every registration entry of related uicontrol objects:         
         for i=1:length(fn)
            if isempty(strfind(fn{i},'prefinput')) == 0
               Hloc = rmfield(Hloc,fn{i});
            end
         end
                  
         Hloc = rmfield(Hloc,{'pref'});
         setappdata(obj.Parent,'uihandles',Hloc);
         
         delete(fig); %Destroy graphic handle object: figure; all uicontrol objects are deleted automatically
         obj.delete(); %Destroy this object
      end
      %Destructor
      function delete(obj)
      end
   end
end