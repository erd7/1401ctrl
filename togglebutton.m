classdef togglebutton < handle
   properties
      ToggleState = 0;
      ButtonHandle
      ButtonPosition
      ButtonString
      Parent
   end
   events
      ToggleOn
      ToggleOff
   end
   methods
      %Constructor:
      function obj = togglebutton(h,pos,lbl,stat)
         obj.Parent = h.main;
         Hloc = getappdata(h.main,'uihandles');
         obj.ButtonPosition = pos;
         obj.ButtonString = lbl;
         Hloc.toggle = uicontrol('Style','togglebutton','String',obj.ButtonString,'Position',obj.ButtonPosition,'Enable','off','Callback',@(src,evt)ToggleCheck(obj,src,evt));
         obj.ButtonHandle = Hloc.toggle;
         setappdata(h.main,'uihandles',Hloc);
         
         if stat == 1
            set(Hloc.toggle,'Enable','on');
         end
         
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
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.toggle);
         Hloc = rmfield(Hloc,'toggle');
         setappdata(obj.Parent,'uihandles',Hloc);
      end         
   end
end
         