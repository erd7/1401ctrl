%Class erzeugt eine Buttongroup aus zwei Radiobuttons; zu implementieren: dynamische Anpassung der Buttonzahl
classdef radiobuttongrp < handle
   properties
      RadioState1 = 1;
      RadioState2 = 0;
      ContainerHandle
      RadioHandle1
      RadioHandle2
      ContainerPosition
      ButtonString1
      ButtonString2
   end
   events
      SelRadio1
      SelRadio2
   end
   methods
      %Constructor: //Use position: [0.8,0.85,0.16,0.1] (testing)
      function obj = radiobuttongrp(h,pos,lbl1,lbl2)
         Hloc = getappdata(h.main,'uihandles');
         obj.ContainerPosition = pos;
         obj.ButtonString1 = lbl1;
         obj.ButtonString2 = lbl2;
         Hloc.radiogrp = uibuttongroup('Position',obj.ContainerPosition,'BackgroundColor',[0.8,0.8,0.8],'SelectionChangeFcn',@(src,evt)RadioCheck(obj,src,evt));
         obj.ContainerHandle = Hloc.radiogrp;
         Hloc.radio1 = uicontrol('Style','Radio','String',lbl1,'pos',[10,8,40,15],'BackgroundColor',[0.8,0.8,0.8],'parent',obj.ContainerHandle,'Selected','on','SelectionHighlight','off'); %default selection
         obj.RadioHandle1 = Hloc.radio1;
         Hloc.radio2 = uicontrol('Style','Radio','String',lbl2,'pos',[50,8,40,15],'BackgroundColor',[0.8,0.8,0.8],'parent',obj.ContainerHandle,'Selected','off');
         obj.RadioHandle2 = Hloc.radio2;
         setappdata(h.main,'uihandles',Hloc);
         
         %Following block probably reducible:         
         if get(obj.RadioHandle1,'Value') == get(obj.RadioHandle1,'Max') && get(obj.RadioHandle2,'Value') == get(obj.RadioHandle2,'Min')
            obj.RadioState1 = 1;
            obj.RadioState2 = 0;
            notify(obj,'SelRadio1');
         elseif get(obj.RadioHandle1,'Value') == get(obj.RadioHandle1,'Min') && get(obj.RadioHandle2,'Value') == get(obj.RadioHandle2,'Max')
            obj.RadioState1 = 0;
            obj.RadioState2 = 1;
            notify(obj,'SelRadio2');
         end
      end
      %Internal callback & event notifier:
      %RadioStates redundant?
      %Selection switches are performed automatically by the button group!
      function RadioCheck(obj,src,evt)
         if evt.NewValue == obj.RadioHandle2
            obj.RadioState1 = 0;
            obj.RadioState2 = 1;
            notify(obj,'SelRadio2');
         elseif evt.NewValue == obj.RadioHandle1
            obj.RadioState1 = 1;
            obj.RadioState2 = 0;
            notify(obj,'SelRadio1');
         end
      end
   end
end