%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zusätzliches update in der generatorklasse!
classdef guiout_m2 < output.guiout
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Parent
      Monitor2
      PlotScaleX
   end
   methods
      %Constructor:
      function obj = guiout_m2(h,src1)
         obj.ListeningTo = src1;
         obj.Parent = h.main;
         obj.PlotScaleX = linspace(0,100000,obj.ListeningTo.DataLength*60);
         
         Hloc = getappdata(h.main,'uihandles');
         
         cdat.setobj(h,obj,'MODAL');
         
         %Invoke axes objects:
         %Hloc.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',h.main,'XLim',[0,40000],'YLim',[-5,5]);
         Hloc.disp2 = axes('Units','Pixels','Position',[25,210,450,100],'Parent',h.main,'XLim',[0,40000],'YLim',[-5,5]);
         %title(Hloc.disp2,'SignalDesign'); ylabel(gca,'Test'); xlabel(gca,'Test'); //Why doesn't work?
         %Hloc.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbl4 = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(h.main,'uihandles',Hloc);
         
         %prüfe: src hier direkt nutzen?
         addlistener(obj.ListeningTo,'NewCalcAlert',@(src,evt)UpdateOutput(obj,src,evt,h));
         %addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         
         %Plot signal design:
         obj.UpdateOutput(1,1,Hloc);
         clear Hloc;
      end
   end
   methods
      function UpdateOutput(obj,src,evt,h)
         Hloc = getappdata(h.main,'uihandles');
         
         %Plot signal design:
         fn = fieldnames(obj.ListeningTo.Signal);
         
         %Reconvert signalstruct to array:
         for i=1:length(fn)
            NSIG((i-1)*10000+1:i*10000) = obj.ListeningTo.Signal.(fn{i});
         end
         
         set(Hloc.main,'CurrentAxes',Hloc.disp2);       
         hplot = plot(obj.PlotScaleX,NSIG,'Parent',gca);
         set(gca,'YLim',[-2,2]);
         clear Hloc;
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