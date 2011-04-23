%Class loads the user specified program design to 1401 on GUI request
classdef setup5 < setup.load1401
   properties
      Parent
      SignalObj
      FileObj
   end
   methods
      %Constructor:
      function obj = setup5(hmain,src1)
         obj.Parent = hmain;
         PREFS = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc = getappdata(obj.Parent,'uihandles');
         Hloc.push = uicontrol('Style','Pushbutton','String','RUN','Position',[245,25,100,115],'Callback',@(src,evt)RunSetup(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         Hloc.pop = uicontrol('Style','popup','String','Left APB: 1|Left FDI: 1|Left ADM: 1|Right APB: 1|Right FDI: 1|Right ADM: 1','Position',[160,220,80,20],'Callback',@(src,evt)CalcPopup(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         Hloc.text = uicontrol('Style','text','String','Specify search path for data file:','Position',[350,55,180,15],'HorizontalAlignment','left','BackgroundColor',[.8,.8,.8],'Callback',@(src,evt)RunSetup(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         obj.FileObj = cfile(hmain);
         
         MATCED32('cedLdX',PREFS.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
      end
      function CalcPopup(obj,src,evt)
         H = getappdata(obj.Parent,'uihandles');
         
         ppstr = get(H.pop,'string');
         ppval = get(H.pop,'value');
         
         ppsel = ppstr{ppval};
         
         query = inputdlg(ppstr(ppval),'Change weighting',1,{'1'});
         
         ppsel = ppsel(1:(strfind(ppsel,': ') + 1));
         
         PPSTR(PPVAL) = {[CURR char(TOPP)]};
         
         set(handles.popupmenu2,'str',PPSTR);
      end
      function r = GenCueSq(obj,isi)
         APPDAT = getappdata(obj.Parent,'appdata');
         taps = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry4;
         
         sq = randi(isi,taps);
         sq = sq(1,:);
         r = sq;
      end
      function RunSetup(obj,src,evt)
         %//..
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.push);
         delete(Hloc.pop);
         delete(Hloc.text);
         Hloc = rmfield(Hloc,{'push','text','pop'});
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end