%Class builds user options-GUI; object is being destroyed explicitly on close request (prefs data management through global struct)
classdef prefgui < handle
   properties
      Parent
      Prefs
      Hloc
   end
   methods
      %Constructor: //Initialize user options GUI & load default preferences
      function obj = prefgui(fig)
         obj.Parent = fig;

         %Invoke GUI:
         obj.Hloc.gui = figure('Visible','off','Position',[0,0,400,400],'MenuBar','none','Resize','off','Name','Preferences','CloseRequestFcn',@(src,evt)CloseReq(obj,src,evt));
         
         %Build local GUI elements: //an dieser stelle neue concrete class prefinput!
         PREFINPUT = input.prefinput(obj.Parent);
         
         movegui(obj.Hloc.gui,'center');
         set(obj.Hloc.gui,'Visible','on'); 
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
         %Hier am besten PREFS update!
         
         delete(obj.Hloc.gui); 
         obj.delete();
      end
      %Destructor
      function delete(obj)
      end
   end
end