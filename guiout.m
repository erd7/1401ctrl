%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zusätzliches update in der generatorklasse!
classdef guiout < handle
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Parent
      Monitor2
      PlotScaleX = linspace(0,1,40000);
   end
   methods
      %Constructor:
      function obj = guiout(src1,h)
         Hloc = getappdata(h.main,'uihandles');
         obj.ListeningTo = src1;
         obj.Parent = h.main;
         
         %Invoke axes objects:
         %Hloc.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',h.main,'XLim',[0,40000],'YLim',[-5,5]);
         Hloc.disp2 = axes('Units','Pixels','Position',[25,210,450,100],'Parent',h.main,'XLim',[0,40000],'YLim',[-5,5]);
         %title(Hloc.disp2,'SignalDesign'); ylabel(gca,'Test'); xlabel(gca,'Test'); //Why doesn't work?
         %Hloc.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbl4 = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(h.main,'uihandles',Hloc);
         
         %prüfe: src hier direkt nutzen?
         addlistener(obj.ListeningTo,'NewCalcAlert',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo,obj.Parent,obj.Monitor2));
         %addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         
         %Plot signal design:
         set(h.main,'CurrentAxes',Hloc.disp2);
         plothandle = plot(obj.PlotScaleX,obj.ListeningTo.Signal,'Parent',gca);
         set(gca,'YLim',[-5,5]);
      end
   end
   methods
      function UpdateOutput(obj,src,evt,srcobj,fig,out2)
         %Plot signal design:
         set(fig,'CurrentAxes',out2);         
         plothandle = plot(obj.PlotScaleX,obj.ListeningTo.Signal,'Parent',gca);
         set(gca,'YLim',[-5,5]);
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.disp2);
         delete(Hloc.lbl4);
         Hloc = rmfield(Hloc,{'disp2','lbl4'});
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end