%Class builds session settings-GUI; object is being destroyed explicitly on close request (sess data management through global struct)
classdef sessgui < handle
   properties
      Parent
      Interface
   end
   methods
      %Constructor: //Initialize session settings GUI & load default values
      function obj = sessgui(hmain)
         obj.Parent = hmain;
         Hloc = getappdata(obj.Parent,'uihandles');
         
         %Invoke GUI:
         Hloc.sess = figure('Visible','off','Position',[0,0,400,400],'MenuBar','none','Resize','off','Name','Session Settings','CloseRequestFcn',@(src,evt)CloseReq(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %Build local GUI elements: //here new concrete class prefinput!
         SESSINPUT = input.sessinput(hmain);
         obj.Interface = SESSINPUT;
         
         movegui(Hloc.sess,'center');
         set(Hloc.sess,'Visible','on');
      end
      %Internal close request callback:
      function CloseReq(obj,src,evt)
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
         delete(Hloc.sess);
         Hloc = rmfield(Hloc,{'sess'});
         setappdata(obj.Parent,'uihandles',Hloc);

         obj.delete(); %Destroy this object
      end
      %Destructor
      function delete(obj)
      end
   end
end