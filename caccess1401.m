%On event calls method for 1401 stimulation routine (data transfer & execution)
classdef caccess1401 < handle
   properties (SetAccess = public, GetAccess = public)
      ToggleState = 0;
      ListeningTo
      SignalObj
      Prefs
      Parent
      DacScale = 2^16/10; %implement as device property in separate data holding class/struct; Voltage scaling by DAC units: voltage resolution is given by 16bit for a 10V range; thus 1V equals to 6553.6 DAC units/ minimum step width (resolution) is 1,53mV (1DAC unit)
   end
   events
      ToggleOn
      ToggleOff
   end
   methods
      %Constructor:
      function obj = caccess1401(h,inidat,src1)
         obj.Parent = h.main;
         obj.SignalObj = src1;
         Hloc = getappdata(obj.Parent,'uihandles');
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
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
         
         Hloc.toggle = uicontrol('Style','togglebutton','String',inidat{2},'Position',inidat{1},'Enable','off','Callback',@(src,evt)ToggleCheck(obj,src,evt));
         setappdata(h.main,'uihandles',Hloc);
         
         if inidat{3} == 1
            set(Hloc.toggle,'Enable','on');
         end
         
         addlistener(obj,'ToggleOn',@(src,evt)StimCtrl(obj,src,evt));
         %(Listening to ToggleOff is not necessary at all as stop condition (see below) is checked before every iteration correctly)
         
         %Following code is to be implemented at a more appropriate point:
         MATCED32('cedSendString','CLEAR;');
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
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         chk = -1; %some initial value ~= 0,1,2,-128
         sz = int2str(2*obj.SignalObj.DataLength); %sz: number of BYTES to be sampled from; note: 1401 splits two byte data into 2 subchunks, claiming twice as much memory space!
         
         %Check if 1401 is ready and initiate data transfer:
         while chk ~= 0
            MATCED32('cedSendString','MEMDAC,?;');
            chk = str2double(MATCED32('cedGetString')); %Every query to 1401 causes load of string into output buffer stack, where the data has to be fetched from by host via getstring!
            drawnow; %flushes the event queue; necessary?
            
            if chk == 0 %transfer whole data package initially to stimulation
               dacOut = obj.DacScale * obj.SignalObj.Signal; %Conversion of input params into DAC-units:
               MATCED32('cedTo1401',obj.SignalObj.DataLength,0,dacOut); %Load the data to 1401 buffer (check max. RAM load); to generate complex signals change digits of dacOut- Array! for realtime manipulation invent more dynamic memory management paradigm
            end
         end
         
         %Execute the first sampling cycle:
         %OUTPUT: just use DAC0; immediate signal, no trigger! use HT for trigger, check exsample code; disable interrupt for output loop?
         %Define RAM sector for output!
         MATCED32('cedSendString',['MEMDAC,I,2,0,',sz,',0,1,H,10,10;']); %analog waveform output from RAM-Data (--> MEMDAC): kind: I (interrupt driven), byte: 2 (thus 16bit data), st: 0 (start at user RAM address 0); sz (size of transferred data, look above), chan: 0 (defines output channel: DAC-output 0), rpts: 1 (number of repeats), clock: H (high-speed clock: 4MHz (native sample rate; SEE FURTHER)), pre*cnt: 10*10 = 100: downsampling the selected clock by divisor of 100! --> sample rate of 40kHz, as implemented above! --> see manual: "clock set up"
            
         %Execute signal update & sampling loop (hoping updating is fast enough to be done before currently played address reaches first digit of update data package):
         while obj.ListeningTo.ToggleState == 1
            %Conversion of input params into DAC-units and split signal array:
            dacOuth1 = obj.DacScale * obj.SignalObj.Signal(1:(length(obj.SignalObj.Signal)/2));
            dacOuth2 = obj.DacScale * obj.SignalObj.Signal((length(obj.SignalObj.Signal)/2+1):(length(obj.SignalObj.Signal)));
            
            MATCED32('cedSendString','MEMDAC,?;');
            chk = str2double(MATCED32('cedGetString'));
            drawnow;
            
            if chk==0 || chk==1
               MATCED32('cedTo1401',(obj.SignalObj.DataLength/2),0,dacOuth1);
               while chk == 1
                  %Waiting...
                  MATCED32('cedSendString','MEMDAC,?;');
                  chk = str2double(MATCED32('cedGetString'));
                  drawnow;
               end
               MATCED32('cedSendString',['MEMDAC,I,2,0,',sz,',0,1,H,10,10;']); %CMD forces start of sampling --> waiting loop; RECONSIDER!
            elseif chk == -128
               MATCED32('cedTo1401',(obj.SignalObj.DataLength/2),obj.SignalObj.DataLength,dacOuth2);
            end
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