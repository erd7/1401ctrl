%Class loads the user specified program design to 1401 on GUI request
classdef cload1401_re < handle
   properties
      Parent
      SignalObj
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = cload1401_re(h,src1)
         obj.Parent = h.main;
         Hloc = getappdata(obj.Parent,'uihandles');
         PREFSloc = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         cdat.setobj(h,obj,'MODAL');
         
         Hloc.push1 = uicontrol('Style','Pushbutton','String','LOAD 1401','Position',[200,55,100,25],'Callback',@(src,evt)Load1401(obj,src,evt));
         
         setappdata(obj.Parent,'uihandles',Hloc);
         
         MATCED32('cedLdX',PREFSloc.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
      end
      function Load1401(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         sz = 2*obj.SignalObj.DataLength*180;
         chunksz = obj.SignalObj.DataLength*18;
         MATCED32('cedSendString','CLEAR;');
                                            
         %Since whole transfer of RN is impossible (only 2byte data!), split into 10 chunks:
         for i=1:10
            dacOut = obj.DacScale * obj.SignalObj.Signal((i-1)*23040+1):(i*23040); %//MAKE DEPEND ON SAMPLE RATE!
            MATCED32('cedTo1401',chunksz,(i-1)*2*23040,dacOut);
         end
                  
         %Initial values for control vars:
         MATCED32('cedSendString','VAR,S,Z,0;');
         MATCED32('cedSendString','VAR,S,A,1;');
         
         %Load sampling cycle & trig sq program to 1401:
         MATCED32('cedSendString','RUNCMD,L;');
         MATCED32('cedSendString',['VAR,S,Z,',int2str(sz),';']); %For waiting: Monitor currently sampled byte adress //Pointer- Alternative! //z.Z. Sq.-Alternative implementiert
         MATCED32('cedSendString',['MEMDAC,I,2,0,',int2str(sz),',0,1,H,125,25;']);
         MATCED32('cedSendString','MEMDAC,?:A;');
         MATCED32('cedSendString','MEMDAC,P:?;');
         MATCED32('cedSendString','RUNCMD,BN,3,A,0;');
         MATCED32('cedSendString','VAR,S,Z,1;');
         %//NULLSTROM HIER! (MEMDAC AN LEERER ADRESSE)
         MATCED32('cedSendString','RUNCMD,D;');
         MATCED32('cedSendString','END;');
         
         set(Hloc.toggle,'Enable','on');
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.push1);
         Hloc = rmfield(Hloc,'push1');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end