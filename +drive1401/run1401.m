%On event calls method for 1401 stimulation routine (data transfer & execution)
%HIER SOLLTEN EIGENTLICH NUR SETUPS DER VERSCHIEDENEN MODI AUSGEFÜHRT WERDEN! Wozu zwei Klassensysteme? --> Setups mit privaten elementen im setup laden; überdenke klassensysteme; manage setups in subklassen! Use RunSetup as common function holding script! Gedanke war, setups in gemeinsame ausführungsroutinen zu überführen, aber setups dennoch essentiell!
%--> IM SETUP NOCH KEINE SIGNALVERARBEITUNG?
classdef run1401 < drive1401.access1401
   properties (SetAccess = public, GetAccess = public)
      ToggleState = 0;
      ListeningTo
      Prefs
   end
   events
      ToggleOn
      ToggleOff
   end
   methods
      %Constructor:
      function obj = run1401(hmain,inidat,src)
         %As superclass constructor requires arguments, call explicitly:
         obj = obj@drive1401.access1401(hmain,src);
         
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         Hloc = getappdata(obj.Parent,'uihandles');
         Hloc.toggle = uicontrol('Style','togglebutton','String',inidat{2},'Position',inidat{1},'Enable','off','Callback',@(src,evt)ToggleCheck(obj,src,evt));
         setappdata(hmain,'uihandles',Hloc);
         
         if inidat{3} == 1
            set(Hloc.toggle,'Enable','on');
         end
         
         %Listening to own event; listening to ToggleOff is not necessary at all as stop condition (see below) is checked before every iteration correctly)
         addlistener(obj,'ToggleOn',@(src,evt)StimCtrl(obj,src,evt));
         
         %Following code is to be implemented at a more appropriate point:
         MATCED32('cedLdX',obj.Prefs.langpath,'MEMDAC'); %In Optionen von user entry abhängig machen?
      end
      %Internal callback & event notifier:
      function ToggleCheck(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         if (get(Hloc.toggle,'Value') ~= obj.ToggleState) && (get(Hloc.toggle,'Value') == get(Hloc.toggle,'Max'))
            obj.ToggleState = 1;
            notify(obj,'ToggleOn');
         elseif (get(Hloc.toggle,'Value') ~= obj.ToggleState) && (get(Hloc.toggle,'Value') == get(Hloc.toggle,'Min'))
            obj.ToggleState = 0;
            notify(obj,'ToggleOff')
         end
      end
      %Stimulation control and sampling routine:
      function StimCtrl(obj,src,evt)
         %//LOCK INPUT! --> OVERALL EVENT; COMBINE WITH LOCKING 1401 ACCESS VIA RUNCMD!
         
         PREFSloc = getappdata(obj.Parent,'preferences');
         APPDAT = getappdata(obj.Parent,'appdata');
         obj.Prefs = PREFSloc;
         
         MATCED32('cedSendString','CLEAR;');
         
         chk = -1; %some initial value ~= 0,1,2,-128
         sz = int2str(2*PREFSloc.samplerate); %sz: number of BYTES to be sampled from; note: 1401 splits two byte data into 2 subchunks, claiming twice as much memory space!
         swps = APPDAT.CURRENTOBJ.MODAL.mainredraw_1.UserInput.Entry4;
                  
         %Check if 1401 is ready and initiate data transfer:
         while chk ~= 0
            MATCED32('cedSendString','MEMDAC,?;');
            chk = str2double(MATCED32('cedGetString')); %Every query to 1401 causes load of string into output buffer stack, where the data has to be fetched from by host via getstring!
            drawnow; %flushes the event queue; necessary?
            
            if chk == 0 %transfer whole data package initially to stimulation
               load1401();
            end
         end
         
         %Execute sampling cycles:
         %OUTPUT: just use DAC0; immediate signal, no trigger! use HT for trigger, check exsample code; disable interrupt for output loop?
         MATCED32('cedSendString',['MEMDAC,I,2,0,',sz,',0,',swps,',H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
            
         %Check for termination condition continously:
         if obj.ToggleState == 1
            while obj.ToggleState == 1
               %Wait and report currently played byte adress:
               MATCED32('cedSendString','MEMDAC,P:?;');
               addr = str2double(MATCED32('cedGetString'));
               display(addr);
            end
         elseif obj.ToggleState == 0
            %ABORT MEMDAC AFTER END OF CYCLE OR KILL IMMEDIATELY? CURRENTLY TRYING THE LATTER FOR THE SAKE OF SECURITY
            MATCED32('cedSendString','MEMDAC,K;');
         end         
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.toggle);
         Hloc = rmfield(Hloc,'toggle');
         setappdata(obj.Parent,'uihandles',Hloc);
       end      
   end
end