classdef togglebutton < handle
   properties
      ToggleState = 0;
      ButtonHandle
      ButtonPosition
      ButtonString
   end
   events
      ToggleOn
      ToggleOff
   end
   methods
      %Constructor: //Use position: [225,15,50,25]
      function obj = togglebutton(fig,pos,lbl)
         Hloc = getappdata(fig,'uihandles');
         obj.ButtonPosition = pos;
         obj.ButtonString = lbl;
         Hloc.toggle = uicontrol('Style','togglebutton','String',obj.ButtonString,'Position',obj.ButtonPosition,'Callback',@(src,evt)ToggleCheck(obj,src,evt));
         obj.ButtonHandle = Hloc.toggle;
         setappdata(fig,'uihandles',Hloc);
         
         %Following lines of this fct probably redundant
         if get(obj.ButtonHandle,'Value') == get(obj.ButtonHandle,'Max')
            obj.ToggleState = 1;
         elseif get(obj.ButtonHandle,'Value') == get(obj.ButtonHandle,'Min')
            obj.ToggleState = 0;
         end
      end
      %Internal callback & event notifier:
      function ToggleCheck(obj,src,evt)
         if (get(obj.ButtonHandle,'Value') ~= obj.ToggleState) && (get(obj.ButtonHandle,'Value') == get(obj.ButtonHandle,'Max'))
            obj.ToggleState = 1;
            notify(obj,'ToggleOn');
         elseif (get(obj.ButtonHandle,'Value') ~= obj.ToggleState) && (get(obj.ButtonHandle,'Value') == get(obj.ButtonHandle,'Min'))
            obj.ToggleState = 0;
            notify(obj,'ToggleOff')
         end
      end
   end
end
         