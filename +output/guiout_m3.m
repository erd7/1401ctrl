%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zusätzliches update in der generatorklasse!
classdef guiout_m3 < output.guiout
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Monitor2
      PlotScaleX
   end
   methods
      %Constructor:
      function obj = guiout_m3(hmain,src1)
         obj = obj@output.guiout(hmain);
         
         APPDATloc = getappdata(hmain,'appdata');
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         obj.PlotScaleX = linspace(0,1,dur*1280);
         
         
         obj.ListeningTo = src1;
         
         Hloc = getappdata(hmain,'uihandles');
         
         cdat.setobj(hmain,obj,'MODAL');
         
         %Invoke axes objects:
         %Hloc.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',hmain,'XLim',[0,40000],'YLim',[-5,5]);
         Hloc.disp2 = axes('Units','Pixels','Position',[25,210,450,100],'Parent',hmain,'XLim',[0,230400],'YLim',[-2,2]);
         %title(Hloc.disp2,'SignalDesign'); ylabel(gca,'Test'); xlabel(gca,'Test'); //Why doesn't work?
         %Hloc.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbl4 = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(hmain,'uihandles',Hloc);
         
         %prüfe: src hier direkt nutzen?
         addlistener(obj.ListeningTo,'NewCalcAlert',@(src,evt)UpdateOutput(obj,src,evt,hmain));
         %addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         
         %Plot signal design:
         obj.UpdateOutput(1,1,hmain);
         clear Hloc;
      end
   end
   methods
      function UpdateOutput(obj,src,evt,hmain)
         APPDATloc = getappdata(hmain,'appdata');
         Hloc = getappdata(hmain,'uihandles');
         
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         obj.PlotScaleX = linspace(0,dur,dur*1280);
         
         %Plot signal design:
         set(Hloc.main,'CurrentAxes',Hloc.disp2);         
         hplot = plot(obj.PlotScaleX,obj.ListeningTo.Signal,'Parent',gca);
         set(gca,'YLim',[-2,2]);
         clear APPDATloc Hloc;
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.disp2);
         delete(Hloc.lbl4);
         Hloc = rmfield(Hloc,{'disp2','lbl4'});
         setappdata(obj.Parent,'uihandles',Hloc);
         clear Hloc;
      end
   end
end