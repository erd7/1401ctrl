%Interface class for collection and storage of user input data
classdef guiout < hgsetget
   properties
      Parent
   end
   events
   end
   methods
      function obj = guiout(hmain)
         obj.Parent = hmain;
         
         cdat.setobj(hmain,obj,'MODAL');
      end
   end
   methods (Abstract)
      UpdateOutput(obj,src,evt,h)
   end
end