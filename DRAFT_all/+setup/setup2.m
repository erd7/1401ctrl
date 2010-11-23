%Class loads the user specified program design to 1401 on GUI request
classdef setup2 < setup.load1401
   properties
      Parent
      SignalObj
   end
   methods
      %Constructor:
      function obj = setup2(hmain,src1)
         obj.Parent = hmain;
         Hloc = getappdata(obj.Parent,'uihandles');
         PREFSloc = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc.push1 = uicontrol('Style','Pushbutton','String','LOAD 1401','Position',[200,55,100,25],'Callback',@(src,evt)Load1401(obj,src,evt));
         
         setappdata(obj.Parent,'uihandles',Hloc);
         
         MATCED32('cedLdX',PREFSloc.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
      end
      function Load1401(obj,src,evt)
         APPDATloc = getappdata(obj.Parent,'appdata');
         Hloc = getappdata(obj.Parent,'uihandles');
         
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         sz = 2*obj.SignalObj.DataLength*dur;
         chunksz = obj.SignalObj.DataLength*dur/10; %//MAKE DEPENDENT ON MAX PACKAGE SIZE!
         MATCED32('cedSendString','CLEAR;');
                                            
         %Since whole transfer of RN is impossible (only 2byte data!), split into 10 chunks:
         for i=1:10
            dacOut = obj.DacScale * obj.SignalObj.Signal((i-1)*chunksz+1:i*chunksz); %//MAKE DEPEND ON SAMPLE RATE!
            MATCED32('cedTo1401',chunksz,(i-1)*2*chunksz,dacOut);
         end
                  
         %Initial values for control vars:
         MATCED32('cedSendString','VAR,S,Z,0;');
         MATCED32('cedSendString','VAR,S,A,1;');
         
         %Load sampling cycle & trig sq program to 1401:
         MATCED32('cedSendString','RUNCMD,L;');
         %MATCED32('cedSendString',['VAR,S,Z,',int2str(sz),';']); %For waiting: Monitor currently sampled byte adress //Pointer- Alternative! //z.Z. Sq.-Alternative implementiert
         MATCED32('cedSendString',['MEMDAC,I,2,0,',int2str(sz),',0,1,H,125,25;']); %Sample rate is 1280
         MATCED32('cedSendString','MEMDAC,?:A;');
         %MATCED32('cedSendString','MEMDAC,P:?;'); %//NOTE: Works, but floads output buffer- checkout continously, if implemented!
         MATCED32('cedSendString','RUNCMD,BN,2,A,0;');
         %MATCED32('cedSendString','VAR,S,Z,1;');
         %//NULLSTROM HIER! (MEMDAC AN LEERER ADRESSE)
         %MATCED32('cedSendString',['MEMDAC,I,2,',num2str(2^16),',2,0,1,H,125,25;']); %Sample rate is 1280
         %MATCED32('cedSendString','RUNCMD,D;');
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