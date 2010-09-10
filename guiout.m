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
      function obj = guiout(src1,src2,fig,out2)
         obj.ListeningTo = src1;
         obj.ComObj = src2;
         obj.ParentFigure = fig;
         obj.Monitor2 = out2;
         
         %prüfe: src hier direkt nutzen?
         addlistener(obj.ListeningTo,'NewInputAlert',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo,obj.ParentFigure,obj.Monitor2));
         %addlistener(obj.ListeningTo,'ToggleOn',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         %addlistener(obj.ListeningTo,'ToggleOff',@(src,evt)UpdateOutput(obj,src,evt,obj.ListeningTo));
         
         %src.UpdateInput(...
         
         %Plot signal design:
         set(fig,'CurrentAxes',out2);
         %obj.ComObj.GenSin(src1.Entry1,src1.Entry2,src1.Entry3); %Don't call; signal has previously been generated during invocation of gen_signal object!
         plothandle = plot(obj.PlotScaleX,obj.ComObj.Signal,'Parent',gca);
         set(gca,'YLim',[-5,5]);
      end
   end
   methods
      function UpdateOutput(obj,src,evt,srcobj,fig,out2)
         %Plot signal design:
         set(fig,'CurrentAxes',out2);         
         obj.ComObj.GenSin(srcobj.Entry1,srcobj.Entry2,srcobj.Entry3);
         plothandle = plot(obj.PlotScaleX,obj.ComObj.Signal,'Parent',gca);
         set(gca,'YLim',[-5,5]);
      end
   end
end