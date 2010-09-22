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
         obj.Hloc = getappdata(obj.Parent,'uihandles');
         
         %Invoke GUI:
         obj.Hloc.pref = figure('Visible','off','Position',[0,0,400,400],'MenuBar','none','Resize','off','Name','Preferences','CloseRequestFcn',@(src,evt)CloseReq(obj,src,evt));
         
         %Build local GUI elements: //here new concrete class prefinput!
         PREFINPUT = input.prefinput(obj.Parent);
         obj.Hloc.lbl = uicontrol('Style','text','String','Specify 1401 language support path:','Position',[25,375,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         
         setappdata(obj.Parent,'uihandles',obj.Hloc);
         
         movegui(obj.Hloc.pref,'center');
         set(obj.Hloc.pref,'Visible','on');
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
         %Hier am besten PREFS update!
         fig = obj.Hloc.pref;
         obj.Hloc = rmfield(obj.Hloc,{'pref','lbl'});
         setappdata(obj.Parent,'uihandles',obj.Hloc);
         
         delete(fig); %Destroy graphic handle object: figure
         obj.delete(); %Destroy this object
      end
      %Destructor
      function delete(obj)
      end
   end
end