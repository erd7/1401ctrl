%Superclass for 1401 control; common routines
classdef access1401 < handle
   properties (SetAccess = public, GetAccess = public)
      Parent
      SIGNALOBJ
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = access1401(hmain,src)
         obj.Parent = hmain;
         obj.SIGNALOBJ = src;
                 
         cdat.setobj(hmain,obj,'MODAL');         
      end
      %Destructor:
      function load1401(obj)
         %// signal zu setup_1 zusammensetzen, wenn methode funktioniert!
         PREFS = getappdata(obj.Parent,'appdata');
         
         sig = obj.SIGNALOBJ.Signal;
         
         if length(sig) > 2^16 %//CHECK: Cut-off should be below to avoid loss of data
            %Split signal into chunks: block transfer (U14ToHost,U14To1401) sets transfer area 0 locking the memory; max. transfer area is 1Mb, but max. block transfer is 64kb (16bit = 2b data)
            
            %//FIRST DRAFT; VERIFY!
            chunks = floor(length(sig)/2^16);
            rem = length(sig)-chunks*2^16;
            
            for i=1:chunks
               dacOut = obj.DacScale * sig((i-1)*2^16+1:i*2^16); %Conversion of input params into DAC-units
               MATCED32('cedTo1401',2^16,(i-1)*2*2^16,dacOut);
            end
            
            dacOut = obj.DacScale * sig(chunks*2^16+1:chunks*2^16+rem); %//OR TILL END?
            MATCED32('cedTo1401',2^16,chunks*2*2^16,dacOut);
         else
            dacOut = obj.DacScale * sig;
            MATCED32('cedTo1401',PREFSloc.samplerate,0,dacOut); %Load the data to 1401 buffer (check max. RAM load); to generate complex signals change digits of dacOut- Array! for realtime manipulation invent more dynamic memory management paradigm
         end
      end
      function delete(obj)
         %//deluiobj() currently method of userinput class; make cdat?!
         %obj.deluiobj();
      end
   end
end