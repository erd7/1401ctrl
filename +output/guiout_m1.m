%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zusätzliches update in der generatorklasse!
classdef guiout_m1 < output.guiout
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Monitor2
      %PlotScaleX
      PlotScaleX = linspace(0,1,40000);
   end
   methods
      %Constructor:
      function obj = guiout_m1(hmain,src1)
         %As superclass constructor requires argument, call explicitly:
         obj = obj@output.guiout(hmain);
         
         obj.ListeningTo = src1;
         
         Hloc = getappdata(hmain,'uihandles');
         strdisp = cdat.uistr(hmain,obj,'disp');
         Hloc.(strdisp) = axes('Units','Pixels','Position',[25,210,450,100],'Parent',hmain,'YLim',[-5,5]); %Do not specify XLim values as this property will be automatically affected by plot (linspace array), but not YLim, so set explicitly on every demand; XLim determines min & max values, so value equal to sample rate would interfere with plot propertes (0 to 1).
         setappdata(hmain,'uihandles',Hloc);
         
         %title(Hloc.disp2,'SignalDesign'); ylabel(gca,'Test'); xlabel(gca,'Test'); //Why doesn't work?
         Hloc = getappdata(hmain,'uihandles');
         strlbl = cdat.uistr(hmain,obj,'lbl');
         Hloc.(strlbl) = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
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
         Hloc = getappdata(hmain,'uihandles');
         PREFSloc = getappdata(hmain,'preferences');
         
         obj.PlotScaleX = linspace(0,1,PREFSloc.samplerate);
         
         %Plot signal design:
         set(obj.Parent,'CurrentAxes',Hloc.([cdat.classname(obj),'_','disp1']));
         hplot = plot(obj.PlotScaleX,obj.ListeningTo.Signal,'Parent',gca);
         set(gca,'YLim',[-5,5]);
         clear Hloc;
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.([cdat.classname(obj),'_','disp1']));
         delete(Hloc.([cdat.classname(obj),'_','lbl1']));
         Hloc = rmfield(Hloc,{[cdat.classname(obj),'_','disp1'],[cdat.classname(obj),'_','lbl1']});
         setappdata(obj.Parent,'uihandles',Hloc);
         clear Hloc;
      end
   end
end