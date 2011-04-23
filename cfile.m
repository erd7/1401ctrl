classdef cfile < cdat
   %Subclass for file management   
   properties
      UIELEM = struct();
      DatDir = pwd();
   end   
   methods
      function obj = cfile(hmain)
         %As superclass constructor requires arguments, call explicitly:
         obj = obj@cdat(hmain);
         
         obj.Parent = hmain;
         strpush = obj.uistr(hmain,obj,'push');
         stredit = obj.uistr(hmain,obj,'edit');
         obj.UIELEM.stredit = stredit;
         obj.UIELEM.strpush = strpush;
         
         H = getappdata(obj.Parent,'uihandles');
         H.(stredit) = uicontrol('Style','edit','String',obj.DatDir,'Position',[350,25,125,25],'BackgroundColor',[1,1,1],'HorizontalAlignment','left','Callback',@(src,evt)setfilepath(obj,src,evt));
         setappdata(obj.Parent,'uihandles',H);
         obj.UIELEM.hedit = H.(stredit);
         
         H = getappdata(obj.Parent,'uihandles');
         H.(strpush) = uicontrol('Style','Pushbutton','String','Browse','Position',[475,25,50,25],'Callback',@(src,evt)browsepath(obj,src,evt));
         setappdata(obj.Parent,'uihandles',H);
         obj.UIELEM.hpush = H.(strpush);
         
         obj.setfilepath();
      end
      function r = setfilepath(obj,src,evt)
         try
            strpath = get(obj.UIELEM.hedit,'String');
            
            if strcmp(strpath(end),'\') ~=1 && strcmp(strpath(end),'/') ~=1
               strpath = [strpath,'\'];
            end
            
            obj.DatDir = strpath;
            cd(obj.DatDir);
            
            r = 1;
         catch
            waitfor(errordlg('Specified directory does not exist!'));
            set(obj.UIELEM.hedit,'String',pwd());
            r = -1;
         end
      end
      function browsepath(obj,src,evt)
         strdir = uigetdir(pwd(),'Select data directory.'); %Also check UIPUTFILE
         
         set(obj.UIELEM.hedit,'String',strdir);
         obj.setfilepath();
      end
      function delete(obj)
         delete(obj.UIELEM.hedit);
         delete(obj.UIELEM.hpush);
         H = getappdata(obj.Parent,'uihandles');
         H = rmfield(H,{obj.UIELEM.stredit,obj.UIELEM.strpush});
         setappdata(obj.Parent,'uihandles',H);
      end
   end
end
