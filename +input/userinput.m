%Interface class for collection and storage of user input data
classdef userinput < hgsetget
   properties
      Parent
      UserInput
   end
   events
      NewInputAlert
   end
   methods
      %Constructor:
      function obj = userinput(hmain)
         obj.Parent = hmain;
         
         cdat.setobj(hmain,obj,'MODAL');
      end
      function deluiobj(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         fn = fieldnames(Hloc);
         
         %Destroy every uicontrol obj that is related to constructing instance specified:         
         for i=1:length(fn)
            if isempty(strfind(fn{i},cdat.classname(obj))) == 0
               delete(Hloc.(fn{i}));
               Hloc = rmfield(Hloc,fn{i});
            end
         end
         
         setappdata(obj.Parent,'uihandles',Hloc);
      end
      function redraw(obj,mod) %auch für Wiederverwendung vom Initialisierungsargument abhängig machen! %//Mache privat und nur für das eigene objekt!
         obj.deluiobj();
      end
      %Destructor:
      function delete(obj)
         obj.deluiobj();
      end
   end
   methods (Abstract)
      UpdateInput(obj,src,evt)
   end
end