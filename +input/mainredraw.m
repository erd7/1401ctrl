%Class erzeugt eine Buttongroup aus zwei Radiobuttons; zu implementieren: dynamische Anpassung der Buttonzahl
%ALT: KONZEPT: Klasse als allg REDRAW klasse (selbst superklasse, untergeordnete implementierungsklassen erstellen!)- beerbt maininput
%+Subklasse: Konkrete implementierung erst in der Refreshfunktion in Subklasse!
%Neues Konzept: cmode-subklasse!
classdef mainredraw < hgsetget
   properties
      Parent
      RadioState = 1;
      InputState = 1;
      InputObj = 0;
   end
   events
      Redraw
   end
   methods
      %Constructor: //Use position: [0.8,0.85,0.16,0.1] (testing)
      function obj = mainredraw(hmain,pos,lbl1,lbl2)
         obj.Parent = hmain;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc = getappdata(obj.Parent,'uihandles');
         obj.ContainerPosition = pos;
         obj.ButtonString1 = lbl1;
         obj.ButtonString2 = lbl2;
         
         Hloc.radiogrp = uibuttongroup('Units','pixels','Position',obj.ContainerPosition,'BackgroundColor',[0.8,0.8,0.8],'SelectionChangeFcn',@(src,evt)RadioCheck(obj,src,evt));
         Hloc.radio1 = uicontrol('Style','Radio','String',lbl1,'pos',[10,8,70,15],'BackgroundColor',[0.8,0.8,0.8],'parent',Hloc.radiogrp,'Selected','on','SelectionHighlight','off'); %default selection
         Hloc.radio2 = uicontrol('Style','Radio','String',lbl2,'pos',[80,8,50,15],'BackgroundColor',[0.8,0.8,0.8],'parent',Hloc.radiogrp,'Selected','off');
         setappdata(hmain,'uihandles',Hloc);
         
         evt.NewValue = Hloc.radio1;
         fh = @(src,evt)RadioCheck(obj,src,evt);
         fh(Hloc.radiogrp,evt);
      end
      %Internal callback:
      %RadioState redundant?
      %Selection switches are performed automatically by the button group!
      function RadioCheck(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         if evt.NewValue == Hloc.radio2
            obj.RadioState = 2;
            obj.redraw(obj.RadioState);
         elseif evt.NewValue == Hloc.radio1
            obj.RadioState = 1;
            obj.redraw(obj.RadioState);
         end
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.radio1);
         delete(Hloc.radio2);
         delete(Hloc.radiogrp);
         Hloc = rmfield(Hloc,'radiogrp');
         Hloc = rmfield(Hloc,'radio1');
         Hloc = rmfield(Hloc,'radio2');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
   methods (Abstract)
      redraw(obj,mod)
   end
end