%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zus�tzliches update in der generatorklasse!
classdef guiout_m3 < output.guiout
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Parent
      Monitor2
      PlotScaleX
   end
   methods
      %Constructor:
      function obj = guiout_m3(h,src1)
         APPDATloc = getappdata(h.main,'appdata');
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         obj.PlotScaleX = linspace(0,1,dur*1280);
         
         
         obj.ListeningTo = src1;
         obj.Parent = h.main;
         
         Hloc = getappdata(h.main,'uihandles');
         
         cdat.setobj(h,obj,'MODAL');
         
         %Invoke axes objects:
         %Hloc.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',h.main,'XLim',[0,40000],'YLim',[-5,5]);
         Hloc.disp2 = axes('Units','Pixels','Position',[25,210,450,100],'Parent',h.main,'XLim',[0,230400],'YLim',[-2,2]);
         %title(Hloc.disp2,'SignalDesign'); ylabel(gca,'Test'); xlabel(gca,'Test'); //Why doesn't work?
         %Hloc.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbl4 = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(h.main,'uihandles',Hloc);
         
         %pr�fe: src hier direkt nutzen?
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
         APPDATloc = getappdata(h.main,'appdata');
         Hloc = getappdata(h.main,'uihandles');
         
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