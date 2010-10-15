%Class loads the user specified program design to 1401 on GUI request
classdef cload1401 < handle
   properties
      Parent
      SignalObj
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   methods
      %Constructor:
      function obj = cload1401(h,src1)
         obj.Parent = h.main;
         Hloc = getappdata(obj.Parent,'uihandles');
         PREFSloc = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         APPDATloc = getappdata(obj.Parent,'appdata');
         if length(fieldnames(APPDATloc.CURRENTOBJ)) > 0
            fn = fieldnames(APPDATloc.CURRENTOBJ);
         else
            fn = {};
         end
         objstr = ['obj',num2str(length(fn)+1)];
         APPDATloc.CURRENTOBJ.(objstr) = obj;
         setappdata(obj.Parent,'appdata',APPDATloc);
         clear fn APPDATloc;
         
         Hloc.push1 = uicontrol('Style','Pushbutton','String','LOAD 1401','Position',[200,55,100,25],'Callback',@(src,evt)Load1401(obj,src,evt));
         
         setappdata(obj.Parent,'uihandles',Hloc);
         
         MATCED32('cedLdX',PREFSloc.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
         %MATCED32('cedSetTransfer',0,880000); %//Why too big?
      end
      function Load1401(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         MATCED32('cedSendString','CLEAR;');
         
         %Load RN chunk into 1401::
         %TODO: Define transfer RAM area- note 1MB restriction!
         %NOTE: Because sampling from 4byte data is not possible, DAC sequences have to be spit into chunks! //MAKE DEPEND ON SAMPLE RATE!
         fn = fieldnames(obj.SignalObj.Signal);
         sz = 2*obj.SignalObj.DataLength*60; %sz: number of BYTES to be sampled from; CHECK MEMDAC PARAMS UP FROM HERE! Array range has to be duplicated due to memory management with 2byte data! NOTE: ONLY SAMPLING FROM 2BYTE DATA IS POSSIBLE!
         %chunksz = obj.SignalObj.DataLength/10;
         runs = length(obj.SignalObj.TrigSq);
         trigint = obj.SignalObj.TrigSq(1);
                                   
         %Since whole transfer of 400kb RN seems to be impossible (only 2byte data!), split into 10 chunks:
         %//Try to transfer whole sq with decreased sample rate!
         %for j=1:10
         %   dacOut = obj.DacScale * obj.SignalObj.Signal.(fn{i})(((j-1)*40000+1):(j*40000));
         %   power1401shutdown;power1401startup; %//WHY IS THIS NECESSARY?
         %   MATCED32('cedTo1401',chunksz,(j-1)*2*40000,dacOut);
         %end
         
         for i=1:length(fn)
            dacOut = obj.DacScale * obj.SignalObj.Signal.(fn{i});
            MATCED32('cedTo1401',obj.SignalObj.DataLength,(i-1)*2*obj.SignalObj.DataLength,dacOut);
         end
                  
         %Load corresponding chunk of trig sq into 1401:
         %//LOAD WHOLE TRIG SQ!
         MATCED32('cedSendString',['DIGTIM,SI,',num2str(2^22),',',num2str(2*16*runs),';']);
         
         MATCED32('cedSendString',['DIGTIM,A,1,1,',num2str(trigint),';']);
         MATCED32('cedSendString','DIGTIM,A,1,0,2;');
         
         %trigint = obj.SignalObj.TrigSq(2*i)-obj.SignalObj.TrigSq(2*i-1)-2-((i-1)*10000);
         %trigint = obj.SignalObj.TrigSq(2*i)-2-((i-1)*10000);
         %MATCED32('cedSendString',['DIGTIM,A,1,1,',num2str(trigint),';']);
         %MATCED32('cedSendString','DIGTIM,A,1,0,2;');
         
         for i=1:(runs-1)
            trigint = obj.SignalObj.TrigSq(i+1)-obj.SignalObj.TrigSq(i)-2;
            MATCED32('cedSendString',['DIGTIM,A,1,1,',num2str(trigint),';']);
            MATCED32('cedSendString','DIGTIM,A,1,0,2;');
         end
         MATCED32('cedSendString','DIGTIM,OD;');
         
         %Initial values for control vars:
         MATCED32('cedSendString','VAR,S,Z,0;');
         MATCED32('cedSendString','VAR,S,A,1;');
         
         %Load sampling cycle & trig sq program to 1401:
         MATCED32('cedSendString','RUNCMD,L;');
         MATCED32('cedSendString',['VAR,S,Z,',int2str(sz),';']); %For waiting: Monitor currently sampled byte adress //Pointer- Alternative! //z.Z. Sq.-Alternative implementiert
         MATCED32('cedSendString','DIGTIM,C,10,100;'); %//implement clock rate to depend on frqsubdiv; or vice versa (everything dependent on dig sample rate!
         MATCED32('cedSendString',['MEMDAC,I,2,0,',int2str(sz),',0,1,H,400,10;']);
         MATCED32('cedSendString','MEMDAC,?:A;');
         MATCED32('cedSendString','MEMDAC,P:?;');
         MATCED32('cedSendString','RUNCMD,BN,4,A,0;');
         MATCED32('cedSendString','VAR,S,Z,1;');
         %for j=1:10
         %   MATCED32('cedSendString',['MEMDAC,I,2,',2*(j-1)*40000,',',sz,',0,1,H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
         %   MATCED32('cedSendString','MEMDAC,?;');
         %end
         MATCED32('cedSendString','DIGTIM,S;'); %For assurance...
         MATCED32('cedSendString','DIG,O,0,8;'); %For assurance...
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