%Interface class for collection and storage of user input data
classdef userinput < handle
   properties
      UserInput
   end
   events
      NewInputAlert
   end
   methods (Abstract)
      UpdateInput(obj,src,evt)
   end
end