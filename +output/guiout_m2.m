%Controls the output on the GUI
%wahrscheinlich besser: hier signal updaten und plotten, nicht noch zusätzliches update in der generatorklasse!
classdef guiout_m2 < output.guiout
   properties (SetAccess = public, GetAccess = public)
      ListeningTo
      Monitor2
      PlotScaleX
   end
   methods
      %Constructor:
      function obj = guiout_m2(hmain,src1)
         %As superclass constructor requires argument, call explicitly:
         obj = obj@output.guiout(hmain);
         
         PREFSloc = getappdata(hmain,'preferences');
         APPDATloc = getappdata(hmain,'appdata');
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         steps = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry2;
         
         obj.ListeningTo = src1;
         obj.PlotScaleX = linspace(0,steps,PREFSloc.samplerate*dur*steps); %//XLim 100000?
         
         %Invoke axes objects:
         Hloc = getappdata(hmain,'uihandles');
         strdisp = cdat.uistr(hmain,obj,'disp');
         Hloc.(strdisp) = axes('Units','Pixels','Position',[25,210,450,100],'Parent',hmain,'YLim',[-2,2]); %Do not specify XLim values as this property will be automatically affected by plot (linspace array), but not YLim, so set explicitly on every demand; XLim determines min & max values, so value equal to sample rate would interfere with plot propertes (0 to 1).
         setappdata(hmain,'uihandles',Hloc);
         
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
         APPDATloc = getappdata(hmain,'appdata');
         PREFSloc = getappdata(hmain,'preferences');
         Hloc = getappdata(hmain,'uihandles');
         
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         steps = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry2;
         %subdiv = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry3;
         %stepdur = dur/subdiv;
         
         obj.PlotScaleX = linspace(0,steps,PREFSloc.samplerate*dur*steps);
         
         %Plot signal design:
         %fn = fieldnames(obj.ListeningTo.Signal);
         
         %Reconvert signalstruct to array:
         %for i=1:length(fn)
         %   NSIG((i-1)*stepdur*PREFSloc.samplerate+1:i*stepdur*PREFSloc.samplerate) = obj.ListeningTo.Signal.(fn{i});
         %end
         
         %Plot signal design:
         set(obj.Parent,'CurrentAxes',Hloc.([cdat.classname(obj),'_','disp1']));
         hplot = plot(obj.PlotScaleX,obj.ListeningTo.Signal,'Parent',gca);
         set(gca,'YLim',[-2,2]);
         clear APPDATloc Hloc;
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