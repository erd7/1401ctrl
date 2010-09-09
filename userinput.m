%Class collects and stores user input data
classdef userinput < handle
   properties
      Entry1
      Entry2
      Entry3
   end
   events
      NewInputAlert
   end
   methods
      %Constructor
      function obj = userinput(inpobj1,inpobj2,inpobj3)
         obj.Entry1 = str2double(get(inpobj1,'String'));
         obj.Entry2 = str2double(get(inpobj2,'String'));
         obj.Entry3 = str2double(get(inpobj3,'String'));
         
         notify(obj,'NewInputAlert');
      end
      %Update method is called via intermediate uicontrol callback (direct call impossible)
      function UpdateInput(obj,inpobj1,inpobj2,inpobj3)
         obj.Entry1 = str2double(get(inpobj1,'String'));
         obj.Entry2 = str2double(get(inpobj2,'String'));
         obj.Entry3 = str2double(get(inpobj3,'String'));
         
         notify(obj,'NewInputAlert');
      end
   end
end