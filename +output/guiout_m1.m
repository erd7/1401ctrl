%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zus�tzliches update in der generatorklasse!
classdef guiout_m1 < output.guiout
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Monitor2
      PlotScaleX = linspace(0,1,40000);
   end
   methods
      %Constructor:
      function obj = guiout_m1(hmain,src1)
         obj = obj@output.guiout(hmain);
         
         obj.ListeningTo = src1;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         %Invoke axes objects:
         %Hloc.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',hmain,'XLim',[0,40000],'YLim',[-5,5]);
         Hloc = getappdata(hmain,'uihandles');
         
         strdisp = cdat.uistr(hmain,obj,'disp');
         Hloc.(strdisp) = axes('Units','Pixels','Position',[25,210,450,100],'Parent',hmain,'XLim',[0,40000],'YLim',[-5,5]);
         setappdata(hmain,'uihandles',Hloc);
         
         %title(Hloc.disp2,'SignalDesign'); ylabel(gca,'Test'); xlabel(gca,'Test'); //Why doesn't work?
         %Hloc.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         strlbl = cdat.uistr(hmain,obj,'disp');
         Hloc.(strlbl) = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(hmain,'uihandles',Hloc);
         
         %pr�fe: src hier direkt nutzen?
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