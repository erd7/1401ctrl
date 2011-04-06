%Class loads the user specified program design to 1401 on GUI request
classdef setup3 < setup.load1401
   properties
      Parent
      SignalObj
   end
   methods
      %Constructor:
      function obj = setup3(hmain,src1)
         obj.Parent = hmain;
         Hloc = getappdata(obj.Parent,'uihandles');
         PREFSloc = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc.push1 = uicontrol('Style','Pushbutton','String','RUN SQ.','Position',[200,55,100,25],'Callback',@(src,evt)RunSetup(obj,src,evt));
         Hloc.lbls1 = uicontrol('Style','text','String','WAITING FOR SQ. START...','Position',[25,85,400,15],'HorizontalAlignment','left','BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbls2 = uicontrol('Style','text','String','...','Position',[25,105,150,35],'FontSize',20,'BackgroundColor',[1,0.5,0.5]);
         
         setappdata(obj.Parent,'uihandles',Hloc);
         
         MATCED32('cedLdX',PREFSloc.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
      end
      function RunSetup(obj,src,evt)
         APPDATloc = getappdata(obj.Parent,'appdata');
         PREFSloc = getappdata(obj.Parent,'preferences');
         Hloc = getappdata(obj.Parent,'uihandles');
         
         %//IMPLEMENT EVERYTHING IN MAININPUT CLASS?
         set(Hloc.edit1,'Enable','off');
         set(Hloc.edit2,'Enable','off');
         
         dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         sz = 2*PREFSloc.samplerate*dur;
         chunksz = PREFSloc.samplerate*dur/10; %//MAKE DEPENDENT ON MAX PACKAGE SIZE!
         cycles = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry2;
         zeroDC = zeros(1,128);
         twait = 30;
         tprobe = 100;
         
         sq = randperm(cycles);
         set(Hloc.lbls1,'String',['LVL order will be: ',num2str(sq)]);
    
         MATCED32('cedSendString','CLEAR;');
         
         for i=1:cycles
            set(Hloc.lbls2,'FontSize',12,'String','Loading 1401...');
            chk = -1;
            
            set(Hloc.lbls2,'String','...');
            obj.SignalObj.GenNoise(dur,sq(i));
            
            nsig = obj.SignalObj.Signal;
            nsig(end) = 0; %//Last DAC-value is zero!
         
            %Since whole transfer of RN is impossible (only 2byte data!), split into 10 chunks:
            for j=1:10
               dacOut = obj.DacScale * nsig((j-1)*chunksz+1:j*chunksz); %//MAKE DEPEND ON SAMPLE RATE!
               MATCED32('cedTo1401',chunksz,(j-1)*2*chunksz,dacOut);
            end
            
            %// Dummy zero current:
            %MATCED32('cedTo1401',length(zeroDC),sz,zeroDC); %//negative byte addresses?
                  
            %Initial values for control vars:
            MATCED32('cedSendString','VAR,S,Z,0;');
            MATCED32('cedSendString','VAR,S,A,1;');
         
            %Load sampling cycle & trig sq program to 1401:
            MATCED32('cedSendString','RUNCMD,L;');
            %MATCED32('cedSendString',['VAR,S,Z,',int2str(sz),';']); %For waiting: Monitor currently sampled byte adress //Pointer- Alternative! //z.Z. Sq.-Alternative implementiert
            MATCED32('cedSendString',['MEMDAC,I,2,0,',int2str(sz),',0,1,H,125,25;']); %Sample rate is 1280
            MATCED32('cedSendString','MEMDAC,?:A;');
            MATCED32('cedSendString','MEMDAC,?:?;');
            %MATCED32('cedSendString','MEMDAC,P:?;');
            MATCED32('cedSendString','RUNCMD,BN,2,A,0;');
            MATCED32('cedSendString','VAR,S,Z,1;');
            MATCED32('cedSendString','VAR,S,A,1;');
            %//NULLSTROM HIER!
            %MATCED32('cedSendString',['MEMDAC,I,2,',int2str(sz),',',2*int2str(length(zeroDC)),',0,1,H,125,25;']); %Sample rate is 1280
            %MATCED32('cedSendString','MEMDAC,?:A;');
            %MATCED32('cedSendString','MEMDAC,?:?;');
            %MATCED32('cedSendString','RUNCMD,BN,8,A,0;');
            MATCED32('cedSendString','RUNCMD,D;');
            MATCED32('cedSendString','END;');
         
            MATCED32('cedSendString','RUNCMD,G;');
            set(Hloc.lbls2,'FontSize',12,'String','Sampling...');
            
            %Wait for 1401 done:
            while chk ~= 0
               chk = str2double(MATCED32('cedGetString'));
               %display(chk);
            end
            
            set(Hloc.lbls2,'FontSize',12,'String','Counting from 30...');
            pause(twait);
            set(Hloc.lbls2,'FontSize',20,'String','GO!');
            pause(tprobe);
         end
         
         set(Hloc.lbls2,'String','ALL DONE!');
         set(Hloc.edit1,'Enable','on');
         set(Hloc.edit2,'Enable','on');
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.push1);
         delete(Hloc.lbls1);
         delete(Hloc.lbls2);
         Hloc = rmfield(Hloc,'push1');
         Hloc = rmfield(Hloc,'lbls1');
         Hloc = rmfield(Hloc,'lbls2');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end