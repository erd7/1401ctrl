%Interface class for collection and storage of user input data
classdef guiout < hgsetget
   properties
   end
   events
   end
   methods (Abstract)
      UpdateOutput(obj,src,evt,h)
   end
end