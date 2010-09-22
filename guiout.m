%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zusätzliches update in der generatorklasse!
classdef guiout < handle
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      ComObj
      ParentFigure
      Monitor2
      PlotScaleX = linspace(0,1,40000);
   end
   methods
      %Constructor:
      function obj = guiout(src1,fig,out2)
         obj.ListeningTo = src1;
         obj.ParentFigure = fig;
         obj.Monitor2 = out2;
         
         %prüfe: src hier direkt nutzen?
         addlistener(obj.ListeningTo,'NewCalcAlert',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo,obj.ParentFigure,obj.Monitor2));
         %addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         
         %Plot signal design:
         set(fig,'CurrentAxes',out2);
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
   end
end