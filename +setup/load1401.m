%Class loads the user specified program design to 1401 on GUI request
classdef load1401 < handle
   properties
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods (Abstract)
      Load1401(obj,src,evt)
   end
end