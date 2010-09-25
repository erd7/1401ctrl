%Class builds session settings-GUI; object is being destroyed explicitly on close request (sess data management through global struct)
classdef sessgui < handle
   properties
      Parent
      Prefs
   end
   methods
      %Constructor: //Initialize session settings GUI & load default values
      function obj = sessgui(h)
         obj.Parent = h.main;
         Hloc = getappdata(obj.Parent,'uihandles');
         
         %Invoke GUI:
         Hloc.sess = figure('Visible','off','Position',[0,0,400,400],'MenuBar','none','Resize','off','Name','Session Settings','CloseRequestFcn',@(src,evt)CloseReq(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %Build local GUI elements: //here new concrete class prefinput!
         SESSINPUT = input.sessinput(Hloc); %auch manuell zerst�ren?
         
         movegui(Hloc.sess,'center');
         set(Hloc.sess,'Visible','on');
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
         %Hier am besten APPDATA update!
         Hloc = getappdata(obj.Parent,'uihandles');
         fig = Hloc.sess;
         Hloc = rmfield(Hloc,{'sess','lbls1'});
         setappdata(obj.Parent,'uihandles',Hloc);
         
         delete(fig); %Destroy graphic handle object: figure; all uicontrol objects are deleted automatically
         obj.delete(); %Destroy this object
      end
      %Destructor
      function delete(obj)
      end
   end
end